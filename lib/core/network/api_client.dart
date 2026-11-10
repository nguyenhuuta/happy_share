import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:injectable/injectable.dart';

import '../config/env.dart';
import '../storage/secure_token_store.dart';
import 'api_envelope.dart';
import 'api_exception.dart';
import 'auth_interceptor.dart';

/// Client HTTP duy nhất của app. Mở envelope và ném [ApiException].
/// Trả về phần `data` (thường là `Map<String, dynamic>`).
@lazySingleton
class ApiClient {
  ApiClient(Env env, TokenStore tokenStore) {
    BaseOptions options() => BaseOptions(
      baseUrl: env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      // Luôn nhận phản hồi để tự đọc envelope lỗi (không ném theo HTTP status).
      validateStatus: (_) => true,
    );
    _dio = Dio(options());
    _refreshDio = Dio(options());
    _dio.interceptors.add(
      AuthInterceptor(
        dio: _dio,
        refreshDio: _refreshDio,
        tokenStore: tokenStore,
        onSessionExpired: () => _sessionExpired.add(null),
      ),
    );
  }

  late final Dio _dio;
  late final Dio _refreshDio;
  final _sessionExpired = StreamController<void>.broadcast();

  /// Phát khi refresh token không còn hợp lệ → app xóa phiên, về màn đăng nhập.
  Stream<void> get sessionExpired => _sessionExpired.stream;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) => _send('GET', path, query: query);

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    bool authenticated = true,
  }) => _send('POST', path, body: body, authenticated: authenticated);

  Future<Map<String, dynamic>> patch(String path, {Object? body}) =>
      _send('PATCH', path, body: body);

  Future<Map<String, dynamic>> delete(String path, {Object? body}) =>
      _send('DELETE', path, body: body);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool authenticated = true,
  }) async {
    final Response<dynamic> res;
    try {
      res = await _dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        options: Options(
          method: method,
          extra: {kExtraAuthenticated: authenticated},
        ),
      );
    } on DioException catch (e) {
      throw ApiException(ApiErrorCode.networkError, message: e.type.name);
    }

    final envelope = ApiEnvelope.tryParse(res.data);
    if (envelope == null) {
      // Không phải envelope (vd. proxy trả HTML 502).
      throw ApiException(
        (res.statusCode ?? 0) >= 500
            ? ApiErrorCode.internalError
            : ApiErrorCode.unknown,
        httpStatus: res.statusCode,
      );
    }
    if (!envelope.success) {
      final err = envelope.error;
      throw ApiException(
        err?.code ?? ApiErrorCode.unknown,
        message: err?.message,
        httpStatus: res.statusCode,
        details: err?.details ?? const {},
      );
    }
    final data = envelope.data;
    return data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  }

  /// Chỉ dùng trong test: thay adapter HTTP cho cả request thường lẫn refresh.
  @visibleForTesting
  void useAdapter(HttpClientAdapter adapter) {
    _dio.httpClientAdapter = adapter;
    _refreshDio.httpClientAdapter = adapter;
  }

  @disposeMethod
  void dispose() => _sessionExpired.close();
}
