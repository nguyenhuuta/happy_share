import 'package:injectable/injectable.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../model/me_data.dart';
import '../model/user.dart';

@lazySingleton
class MeRepository {
  MeRepository(this._api);

  final ApiClient _api;

  /// `GET /me`.
  Future<MeData> getMe() async {
    final data = await _api.get('/me');
    try {
      return MeData.fromJson(data);
    } on Object {
      throw const ApiException(ApiErrorCode.unknown);
    }
  }

  /// `PATCH /me` — chỉ gửi trường nào được truyền. `timezone` là tên IANA (D08).
  Future<User> updateMe({String? displayName, String? timezone}) async {
    final data = await _api.patch(
      '/me',
      body: {'display_name': ?displayName?.trim(), 'timezone': ?timezone},
    );
    try {
      return User.fromJson(Map<String, dynamic>.from(data['user'] as Map));
    } on Object {
      throw const ApiException(ApiErrorCode.unknown);
    }
  }
}
