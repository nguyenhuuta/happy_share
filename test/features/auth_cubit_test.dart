import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happy_share/core/network/api_exception.dart';
import 'package:happy_share/core/session/session_state.dart';
import 'package:happy_share/core/utils/submit_state.dart';
import 'package:happy_share/features/auth/presentation/cubit/auth_cubit.dart';

import '../helpers/fakes.dart';

void main() {
  late Reply Function() onLogin;
  late Reply Function() onRegister;
  late Reply Function() onMe;
  late Harness h;
  late AuthCubit cubit;
  late List<SubmitState<void>> states;

  Reply authOk() => ok({'user': userJson(), 'tokens': tokensJson('A1', 'R1')});

  setUp(() {
    onLogin = authOk;
    onRegister = authOk;
    onMe = () => ok(meJson(withFamily: false));
    h = Harness(
      FakeAdapter((o) {
        switch (o.path) {
          case '/auth/login':
            return onLogin();
          case '/auth/register':
            return onRegister();
          case '/me':
            return onMe();
        }
        return ok({});
      }),
    );
    cubit = AuthCubit(h.auth, h.session);
    states = [];
    cubit.stream.listen(states.add);
  });

  tearDown(() async {
    await cubit.close();
    await h.dispose();
  });

  group('đăng nhập', () {
    test(
      'thành công: submitting → success, token được lưu, phiên chuyển sang consentIntro (nhóm là tùy chọn)',
      () async {
        await cubit.login(identifier: 'mai.tran', password: 'matkhau123');
        expect(states.map((s) => s.status), [
          SubmitStatus.submitting,
          SubmitStatus.success,
        ]);
        expect(h.store.tokens!.refreshToken, 'R1');
        expect(h.session.state.status, SessionStatus.consentIntro);
      },
    );

    test('thiếu dữ liệu: báo lỗi từng trường, KHÔNG gọi API', () async {
      await cubit.login(identifier: '  ', password: '');
      expect(h.adapter.calls, isEmpty);
      final s = cubit.state;
      expect(s.status, SubmitStatus.failure);
      expect(s.fieldErrors, {
        'identifier': ['required'],
        'password': ['required'],
      });
      expect(s.error, ApiErrorCode.validationError);
    });

    test(
      'sai tài khoản/mật khẩu: lỗi tổng quát, không có lỗi theo trường, không lưu token',
      () async {
        onLogin = () => apiError(401, 'INVALID_CREDENTIALS');
        await cubit.login(identifier: 'a', password: 'b');
        expect(cubit.state.status, SubmitStatus.failure);
        expect(cubit.state.error, ApiErrorCode.invalidCredentials);
        expect(cubit.state.fieldErrors, isEmpty);
        expect(h.store.tokens, isNull);
        expect(
          h.session.state.status,
          SessionStatus.initializing,
        ); // chưa đổi gì
      },
    );

    test('bị khóa tạm (429) → RATE_LIMITED', () async {
      onLogin = () => apiError(429, 'RATE_LIMITED');
      await cubit.login(identifier: 'a', password: 'b');
      expect(cubit.state.error, ApiErrorCode.rateLimited);
    });

    test('mất mạng → networkError, có thể bấm lại', () async {
      final offline = Harness(
        FakeAdapter(
          (o) => throw DioException(
            requestOptions: o,
            type: DioExceptionType.connectionError,
          ),
        ),
      );
      final c = AuthCubit(offline.auth, offline.session);
      await c.login(identifier: 'a', password: 'b');
      expect(c.state.error, ApiErrorCode.networkError);
      expect(c.state.isSubmitting, isFalse);
      await c.close();
      await offline.dispose();
    });

    test('bấm đúp khi đang gửi chỉ gửi MỘT request', () async {
      await Future.wait([
        cubit.login(identifier: 'mai', password: 'matkhau123'),
        cubit.login(identifier: 'mai', password: 'matkhau123'),
      ]);
      expect(h.adapter.count('/auth/login'), 1);
    });

    test(
      'đăng nhập xong nhưng /me lỗi mạng: form vẫn là success, phiên sang failure (màn chờ + thử lại)',
      () async {
        onMe = () => apiError(500, 'INTERNAL_ERROR');
        await cubit.login(identifier: 'mai', password: 'matkhau123');
        expect(cubit.state.status, SubmitStatus.success);
        expect(h.session.state.status, SessionStatus.failure);
        expect(h.store.tokens, isNotNull);
      },
    );

    test('clearErrors đưa form về trạng thái ban đầu', () async {
      onLogin = () => apiError(401, 'INVALID_CREDENTIALS');
      await cubit.login(identifier: 'a', password: 'b');
      cubit.clearErrors();
      expect(cubit.state, const SubmitState<void>());
    });
  });

  group('đăng ký', () {
    test('thành công', () async {
      await cubit.register(
        identifier: '0912345678',
        password: 'matkhau123',
        displayName: 'Mẹ',
      );
      expect(cubit.state.status, SubmitStatus.success);
      expect(h.adapter.to('/auth/register').single.data, {
        'identifier': '0912345678',
        'password': 'matkhau123',
        'display_name': 'Mẹ',
      });
      expect(h.session.state.status, SessionStatus.consentIntro);
    });

    test(
      'mật khẩu ngắn + thiếu tên: lỗi cục bộ theo trường, không gọi API',
      () async {
        await cubit.register(
          identifier: 'mai',
          password: '1234567',
          displayName: ' ',
        );
        expect(h.adapter.calls, isEmpty);
        expect(cubit.state.fieldErrors, {
          'display_name': ['required'],
          'password': ['minLength'],
        });
      },
    );

    test('IDENTIFIER_TAKEN', () async {
      onRegister = () => apiError(409, 'IDENTIFIER_TAKEN');
      await cubit.register(
        identifier: 'mai',
        password: 'matkhau123',
        displayName: 'Mẹ',
      );
      expect(cubit.state.error, ApiErrorCode.identifierTaken);
      expect(h.store.tokens, isNull);
    });

    test(
      'VALIDATION_ERROR của server (identifier sai định dạng) → lỗi gắn đúng trường',
      () async {
        onRegister = () => apiError(
          400,
          'VALIDATION_ERROR',
          details: {
            'fields': {
              'identifier': ['invalidIdentifier'],
            },
          },
        );
        await cubit.register(
          identifier: '1ab',
          password: 'matkhau123',
          displayName: 'Mẹ',
        );
        expect(cubit.state.error, ApiErrorCode.validationError);
        expect(cubit.state.fieldErrors, {
          'identifier': ['invalidIdentifier'],
        });
      },
    );
  });
}
