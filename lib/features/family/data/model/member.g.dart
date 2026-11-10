// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Member _$MemberFromJson(Map<String, dynamic> json) => _Member(
  memberId: json['member_id'] as String,
  userId: json['user_id'] as String,
  displayName: json['display_name'] as String,
  nickname: json['nickname'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  role: $enumDecode(
    _$MemberRoleEnumMap,
    json['role'],
    unknownValue: MemberRole.unknown,
  ),
  status: $enumDecode(
    _$MemberStatusEnumMap,
    json['status'],
    unknownValue: MemberStatus.unknown,
  ),
  joinedAt: DateTime.parse(json['joined_at'] as String),
  sharingState: $enumDecode(
    _$SharingStateEnumMap,
    json['sharing_state'],
    unknownValue: SharingState.unknown,
  ),
  isMe: json['is_me'] as bool,
);

Map<String, dynamic> _$MemberToJson(_Member instance) => <String, dynamic>{
  'member_id': instance.memberId,
  'user_id': instance.userId,
  'display_name': instance.displayName,
  'nickname': instance.nickname,
  'avatar_url': instance.avatarUrl,
  'role': _$MemberRoleEnumMap[instance.role]!,
  'status': _$MemberStatusEnumMap[instance.status]!,
  'joined_at': instance.joinedAt.toIso8601String(),
  'sharing_state': _$SharingStateEnumMap[instance.sharingState]!,
  'is_me': instance.isMe,
};

const _$MemberRoleEnumMap = {
  MemberRole.owner: 'owner',
  MemberRole.member: 'member',
  MemberRole.unknown: 'unknown',
};

const _$MemberStatusEnumMap = {
  MemberStatus.active: 'active',
  MemberStatus.left: 'left',
  MemberStatus.removed: 'removed',
  MemberStatus.unknown: 'unknown',
};

const _$SharingStateEnumMap = {
  SharingState.sharing: 'sharing',
  SharingState.limited: 'limited',
  SharingState.paused: 'paused',
  SharingState.notShared: 'not_shared',
  SharingState.unknown: 'unknown',
};
