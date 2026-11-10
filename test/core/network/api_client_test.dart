import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happy_share/core/config/env.dart';
import 'package:happy_share/core/network/api_client.dart';
import 'package:happy_share/core/network/api_exception.dart';
import 'package:happy_share/core/network/auth_tokens.dart';
import 'package:happy_share/core/storage/secure_token_store.dart';

class _MemoryTokenStore implements TokenStore {
  AuthTokens? tokens;

  @override
  Future<AuthTokens?> read() async => tokens;

  @override
  Future<void> write(AuthTokens t) async => tokens = t;

  @override
  Future<void> clear() async => tokens = null;
}

typedef _Reply = ({int status, Object? body});

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final FutureOr<_Reply> Function(RequestOptions options) handler;
  final List<RequestOptions> calls = [];

  int count(String path) => calls.where((c) => c.path == path).length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls.add(options);
    final reply = await handler(options);
    final isText = reply.body is String;
    return ResponseBody.fromString(
      isText ? reply.body as String : jsonEncode(reply.body),
      reply.status,
      headers: {
        Headers.contentTypeHeader: [
          isText ? 'text/html' : Headers.jsonContentType,
        ],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

AuthTokens _tokens(String access, String refresh) => AuthTokens(
  accessToken: access,
  refreshToken: refresh,
  accessExpiresAt: DateTime.utc(2030),
  refreshExpiresAt: DateTime.utc(2031),
);

Map<String, dynamic> _tokensJson(String access, String refresh) => {
  'access_token': access,
  'refresh_token': refresh,
  'access_expires_at': '2030-01-01T00:00:00Z',
  'refresh_expires_at': '2031-01-01T00:00:00Z',
};

_Reply _ok(Object data) =>
    (status: 200, body: {'success': true, 'data': data, 'error': null});

_Reply _err(int status, String code, {Map<String, dynamic>? details}) => (
  status: status,
  body: {
    'success': false,
    'data': null,
    'error': {'code': code, 'message': 'x', 'details': details ?? {}},
  },
);

void main() {
  late _MemoryTokenStore store;
  late ApiClient client;

  ApiClient build(_FakeAdapter adapter) {
    final c = ApiClient(
      const Env(
        name: 'test',
        apiBaseUrl: 'http://test/api/v1',
        googleMapsApiKey: '',
      ),
      store,
    );
    c.useAdapter(adapter);
    return c;
  }

  setUp(() => store = _MemoryTokenStore());

  test('trả về data khi success', () async {
    client = build(_FakeAdapter((_) => _ok({'status': 'ok'})));
    expect(await client.get('/health', query: {}), {'status': 'ok'});
  });

  test('gắn Bearer token và bỏ qua khi authenticated=false', () async {
    store.tokens = _tokens('A1', 'R1');
    final adapter = _FakeAdapter((_) => _ok({}));
    client = build(adapter);
    await client.get('/me');
    await client.post('/auth/login', authenticated: false);
    expect(adapter.calls[0].headers['Authorization'], 'Bearer A1');
    expect(adapter.calls[1].headers.containsKey('Authorization'), isFalse);
  });

  test('ném ApiException theo error.code và giữ details', () async {
    client = build(
      _FakeAdapter(
        (_) => _err(
          400,
          'VALIDATION_ERROR',
          details: {
            'fields': {
              'identifier': ['invalidIdentifier'],
            },
          },
        ),
      ),
    );
    await expectLater(
      client.post('/auth/register', body: {}),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', ApiErrorCode.validationError)
            .having((e) => e.fieldErrors, 'fields', {
              'identifier': ['invalidIdentifier'],
            }),
      ),
    );
  });

  test(
    'mã lỗi lạ → unknown; phản hồi không phải envelope 5xx → internalError',
    () async {
      client = build(_FakeAdapter((_) => _err(409, 'SOMETHING_NEW')));
      await expectLater(
        client.get('/x'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            ApiErrorCode.unknown,
          ),
        ),
      );
      client = build(
        _FakeAdapter((_) => (status: 502, body: '<html>bad gateway</html>')),
      );
      await expectLater(
        client.get('/x'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            ApiErrorCode.internalError,
          ),
        ),
      );
    },
  );

  test(
    'TOKEN_EXPIRED → refresh đúng 1 lần cho nhiều request song song, rồi thử lại',
    () async {
      store.tokens = _tokens('OLD', 'R1');
      final adapter = _FakeAdapter((o) async {
        if (o.path == '/auth/refresh') {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return _ok({'tokens': _tokensJson('NEW', 'R2')});
        }
        return o.headers['Authorization'] == 'Bearer NEW'
            ? _ok({'path': o.path})
            : _err(401, 'TOKEN_EXPIRED');
      });
      client = build(adapter);

      final results = await Future.wait([client.get('/a'), client.get('/b')]);

      expect(results.map((r) => r['path']), ['/a', '/b']);
      expect(adapter.count('/auth/refresh'), 1);
      expect(store.tokens!.refreshToken, 'R2');
    },
  );

  test('REFRESH_TOKEN_INVALID → xóa token và phát sessionExpired', () async {
    store.tokens = _tokens('OLD', 'R1');
    final adapter = _FakeAdapter(
      (o) => o.path == '/auth/refresh'
          ? _err(401, 'REFRESH_TOKEN_INVALID')
          : _err(401, 'TOKEN_EXPIRED'),
    );
    client = build(adapter);
    final expired = client.sessionExpired.first;

    await expectLater(
      client.get('/me'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          ApiErrorCode.tokenExpired,
        ),
      ),
    );
    await expired.timeout(const Duration(seconds: 1));
    expect(store.tokens, isNull);
  });

  test(
    'refresh bị từ chối nhưng isolate khác vừa xoay token → KHÔNG đăng xuất',
    () async {
      store.tokens = _tokens('OLD', 'R1');
      var sessionExpiredCount = 0;
      final adapter = _FakeAdapter((o) {
        if (o.path == '/auth/refresh') {
          // Bên kia (isolate nền) đã refresh trước và ghi token mới vào kho.
          store.tokens = _tokens('NEW', 'R2');
          return _err(401, 'REFRESH_TOKEN_INVALID');
        }
        return o.headers['Authorization'] == 'Bearer NEW'
            ? _ok({'ok': true})
            : _err(401, 'TOKEN_EXPIRED');
      });
      client = build(adapter);
      client.sessionExpired.listen((_) => sessionExpiredCount++);

      expect(await client.get('/me'), {'ok': true});
      await Future<void>.delayed(Duration.zero);
      expect(sessionExpiredCount, 0);
      expect(store.tokens!.refreshToken, 'R2');
    },
  );

  // --- Hợp đồng server S1–S4 ---------------------------------------------------

  test('UNAUTHENTICATED (token hỏng) → refresh 1 lần rồi thử lại', () async {
    store.tokens = _tokens('BAD', 'R1');
    final adapter = _FakeAdapter((o) {
      if (o.path == '/auth/refresh') {
        return _ok({'tokens': _tokensJson('GOOD', 'R2')});
      }
      return o.headers['Authorization'] == 'Bearer GOOD'
          ? _ok({'ok': true})
          : _err(401, 'UNAUTHENTICATED');
    });
    client = build(adapter);

    expect(await client.get('/me'), {'ok': true});
    expect(adapter.count('/auth/refresh'), 1);
    expect(store.tokens!.refreshToken, 'R2');
  });

  test(
    'tài khoản đã bị xóa (access → UNAUTHENTICATED, refresh → REFRESH_TOKEN_INVALID) → xóa phiên',
    () async {
      store.tokens = _tokens('OLD', 'R1');
      final adapter = _FakeAdapter(
        (o) => o.path == '/auth/refresh'
            ? _err(401, 'REFRESH_TOKEN_INVALID')
            : _err(401, 'UNAUTHENTICATED'),
      );
      client = build(adapter);
      final expired = client.sessionExpired.first;

      await expectLater(
        client.get('/me'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            ApiErrorCode.unauthenticated,
          ),
        ),
      );
      await expired.timeout(const Duration(seconds: 1));
      expect(store.tokens, isNull);
    },
  );

  test('UNAUTHENTICATED lặp lại sau refresh không gây vòng lặp', () async {
    store.tokens = _tokens('OLD', 'R1');
    final adapter = _FakeAdapter(
      (o) => o.path == '/auth/refresh'
          ? _ok({'tokens': _tokensJson('NEW', 'R2')})
          : _err(401, 'UNAUTHENTICATED'),
    );
    client = build(adapter);

    await expectLater(
      client.get('/me'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          ApiErrorCode.unauthenticated,
        ),
      ),
    );
    expect(adapter.count('/me'), 2);
    expect(adapter.count('/auth/refresh'), 1);
  });

  test(
    'endpoint công khai (authenticated=false) không bao giờ kích hoạt refresh',
    () async {
      store.tokens = _tokens('OLD', 'R1');
      final adapter = _FakeAdapter((_) => _err(401, 'INVALID_CREDENTIALS'));
      client = build(adapter);

      await expectLater(
        client.post(
          '/auth/login',
          body: {'identifier': 'a', 'password': 'b'},
          authenticated: false,
        ),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            ApiErrorCode.invalidCredentials,
          ),
        ),
      );
      expect(adapter.count('/auth/refresh'), 0);
      expect(store.tokens, isNotNull); // đăng nhập sai không được xóa phiên cũ
    },
  );

  test('IDENTIFIER_TAKEN và RATE_LIMITED map đúng mã và HTTP status', () async {
    client = build(
      _FakeAdapter(
        (o) => o.path == '/auth/register'
            ? _err(409, 'IDENTIFIER_TAKEN')
            : _err(429, 'RATE_LIMITED'),
      ),
    );
    await expectLater(
      client.post('/auth/register', body: {}, authenticated: false),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', ApiErrorCode.identifierTaken)
            .having((e) => e.httpStatus, 'http', 409),
      ),
    );
    await expectLater(
      client.post('/auth/login', body: {}, authenticated: false),
      throwsA(
        isA<ApiException>()
            .having((e) => e.code, 'code', ApiErrorCode.rateLimited)
            .having((e) => e.httpStatus, 'http', 429),
      ),
    );
  });

  test('DELETE /me gửi kèm body {password} (xóa tài khoản)', () async {
    store.tokens = _tokens('A1', 'R1');
    final adapter = _FakeAdapter((_) => _ok({}));
    client = build(adapter);

    expect(await client.delete('/me', body: {'password': 'secret12'}), isEmpty);
    final call = adapter.calls.single;
    expect(call.method, 'DELETE');
    expect(call.data, {'password': 'secret12'});
    expect(call.headers['Authorization'], 'Bearer A1');
  });

  test('GET kèm query (vd. /journeys/:id?date=)', () async {
    final adapter = _FakeAdapter((_) => _ok({}));
    client = build(adapter);
    await client.get('/journeys/abc', query: {'date': '2026-11-08'});
    expect(adapter.calls.single.queryParameters, {'date': '2026-11-08'});
  });

  test('chỉ thử lại 1 lần: TOKEN_EXPIRED lặp lại không gây vòng lặp', () async {
    store.tokens = _tokens('OLD', 'R1');
    final adapter = _FakeAdapter(
      (o) => o.path == '/auth/refresh'
          ? _ok({'tokens': _tokensJson('NEW', 'R2')})
          : _err(401, 'TOKEN_EXPIRED'),
    );
    client = build(adapter);

    await expectLater(
      client.get('/me'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.code,
          'code',
          ApiErrorCode.tokenExpired,
        ),
      ),
    );
    expect(adapter.count('/me'), 2);
    expect(adapter.count('/auth/refresh'), 1);
  });
}
