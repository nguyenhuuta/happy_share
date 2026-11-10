import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/domain_constants.dart';
import '../../../../core/constants/domain_enums.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// User (A4). `identifier` đã được server chuẩn hóa (D13). `timezone` quyết định cách cắt ngày
/// của dữ liệu của người này (D08) — KHÔNG dùng múi giờ của máy.
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String identifier,
    @JsonKey(unknownEnumValue: IdentifierType.unknown)
    required IdentifierType identifierType,
    required String displayName,
    String? avatarUrl,
    @Default(kDefaultTimezone) String timezone,
    required DateTime createdAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
