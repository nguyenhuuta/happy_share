// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: json['id'] as String,
  identifier: json['identifier'] as String,
  identifierType: $enumDecode(
    _$IdentifierTypeEnumMap,
    json['identifier_type'],
    unknownValue: IdentifierType.unknown,
  ),
  displayName: json['display_name'] as String,
  avatarUrl: json['avatar_url'] as String?,
  timezone: json['timezone'] as String? ?? kDefaultTimezone,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'identifier': instance.identifier,
  'identifier_type': _$IdentifierTypeEnumMap[instance.identifierType]!,
  'display_name': instance.displayName,
  'avatar_url': instance.avatarUrl,
  'timezone': instance.timezone,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$IdentifierTypeEnumMap = {
  IdentifierType.email: 'email',
  IdentifierType.phone: 'phone',
  IdentifierType.username: 'username',
  IdentifierType.unknown: 'unknown',
};
