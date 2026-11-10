// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_with_member.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FamilyWithMember _$FamilyWithMemberFromJson(Map<String, dynamic> json) =>
    _FamilyWithMember(
      family: Family.fromJson(json['family'] as Map<String, dynamic>),
      member: Member.fromJson(json['member'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FamilyWithMemberToJson(_FamilyWithMember instance) =>
    <String, dynamic>{
      'family': instance.family.toJson(),
      'member': instance.member.toJson(),
    };
