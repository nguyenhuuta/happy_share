import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/constants/domain_enums.dart';

part 'consent_info.freezed.dart';
part 'consent_info.g.dart';

/// Trạng thái ghi nhận hành trình của chính mình (`/me.consent`, `/locations/consent`) — cấp tài
/// khoản, không phụ thuộc nhóm (D15). `status == null` nghĩa là chưa từng bật.
@freezed
abstract class ConsentInfo with _$ConsentInfo {
  const ConsentInfo._();

  const factory ConsentInfo({
    @JsonKey(unknownEnumValue: ConsentStatus.unknown) ConsentStatus? status,
    required String consentVersion,
    DateTime? updatedAt,
  }) = _ConsentInfo;

  factory ConsentInfo.fromJson(Map<String, dynamic> json) =>
      _$ConsentInfoFromJson(json);

  /// Đang ghi nhận hoặc tạm dừng — đã qua bước đồng ý, không cần màn giới thiệu nữa.
  bool get hasAgreed =>
      status == ConsentStatus.granted || status == ConsentStatus.paused;
}
