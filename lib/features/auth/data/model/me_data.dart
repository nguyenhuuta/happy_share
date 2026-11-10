import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../consent/data/model/consent_info.dart';
import '../../../family/data/model/family_with_member.dart';
import 'user.dart';

part 'me_data.freezed.dart';
part 'me_data.g.dart';

/// `GET /me` — app gọi khi mở để quyết định điều hướng (B5).
/// `families` rỗng khi chưa thuộc nhóm nào (vẫn dùng được nhật ký cá nhân, D15). `consent` (ghi nhận
/// hành trình của chính mình) luôn là object; chưa bật → `status: null`.
@freezed
abstract class MeData with _$MeData {
  const factory MeData({
    required User user,
    @Default(<FamilyWithMember>[]) List<FamilyWithMember> families,
    required ConsentInfo consent,
  }) = _MeData;

  factory MeData.fromJson(Map<String, dynamic> json) => _$MeDataFromJson(json);
}
