import 'package:freezed_annotation/freezed_annotation.dart';

import 'family.dart';
import 'member.dart';

part 'family_with_member.freezed.dart';
part 'family_with_member.g.dart';

/// Phản hồi của `POST /families` và `POST /families/join`: `{family, member}`.
@freezed
abstract class FamilyWithMember with _$FamilyWithMember {
  const factory FamilyWithMember({
    required Family family,
    required Member member,
  }) = _FamilyWithMember;

  factory FamilyWithMember.fromJson(Map<String, dynamic> json) =>
      _$FamilyWithMemberFromJson(json);
}
