// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConsentInfo _$ConsentInfoFromJson(Map<String, dynamic> json) => _ConsentInfo(
  status: $enumDecodeNullable(
    _$ConsentStatusEnumMap,
    json['status'],
    unknownValue: ConsentStatus.unknown,
  ),
  consentVersion: json['consent_version'] as String,
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ConsentInfoToJson(_ConsentInfo instance) =>
    <String, dynamic>{
      'status': _$ConsentStatusEnumMap[instance.status],
      'consent_version': instance.consentVersion,
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

const _$ConsentStatusEnumMap = {
  ConsentStatus.granted: 'granted',
  ConsentStatus.paused: 'paused',
  ConsentStatus.revoked: 'revoked',
  ConsentStatus.unknown: 'unknown',
};
