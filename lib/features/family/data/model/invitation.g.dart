// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Invitation _$InvitationFromJson(Map<String, dynamic> json) => _Invitation(
  code: json['code'] as String,
  expiresAt: DateTime.parse(json['expires_at'] as String),
  qrPayload: json['qr_payload'] as String,
);

Map<String, dynamic> _$InvitationToJson(_Invitation instance) =>
    <String, dynamic>{
      'code': instance.code,
      'expires_at': instance.expiresAt.toIso8601String(),
      'qr_payload': instance.qrPayload,
    };
