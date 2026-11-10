import 'package:freezed_annotation/freezed_annotation.dart';

part 'invitation.freezed.dart';
part 'invitation.g.dart';

/// Lời mời (A4): mã 8 ký tự dùng một lần, hết hạn sau 48 giờ. Mã chỉ hiện đúng một lần
/// khi tạo (server chỉ lưu hash) nên không được lưu lại cục bộ.
@freezed
abstract class Invitation with _$Invitation {
  const factory Invitation({
    required String code,
    required DateTime expiresAt,
    required String qrPayload,
  }) = _Invitation;

  factory Invitation.fromJson(Map<String, dynamic> json) =>
      _$InvitationFromJson(json);
}
