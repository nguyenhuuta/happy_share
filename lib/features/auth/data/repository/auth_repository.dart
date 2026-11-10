import 'package:injectable/injectable.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/network/auth_tokens.dart';
import '../../../../core/storage/local_data_cleaner.dart';
import '../../../../core/storage/secure_token_store.dart';
import '../model/user.dart';

/// Đăng ký / đăng nhập / đăng xuất. Một ô `identifier` duy nhất (D13): gửi nguyên chuỗi người
/// dùng nhập (chỉ `trim`), server tự nhận dạng và chuẩn hóa — mobile KHÔNG tự đoán loại.
@lazySingleton
class AuthRepository {
  AuthRepository(this._api, this._tokens, this._cleaner);

  final ApiClient _api;
  final TokenStore _tokens;
  final LocalDataCleaner _cleaner;

  Future<User> register({
    required String identifier,
    required String password,
    required String displayName,
  }) => _authenticate('/auth/register', {
    'identifier': identifier.trim(),
    'password': password,
    'display_name': displayName.trim(),
  });

  Future<User> login({required String identifier, required String password}) =>
      _authenticate('/auth/login', {
        'identifier': identifier.trim(),
        'password': password,
      });

  Future<User> _authenticate(String path, Map<String, dynamic> body) async {
    final data = await _api.post(path, body: body, authenticated: false);
    final User user;
    final AuthTokens tokens;
    try {
      user = User.fromJson(Map<String, dynamic>.from(data['user'] as Map));
      tokens = AuthTokens.fromJson(
        Map<String, dynamic>.from(data['tokens'] as Map),
      );
    } on Object {
      // Phản hồi sai định dạng: không lưu gì, báo lỗi chung.
      throw const ApiException(ApiErrorCode.unknown);
    }
    // Không để sót dữ liệu cục bộ của phiên/tài khoản trước.
    await _cleaner.clearAll();
    await _tokens.write(tokens);
    return user;
  }

  /// Đăng xuất. Luôn xóa dữ liệu cục bộ dù API lỗi (mạng…).
  ///
  /// Refresh token xoay vòng mỗi lần refresh. Nếu `AuthInterceptor` refresh GIỮA CHỪNG request
  /// logout (access hết hạn), refresh token vừa gửi đã bị vô hiệu và token mới vẫn còn hiệu lực
  /// trên server; vì vậy đọc lại kho token sau mỗi lần gửi và gửi lại nếu token đã đổi.
  Future<void> logout() async {
    try {
      String? lastSent;
      for (var attempt = 0; attempt < 3; attempt++) {
        final tokens = await _tokens.read();
        if (tokens == null || tokens.refreshToken == lastSent) break;
        lastSent = tokens.refreshToken;
        await _api.post(
          '/auth/logout',
          body: {'refresh_token': tokens.refreshToken},
        );
      }
    } on ApiException {
      // Best effort: server sẽ tự thu hồi phiên khi token hết hạn.
    } finally {
      await _cleaner.clearAll();
    }
  }

  /// Phiên đã hết hiệu lực (refresh bị từ chối, tài khoản bị xóa…): chỉ dọn cục bộ, không gọi API.
  Future<void> clearLocalSession() => _cleaner.clearAll();
}
