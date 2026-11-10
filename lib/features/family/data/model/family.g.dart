// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Family _$FamilyFromJson(Map<String, dynamic> json) => _Family(
  id: json['id'] as String,
  name: json['name'] as String,
  timezone: json['timezone'] as String,
  ownerUserId: json['owner_user_id'] as String,
  plan: $enumDecode(
    _$SubscriptionPlanEnumMap,
    json['plan'],
    unknownValue: SubscriptionPlan.unknown,
  ),
  memberCount: (json['member_count'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$FamilyToJson(_Family instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'timezone': instance.timezone,
  'owner_user_id': instance.ownerUserId,
  'plan': _$SubscriptionPlanEnumMap[instance.plan]!,
  'member_count': instance.memberCount,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$SubscriptionPlanEnumMap = {
  SubscriptionPlan.free: 'free',
  SubscriptionPlan.basic: 'basic',
  SubscriptionPlan.premium: 'premium',
  SubscriptionPlan.beta: 'beta',
  SubscriptionPlan.unknown: 'unknown',
};
