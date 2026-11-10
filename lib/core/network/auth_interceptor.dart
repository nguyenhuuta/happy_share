import 'dart:async';

import 'package:dio/dio.dart';

import '../storage/secure_token_store.dart';
import 'api_envelope.dart';
import 'api_exception.dart';
import 'auth_tokens.dart';

/// Cờ trong `RequestOptions.extra` (mặc định true).
const kExtraAuthenticated = 'authenticated';
const _kExtraRetried = 'auth_retried';

/// Gắn Bearer token; khi gặp 401 `TOKEN_EXPIRED` (hoặc `UNAUTHENTICATED`) thì refresh rồi
/// thử lại đúng 1 lần.
///
/// - Chỉ một request refresh tại một thời điểm: các request khác chờ cùng
///   một `Future`.
/// - Chống race giữa isolate foreground và isolate workmanager (refresh token
///   xoay vòng): trước khi refresh, và khi refresh bị từ chối, đọc lại kho
///   token — nếu token đã bị bên kia đổi thì dùng token mới, KHÔNG đăng xuất.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required Dio dio,
    required Dio refreshDio,
    required TokenStore tokenStore,
    required void Function() onSessionExpired,
  }) : _dio = dio,
       _refreshDio = refreshDio,
       _tokenStore = tokenStore,
       _onSessionExpired = onSessionExpired;

  final Dio _dio;
  final Dio _refreshDio; // không gắn interceptor này
  final TokenStore _tokenStore;
  final void Function() _onSessionExpired;

  Future<AuthTokens?>? _refreshing;

  bool _needsAuth(RequestOptions o) => o.extra[kExtraAuthenticated] != false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_needsAuth(options)) {
      final tokens = await _tokenStore.read();
      if (tokens != null) {
        options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    final options = response.requestOptions;
    final envelope = ApiEnvelope.tryParse(response.data);
    // `TOKEN_EXPIRED`: access token hết hạn. `UNAUTHENTICATED` trên request đã gắn token: token
    // hỏng hoặc tài khoản đã bị xóa (server S4 từ chối ngay, không đợi 15 phút) — thử refresh một
    // lần; nếu refresh trả `REFRESH_TOKEN_INVALID` thì xóa phiên và về màn đăng nhập.
    final code = envelope?.error?.code;
    final expired =
        response.statusCode == 401 &&
        (code == ApiErrorCode.tokenExpired ||
            code == ApiErrorCode.unauthenticated) &&
        _needsAuth(options) &&
        options.extra[_kExtraRetried] != true;
    if (!expired) return handler.next(response);

    final tokens = await _refresh(_bearerOf(options));
    if (tokens == null) {
      // Không refresh được: trả nguyên phản hồi để ApiClient ném ApiException.
      return handler.next(response);
    }
    options.extra[_kExtraRetried] = true;
    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (e) {
      handler.reject(e);
    }
  }

  String? _bearerOf(RequestOptions o) {
    final h = o.headers['Authorization']?.toString();
    return h != null && h.startsWith('Bearer ') ? h.substring(7) : null;
  }

  Future<AuthTokens?> _refresh(String? usedAccessToken) =>
      _refreshing ??= _doRefresh(usedAccessToken).whenComplete(() {
        _refreshing = null;
      });

  Future<AuthTokens?> _doRefresh(String? usedAccessToken) async {
    final current = await _tokenStore.read();
    if (current == null) {
      _onSessionExpired();
      return null;
    }
    // Bên khác (isolate nền) đã refresh xong: dùng luôn token mới.
    if (usedAccessToken != null && current.accessToken != usedAccessToken) {
      return current;
    }
    try {
      final res = await _refreshDio.post<dynamic>(
        '/auth/refresh',
        data: {'refresh_token': current.refreshToken},
      );
      final envelope = ApiEnvelope.tryParse(res.data);
      if (envelope != null && envelope.success && envelope.data is Map) {
        final data = Map<String, dynamic>.from(envelope.data as Map);
        final tokens = AuthTokens.fromJson(
          Map<String, dynamic>.from(data['tokens'] as Map),
        );
        await _tokenStore.write(tokens);
        return tokens;
      }
      if (envelope?.error?.code == ApiErrorCode.refreshTokenInvalid) {
        // Có thể bên kia vừa xoay vòng: đọc lại trước khi kết luận hết phiên.
        final latest = await _tokenStore.read();
        if (latest != null && latest.refreshToken != current.refreshToken) {
          return latest;
        }
        await _tokenStore.clear();
        _onSessionExpired();
        return null;
      }
    } on DioException {
      // Lỗi mạng khi refresh: không đăng xuất, để request gốc báo lỗi.
    }
    return null;
  }
}
