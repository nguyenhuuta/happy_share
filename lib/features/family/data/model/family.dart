import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/domain_enums.dart';

part 'family.freezed.dart';
part 'family.g.dart';

/// Family (A4). `timezone` quyết định cách cắt ngày (D08) — KHÔNG dùng múi giờ của máy.
@freezed
abstract class Family with _$Family {
  const factory Family({
    required String id,
    required String name,
    required String timezone,
    required String ownerUserId,
    @JsonKey(unknownEnumValue: SubscriptionPlan.unknown)
    required SubscriptionPlan plan,
    required int memberCount,
    required DateTime createdAt,
  }) = _Family;

  factory Family.fromJson(Map<String, dynamic> json) => _$FamilyFromJson(json);
}
