import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/domain_enums.dart';

part 'member.freezed.dart';
part 'member.g.dart';

/// Member (A4). `role` có thể đổi (vd. chủ nhóm xóa tài khoản) nên không cache lâu.
@freezed
abstract class Member with _$Member {
  const Member._();

  const factory Member({
    required String memberId,
    required String userId,
    required String displayName,
    String? nickname,
    String? avatarUrl,
    @JsonKey(unknownEnumValue: MemberRole.unknown) required MemberRole role,
    @JsonKey(unknownEnumValue: MemberStatus.unknown)
    required MemberStatus status,
    required DateTime joinedAt,
    @JsonKey(unknownEnumValue: SharingState.unknown)
    required SharingState sharingState,
    required bool isMe,
  }) = _Member;

  factory Member.fromJson(Map<String, dynamic> json) => _$MemberFromJson(json);

  /// Tên hiển thị trong gia đình: biệt danh (nếu có) thay cho tên tài khoản.
  String get label => (nickname != null && nickname!.trim().isNotEmpty)
      ? nickname!
      : displayName;

  bool get isOwner => role == MemberRole.owner;
}
