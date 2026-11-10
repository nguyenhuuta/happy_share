import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/session/app_session_cubit.dart';
import '../../data/model/invitation.dart';
import '../../data/model/member.dart';
import '../../data/repository/family_repository.dart';

enum MembersStatus { loading, loaded, failure }

class MembersState extends Equatable {
  const MembersState({
    this.status = MembersStatus.loading,
    this.members = const [],
    this.invitation,
    this.inviting = false,
    this.busy = false,
    this.error,
  });

  final MembersStatus status;
  final List<Member> members;

  /// Lời mời vừa tạo. Mã chỉ hiện đúng một lần nên chỉ giữ trong bộ nhớ đến khi đóng sheet.
  final Invitation? invitation;
  final bool inviting;

  /// Đang xóa/đổi biệt danh/rời nhóm.
  final bool busy;
  final ApiErrorCode? error;

  Member? get me {
    for (final m in members) {
      if (m.isMe) return m;
    }
    return null;
  }

  bool get iAmOwner => me?.isOwner ?? false;

  MembersState copyWith({
    MembersStatus? status,
    List<Member>? members,
    Invitation? invitation,
    bool clearInvitation = false,
    bool? inviting,
    bool? busy,
    ApiErrorCode? error,
    bool clearError = false,
  }) => MembersState(
    status: status ?? this.status,
    members: members ?? this.members,
    invitation: clearInvitation ? null : (invitation ?? this.invitation),
    inviting: inviting ?? this.inviting,
    busy: busy ?? this.busy,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [
    status,
    members,
    invitation,
    inviting,
    busy,
    error,
  ];
}

/// Tab Thành viên: danh sách, mời, đổi biệt danh, xóa, rời nhóm.
/// Mọi quyết định quyền (chủ nhóm…) do server; cubit chỉ phản ánh lỗi `FORBIDDEN`/`NOT_FAMILY_MEMBER`.
@injectable
class MembersCubit extends Cubit<MembersState> {
  MembersCubit(this._families, this._session) : super(const MembersState());

  final FamilyRepository _families;
  final AppSessionCubit _session;

  /// Nhóm đang xem (người dùng có thể ở nhiều nhóm). null khi chưa thuộc nhóm nào.
  String? get _familyId => _session.state.activeFamily?.family.id;

  Future<void> load() async {
    final familyId = _familyId;
    if (familyId == null) {
      emit(
        state.copyWith(
          status: MembersStatus.failure,
          error: ApiErrorCode.notFamilyMember,
        ),
      );
      return;
    }
    // Giữ danh sách cũ khi tải lại (kéo để làm mới) để UI không nhấp nháy.
    emit(
      state.copyWith(
        status: state.members.isEmpty ? MembersStatus.loading : state.status,
        clearError: true,
      ),
    );
    try {
      final members = await _families.listMembers(familyId);
      emit(
        state.copyWith(
          status: MembersStatus.loaded,
          members: members,
          clearError: true,
        ),
      );
    } on ApiException catch (e) {
      await _onError(e, fatalIfEmpty: true);
    }
  }

  /// Chủ nhóm tạo mã mời mới. Kết quả nằm ở [MembersState.invitation].
  Future<void> createInvitation() async {
    final familyId = _familyId;
    if (familyId == null || state.inviting) return;
    emit(state.copyWith(inviting: true, clearError: true));
    try {
      final invitation = await _families.createInvitation(familyId);
      emit(state.copyWith(inviting: false, invitation: invitation));
    } on ApiException catch (e) {
      emit(state.copyWith(inviting: false));
      await _onError(e);
    }
  }

  void dismissInvitation() => emit(state.copyWith(clearInvitation: true));

  Future<void> updateNickname(String memberId, String nickname) async {
    final familyId = _familyId;
    if (familyId == null || state.busy) return;
    emit(state.copyWith(busy: true, clearError: true));
    try {
      final updated = await _families.updateNickname(
        familyId: familyId,
        memberId: memberId,
        nickname: nickname,
      );
      emit(
        state.copyWith(
          busy: false,
          members: [
            for (final m in state.members)
              m.memberId == updated.memberId ? updated : m,
          ],
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(busy: false));
      await _onError(e);
    }
  }

  Future<void> removeMember(String memberId) async {
    final familyId = _familyId;
    if (familyId == null || state.busy) return;
    emit(state.copyWith(busy: true, clearError: true));
    try {
      await _families.removeMember(familyId: familyId, memberId: memberId);
      emit(
        state.copyWith(
          busy: false,
          members: [
            for (final m in state.members)
              if (m.memberId != memberId) m,
          ],
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(busy: false));
      await _onError(e);
    }
  }

  /// Rời nhóm đang xem. Chỉ mất quyền xem nhóm đó; ghi nhận hành trình cá nhân KHÔNG đổi (D15) nên
  /// không dừng thu thập hay xóa hàng đợi. Chủ nhóm còn người khác → `OWNER_CANNOT_LEAVE`.
  Future<void> leave() async {
    final familyId = _familyId;
    if (familyId == null || state.busy) return;
    emit(state.copyWith(busy: true, clearError: true));
    try {
      await _families.leave(familyId);
    } on ApiException catch (e) {
      emit(state.copyWith(busy: false));
      await _onError(e);
      return;
    }
    emit(state.copyWith(busy: false));
    await _session
        .refreshMe(); // nhóm đang xem tự chuyển sang nhóm còn lại (hoặc trống)
  }

  Future<void> _onError(ApiException e, {bool fatalIfEmpty = false}) async {
    // Mình không còn thuộc nhóm này (bị xóa/đã rời ở máy khác): đồng bộ lại.
    if (e.code == ApiErrorCode.notFamilyMember) {
      await _session.refreshMe();
    }
    final failed = fatalIfEmpty && state.members.isEmpty;
    emit(
      state.copyWith(
        status: failed ? MembersStatus.failure : state.status,
        error: e.code,
      ),
    );
  }
}
