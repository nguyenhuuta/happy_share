import 'package:injectable/injectable.dart';

import '../../../../core/constants/domain_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../model/family_with_member.dart';
import '../model/invitation.dart';
import '../model/member.dart';

/// Tạo/tham gia nhóm (API giữ tên `families`, D14), thành viên, lời mời (A4). Chỉ gọi API và phân tích kết quả;
/// quyền (owner…) và giới hạn gói do server quyết định.
@lazySingleton
class FamilyRepository {
  FamilyRepository(this._api);

  final ApiClient _api;

  /// `POST /families`. Tạo nhóm là đồng ý chia sẻ (D16) nên luôn gửi [kCurrentSharingConsentVersion];
  /// UI phải đã hiển thị nội dung đồng ý trước đó. `timezone` bỏ trống → mặc định của server.
  Future<FamilyWithMember> createFamily({
    required String name,
    String? timezone,
  }) async => _parse(
    await _api.post(
      '/families',
      body: {
        'name': name.trim(),
        'timezone': ?timezone,
        'sharing_consent_version': kCurrentSharingConsentVersion,
      },
    ),
    FamilyWithMember.fromJson,
  );

  /// `POST /families/join`. [code] nên là mã đã qua `normalizeInviteCode`. Vào nhóm là đồng ý chia sẻ
  /// (D16) nên gửi kèm [kCurrentSharingConsentVersion].
  Future<FamilyWithMember> joinFamily(String code) async => _parse(
    await _api.post(
      '/families/join',
      body: {
        'code': code,
        'sharing_consent_version': kCurrentSharingConsentVersion,
      },
    ),
    FamilyWithMember.fromJson,
  );

  /// `GET /families/:id/members` — chỉ member `active`, sắp theo ngày tham gia.
  Future<List<Member>> listMembers(String familyId) async {
    final data = await _api.get('/families/$familyId/members');
    return _parse(data, (json) {
      final items = json['items'] as List;
      return [
        for (final m in items)
          Member.fromJson(Map<String, dynamic>.from(m as Map)),
      ];
    });
  }

  /// `POST /families/:id/invitations` (chủ nhóm). Mã chỉ trả về một lần.
  Future<Invitation> createInvitation(String familyId) async => _parse(
    await _api.post('/families/$familyId/invitations'),
    Invitation.fromJson,
  );

  /// `PATCH /families/:id/members/:memberId` — chỉ đổi biệt danh của chính mình.
  Future<Member> updateNickname({
    required String familyId,
    required String memberId,
    required String nickname,
  }) async {
    final data = await _api.patch(
      '/families/$familyId/members/$memberId',
      body: {'nickname': nickname.trim()},
    );
    return _parse(
      data,
      (json) =>
          Member.fromJson(Map<String, dynamic>.from(json['member'] as Map)),
    );
  }

  /// `DELETE /families/:id/members/:memberId` — chủ nhóm xóa người khác.
  Future<void> removeMember({
    required String familyId,
    required String memberId,
  }) async {
    await _api.delete('/families/$familyId/members/$memberId');
  }

  /// `POST /families/:id/leave`. Mất quyền xem nhóm đó ngay; KHÔNG đổi ghi nhận cá nhân của mình
  /// (D15) nên không dừng thu thập hay xóa hàng đợi.
  Future<void> leave(String familyId) async {
    await _api.post('/families/$familyId/leave');
  }

  T _parse<T>(
    Map<String, dynamic> data,
    T Function(Map<String, dynamic>) parser,
  ) {
    try {
      return parser(data);
    } on Object {
      throw const ApiException(ApiErrorCode.unknown);
    }
  }
}
