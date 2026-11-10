// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'me_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MeData _$MeDataFromJson(Map<String, dynamic> json) => _MeData(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  families:
      (json['families'] as List<dynamic>?)
          ?.map((e) => FamilyWithMember.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <FamilyWithMember>[],
  consent: ConsentInfo.fromJson(json['consent'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MeDataToJson(_MeData instance) => <String, dynamic>{
  'user': instance.user.toJson(),
  'families': instance.families.map((e) => e.toJson()).toList(),
  'consent': instance.consent.toJson(),
};
