import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happy_share/core/constants/domain_enums.dart';
import 'package:happy_share/core/network/api_exception.dart';

import '../helpers/fakes.dart';

Reply _authOk({
  String access = 'A1',
  String refresh = 'R1',
  String type = 'username',
}) => ok({'user': userJson(type: type), 'tokens': tokensJson(access, refresh)});

void main() {
  group('đăng nhập / đăng ký', () {
    test(
      'login: gửi identifier đã trim, KHÔNG gắn Bearer, lưu token và trả user',
      () async {
        final h = Harness(FakeAdapter((_) => _authOk()), tokens: null);
        final user = await h.auth.login(
          identifier: '  Mai.Tran  ',
          password: 'matkhau123',
        );

        final call = h.adapter.calls.single;
        expect(call.path, '/auth/login');
        expect(call.data, {
          'identifier': 'Mai.Tran',
          'password': 'matkhau123',
        }); // không tự chuẩn hóa
        expect(call.headers.containsKey('Authorization'), isFalse);
        expect(user.identifierType, IdentifierType.username);
        expect(h.store.tokens!.accessToken, 'A1');
        expect(h.store.tokens!.refreshToken, 'R1');
      },
    );

    test('register: gửi display_name đã trim, mật khẩu nguyên văn', () async {
      final h = Harness(FakeAdapter((_) => _authOk(type: 'phone')));
      final user = await h.auth.register(
        identifier: '+84 912 345 678',
        password: '  có khoảng trắng  ',
        displayName: '  Mẹ  ',
      );
      expect(h.adapter.calls.single.path, '/auth/register');
      expect(h.adapter.calls.single.data, {
        'identifier': '+84 912 345 678', // server chuẩn hóa, mobile không đoán
        'password': '  có khoảng trắng  ', // mật khẩu không bị trim
        'display_name': 'Mẹ',
      });
      expect(user.identifierType, IdentifierType.phone);
    });

    test(
      'đăng nhập dọn dữ liệu của phiên trước TRƯỚC khi ghi token mới',
      () async {
        final h = Harness(
          FakeAdapter((_) => _authOk(access: 'NEW', refresh: 'RNEW')),
          tokens: tokensOf('OLD', 'ROLD'),
        );
        await h.auth.login(identifier: 'a', password: 'password1');
        expect(h.cleaner.clearAllCalls, 1);
        expect(
          h.store.tokens!.accessToken,
          'NEW',
        ); // clearAll không xóa token mới
      },
    );

    test(
      'đăng nhập sai: ném INVALID_CREDENTIALS, không đụng token/dữ liệu cũ',
      () async {
        final h = Harness(
          FakeAdapter((_) => apiError(401, 'INVALID_CREDENTIALS')),
          tokens: tokensOf('OLD', 'ROLD'),
        );
        await expectLater(
          h.auth.login(identifier: 'a', password: 'b'),
          throwsA(
            isA<ApiException>().having(
              (e) => e.code,
              'code',
              ApiErrorCode.invalidCredentials,
            ),
          ),
        );
        expect(h.store.tokens!.accessToken, 'OLD');
        expect(h.cleaner.clearAllCalls, 0);
      },
    );

    test(
      'IDENTIFIER_TAKEN / RATE_LIMITED / VALIDATION_ERROR được giữ nguyên mã và fields',
      () async {
        final codes = <String, ApiErrorCode>{
          'IDENTIFIER_TAKEN': ApiErrorCode.identifierTaken,
          'RATE_LIMITED': ApiErrorCode.rateLimited,
        };
        for (final e in codes.entries) {
          final h = Harness(FakeAdapter((_) => apiError(409, e.key)));
          await expectLater(
            h.auth.register(
              identifier: 'a',
              password: 'password1',
              displayName: 'x',
            ),
            throwsA(isA<ApiException>().having((x) => x.code, 'code', e.value)),
          );
        }
        final h = Harness(
          FakeAdapter(
            (_) => apiError(
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
          h.auth.register(
            identifier: '1ab',
            password: 'password1',
            displayName: 'x',
          ),
          throwsA(
            isA<ApiException>().having((x) => x.fieldErrors, 'fields', {
              'identifier': ['invalidIdentifier'],
            }),
          ),
        );
      },
    );

    test('phản hồi sai định dạng: lỗi chung, KHÔNG lưu token', () async {
      final h = Harness(FakeAdapter((_) => ok({'user': 'oops'})));
      await expectLater(
        h.auth.login(identifier: 'a', password: 'b'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.code,
            'code',
            ApiErrorCode.unknown,
          ),
        ),
      );
      expect(h.store.tokens, isNull);
    });
  });

  group('đăng xuất', () {
    test(
      'gửi refresh token hiện tại (kèm Bearer) rồi dọn sạch cục bộ',
      () async {
        final h = Harness(
          FakeAdapter((_) => ok({})),
          tokens: tokensOf('A1', 'R1'),
        );
        await h.auth.logout();

        final call = h.adapter.calls.single;
        expect(call.path, '/auth/logout');
        expect(call.data, {'refresh_token': 'R1'});
        expect(call.headers['Authorization'], 'Bearer A1');
        expect(h.store.tokens, isNull);
        expect(h.cleaner.clearAllCalls, 1);
      },
    );

    test(
      'mất mạng khi đăng xuất: vẫn xóa token và dữ liệu cục bộ, không ném',
      () async {
        final h = Harness(
          FakeAdapter(
            (o) => throw DioException(
              requestOptions: o,
              type: DioExceptionType.connectionError,
            ),
          ),
          tokens: tokensOf('A1', 'R1'),
        );
        await h.auth.logout();
        expect(h.store.tokens, isNull);
        expect(h.cleaner.clearAllCalls, 1);
      },
    );

    test('server lỗi 5xx khi đăng xuất: vẫn dọn sạch cục bộ', () async {
      final h = Harness(
        FakeAdapter((_) => apiError(500, 'INTERNAL_ERROR')),
        tokens: tokensOf('A1', 'R1'),
      );
      await h.auth.logout();
      expect(h.store.tokens, isNull);
      expect(h.cleaner.clearAllCalls, 1);
    });

    test('không có token: không gọi API nhưng vẫn dọn cục bộ', () async {
      final h = Harness(FakeAdapter((_) => ok({})));
      await h.auth.logout();
      expect(h.adapter.calls, isEmpty);
      expect(h.cleaner.clearAllCalls, 1);
    });

    test(
      'access hết hạn giữa chừng → refresh xoay token → gửi lại logout với refresh token MỚI',
      () async {
        final h = Harness(
          FakeAdapter((o) {
            if (o.path == '/auth/refresh') {
              return ok({'tokens': tokensJson('A2', 'R2')});
            }
            if (o.path == '/auth/logout') {
              // Lần đầu (Bearer A1) hết hạn; sau khi refresh (Bearer A2) thì chấp nhận.
              return o.headers['Authorization'] == 'Bearer A2'
                  ? ok({})
                  : apiError(401, 'TOKEN_EXPIRED');
            }
            return ok({});
          }),
          tokens: tokensOf('A1', 'R1'),
        );

        await h.auth.logout();

        final bodies = h.adapter
            .to('/auth/logout')
            .map((c) => c.data['refresh_token'])
            .toList();
        // R1 (bị từ chối) → R1 (thử lại tự động) → R2 (token mới sau khi xoay vòng).
        expect(bodies, ['R1', 'R1', 'R2']);
        expect(h.adapter.count('/auth/refresh'), 1);
        expect(h.store.tokens, isNull);
        expect(h.cleaner.clearAllCalls, 1);
      },
    );

    test('clearLocalSession chỉ dọn cục bộ, không gọi API', () async {
      final h = Harness(
        FakeAdapter((_) => ok({})),
        tokens: tokensOf('A1', 'R1'),
      );
      await h.auth.clearLocalSession();
      expect(h.adapter.calls, isEmpty);
      expect(h.store.tokens, isNull);
    });
  });
}
