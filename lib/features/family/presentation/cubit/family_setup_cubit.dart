import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/session/app_session_cubit.dart';
import '../../../../core/utils/invite_code.dart';
import '../../../../core/utils/submit_state.dart';
import '../../../auth/domain/auth_validators.dart';
import '../../data/model/family_with_member.dart';
import '../../data/repository/family_repository.dart';

/// Tạo nhóm hoặc tham gia bằng mã. Dùng được lúc chưa có nhóm nào và cả khi đã ở nhóm khác
/// (tối đa `kMaxGroupsPerUser`, quá thì `GROUP_LIMIT`). Gọi API là đồng ý chia sẻ với nhóm (D16): UI
/// phải hiển thị nội dung đồng ý trước khi cho bấm.
///
/// Thành công KHÔNG làm mới phiên ngay: nếu làm ngay, router sẽ rời `/family-setup` trước khi
/// người dùng kịp thấy màn xác nhận ("Đã tạo Nhà Nguyễn!"). UI gọi [finish] khi người dùng bấm
/// "Tiếp tục"/"Để sau"/"Mời thành viên".
@injectable
class FamilySetupCubit extends Cubit<SubmitState<FamilyWithMember>> {
  FamilySetupCubit(this._families, this._session) : super(const SubmitState());

  final FamilyRepository _families;
  final AppSessionCubit _session;

  Future<void> create({required String name, required String timezone}) {
    final errors = validateCreateFamily(name: name, timezone: timezone);
    return _submit(
      errors,
      () => _families.createFamily(name: name, timezone: timezone),
    );
  }

  /// [rawCode] là chuỗi người dùng nhập/dán. Sai độ dài/ký tự → báo lỗi ngay, KHÔNG gọi API.
  Future<void> join(String rawCode) {
    final code = normalizeInviteCode(rawCode);
    if (code == null) {
      emit(
        const SubmitState.failure(
          fieldErrors: {
            'code': ['invalid'],
          },
          error: ApiErrorCode.validationError,
        ),
      );
      return Future.value();
    }
    return _submit(const {}, () => _families.joinFamily(code));
  }

  /// Kết thúc luồng: làm mới `/me` rồi chuyển sang nhóm vừa tạo/tham gia.
  Future<void> finish() async {
    final id = state.result?.family.id;
    await _session.refreshMe();
    if (id != null) _session.selectFamily(id);
  }

  void clearErrors() {
    if (state.status == SubmitStatus.failure) emit(const SubmitState());
  }

  Future<void> _submit(
    Map<String, List<String>> localErrors,
    Future<FamilyWithMember> Function() action,
  ) async {
    if (state.isSubmitting) return;
    if (localErrors.isNotEmpty) {
      emit(
        SubmitState.failure(
          fieldErrors: localErrors,
          error: ApiErrorCode.validationError,
        ),
      );
      return;
    }
    emit(const SubmitState.submitting());
    try {
      emit(SubmitState.success(await action()));
    } on ApiException catch (e) {
      // `ALREADY_IN_FAMILY` (đã ở nhóm này): trạng thái cục bộ lạc hậu so với server → đồng bộ lại.
      if (e.code == ApiErrorCode.alreadyInFamily) {
        unawaited(_session.refreshMe());
      }
      emit(SubmitState.fromException(e));
    }
  }
}
