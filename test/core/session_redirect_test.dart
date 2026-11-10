import 'package:flutter_test/flutter_test.dart';
import 'package:happy_share/core/router/app_routes.dart';
import 'package:happy_share/core/router/session_redirect.dart';
import 'package:happy_share/core/session/session_state.dart';

void main() {
  String? r(SessionStatus s, String loc) => sessionRedirect(s, loc);

  group('initializing / failure → luôn về màn chờ', () {
    for (final s in [SessionStatus.initializing, SessionStatus.failure]) {
      test('$s', () {
        expect(r(s, AppRoutes.family), AppRoutes.splash);
        expect(r(s, AppRoutes.login), AppRoutes.splash);
        expect(r(s, AppRoutes.splash), isNull);
      });
    }
  });

  group('unauthenticated → chỉ được ở đăng nhập / đăng ký', () {
    const s = SessionStatus.unauthenticated;
    test('cho phép', () {
      expect(r(s, AppRoutes.login), isNull);
      expect(r(s, AppRoutes.register), isNull);
    });
    test('mọi nơi khác về đăng nhập (kể cả deep link vào tab)', () {
      for (final loc in [
        AppRoutes.splash,
        AppRoutes.family,
        AppRoutes.members,
        AppRoutes.familySetup,
        AppRoutes.consentIntro,
        '/journey/abc',
      ]) {
        expect(r(s, loc), AppRoutes.login, reason: loc);
      }
    });
  });

  group('consentIntro → chỉ được ở màn giới thiệu ghi lại hành trình', () {
    const s = SessionStatus.consentIntro;
    test('cho phép', () => expect(r(s, AppRoutes.consentIntro), isNull));
    test('mọi nơi khác về màn giới thiệu', () {
      for (final loc in [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.family,
        AppRoutes.familySetup,
      ]) {
        expect(r(s, loc), AppRoutes.consentIntro, reason: loc);
      }
    });
  });

  group('ready → vào shell; các màn trước-shell không còn ý nghĩa', () {
    const s = SessionStatus.ready;
    test('đang ở tab thì giữ nguyên', () {
      for (final loc in [
        AppRoutes.family,
        AppRoutes.journey,
        AppRoutes.places,
        AppRoutes.members,
        AppRoutes.settings,
      ]) {
        expect(r(s, loc), isNull, reason: loc);
      }
    });
    test('đang ở màn trước-shell thì chuyển về tab Nhóm', () {
      for (final loc in [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.consentIntro,
      ]) {
        expect(r(s, loc), AppRoutes.family, reason: loc);
      }
    });
    test(
      'luồng tạo/tham gia nhóm dùng được bất cứ lúc nào (có thể ở nhiều nhóm)',
      () {
        for (final loc in [
          AppRoutes.familySetup,
          AppRoutes.familyCreate,
          AppRoutes.familyJoin,
        ]) {
          expect(r(s, loc), isNull, reason: loc);
        }
      },
    );
    test(
      '"Để sau" / đồng ý xong (consentIntro → ready) tự rời màn giới thiệu, không kẹt lại',
      () {
        // Đang ở /consent-intro, trạng thái chuyển sang ready ⇒ phải được đưa vào shell.
        expect(r(SessionStatus.consentIntro, AppRoutes.consentIntro), isNull);
        expect(
          r(SessionStatus.ready, AppRoutes.consentIntro),
          AppRoutes.family,
        );
      },
    );
  });

  test('không nhầm tiền tố: "/login-help" không phải "/login"', () {
    expect(r(SessionStatus.unauthenticated, '/login-help'), AppRoutes.login);
    expect(r(SessionStatus.ready, '/family-setup-x'), isNull);
  });

  test('mọi trạng thái đều xử lý (không rơi khỏi switch)', () {
    for (final s in SessionStatus.values) {
      expect(() => r(s, '/anything'), returnsNormally);
    }
  });
}
