import 'package:flutter_test/flutter_test.dart';
import 'package:happy_share/core/constants/domain_enums.dart';
import 'package:happy_share/core/network/api_exception.dart';
import 'package:happy_share/core/session/session_state.dart';

import '../helpers/fakes.dart';

void main() {
  /// `/me` trả theo [me]; mọi đường dẫn khác trả `{}`.
  Harness harness(Reply Function() me, {bool withTokens = true}) => Harness(
    FakeAdapter((o) {
      if (o.path == '/me') return me();
      if (o.path == '/auth/refresh') {
        return apiError(401, 'REFRESH_TOKEN_INVALID');
      }
      return ok({});
    }),
    tokens: withTokens ? tokensOf('A1', 'R1') : null,
  );

  group('start()', () {
    test('không có token → unauthenticated, KHÔNG gọi API', () async {
      final h = harness(() => ok(meJson()), withTokens: false);
      await h.session.start();
      expect(h.session.state.status, SessionStatus.unauthenticated);
      expect(h.adapter.calls, isEmpty);
    });

    test('trạng thái ban đầu là initializing', () {
      expect(
        harness(() => ok(meJson())).session.state.status,
        SessionStatus.initializing,
      );
    });

    test(
      'chưa có nhóm, chưa bật ghi nhận → consentIntro (nhóm là tùy chọn, D15)',
      () async {
        final h = harness(() => ok(meJson(withFamily: false)));
        await h.session.start();
        expect(h.session.state.status, SessionStatus.consentIntro);
        expect(h.session.state.families, isEmpty);
        expect(h.session.state.activeFamily, isNull);
        expect(h.session.state.me!.consent.status, isNull);
      },
    );

    test(
      'chưa có nhóm nhưng đã bật ghi nhận → ready (dùng được nhật ký cá nhân)',
      () async {
        final h = harness(
          () => ok(meJson(withFamily: false, consentStatus: 'granted')),
        );
        await h.session.start();
        expect(h.session.state.status, SessionStatus.ready);
        expect(h.session.state.activeFamily, isNull);
      },
    );

    test('có nhóm, chưa từng bật ghi nhận → consentIntro', () async {
      final h = harness(() => ok(meJson()));
      await h.session.start();
      expect(h.session.state.status, SessionStatus.consentIntro);
    });

    test('đã tắt ghi nhận → consentIntro (phải bật lại)', () async {
      final h = harness(() => ok(meJson(consentStatus: 'revoked')));
      await h.session.start();
      expect(h.session.state.status, SessionStatus.consentIntro);
    });

    test('granted và paused → ready', () async {
      for (final s in ['granted', 'paused']) {
        final h = harness(() => ok(meJson(consentStatus: s)));
        await h.session.start();
        expect(h.session.state.status, SessionStatus.ready, reason: s);
        expect(
          h.session.state.me!.consent.status,
          s == 'granted' ? ConsentStatus.granted : ConsentStatus.paused,
        );
      }
    });

    test(
      'consent status lạ (server mới hơn app) → coi như chưa bật, không crash',
      () async {
        final h = harness(() => ok(meJson(consentStatus: 'quantum')));
        await h.session.start();
        expect(h.session.state.status, SessionStatus.consentIntro);
      },
    );
  });

  group('consentIntro "Để sau"', () {
    test('skip → ready; cờ được giữ khi làm mới /me', () async {
      final h = harness(() => ok(meJson()));
      await h.session.start();
      h.session.skipConsentIntro();
      expect(h.session.state.status, SessionStatus.ready);
      expect(h.session.state.consentIntroSkipped, isTrue);

      await h.session.refreshMe();
      expect(h.session.state.status, SessionStatus.ready);
    });

    test('skip khi không ở consentIntro không đổi trạng thái', () async {
      final h = harness(
        () => ok(meJson(withFamily: false, consentStatus: 'granted')),
      );
      await h.session.start();
      h.session.skipConsentIntro();
      expect(h.session.state.status, SessionStatus.ready);
    });

    test('đồng ý xong (granted) thì ready, dù đã skip trước đó', () async {
      var consent = 'none';
      final h = harness(() => ok(meJson(consentStatus: consent)));
      await h.session.start();
      h.session.skipConsentIntro();
      consent = 'granted';
      await h.session.refreshMe();
      expect(h.session.state.status, SessionStatus.ready);
    });
  });

  group('lỗi khi gọi /me', () {
    test(
      'lỗi mạng lúc mở app (chưa có dữ liệu) → failure, giữ token để thử lại',
      () async {
        var online = false;
        final h = harness(
          () => online ? ok(meJson()) : apiError(503, 'INTERNAL_ERROR'),
        );
        await h.session.start();
        expect(h.session.state.status, SessionStatus.failure);
        expect(h.session.state.error, ApiErrorCode.internalError);
        expect(h.store.tokens, isNotNull);

        online = true;
        await h.session.refreshMe(); // nút "Thử lại"
        expect(h.session.state.status, SessionStatus.consentIntro);
        expect(h.session.state.error, isNull);
      },
    );

    test(
      'lỗi mạng khi ĐÃ có dữ liệu → giữ nguyên màn hình, chỉ gắn error (không đá ra ngoài)',
      () async {
        var online = true;
        final h = harness(
          () => online
              ? ok(meJson(consentStatus: 'granted'))
              : apiError(500, 'INTERNAL_ERROR'),
        );
        await h.session.start();
        expect(h.session.state.status, SessionStatus.ready);

        online = false;
        await h.session.refreshMe();
        expect(h.session.state.status, SessionStatus.ready);
        expect(h.session.state.me, isNotNull);
        expect(h.session.state.error, ApiErrorCode.internalError);
        expect(h.store.tokens, isNotNull);
      },
    );

    test('UNAUTHENTICATED dai dẳng → đăng xuất cục bộ', () async {
      final h = harness(() => apiError(401, 'UNAUTHENTICATED'));
      await h.session.start();
      expect(h.session.state.status, SessionStatus.unauthenticated);
      expect(h.store.tokens, isNull);
      expect(h.cleaner.clearAllCalls, greaterThanOrEqualTo(1));
    });

    test(
      'TOKEN_EXPIRED + refresh bị từ chối (hết phiên) → unauthenticated, KHÔNG kẹt ở failure',
      () async {
        final h = harness(() => apiError(401, 'TOKEN_EXPIRED'));
        await h.session.start();
        await Future<void>.delayed(
          const Duration(milliseconds: 20),
        ); // cho listener sessionExpired chạy
        expect(h.session.state.status, SessionStatus.unauthenticated);
        expect(h.store.tokens, isNull);
        expect(h.session.state.me, isNull);
      },
    );
  });

  group('mất/rời nhóm và ghi nhận bị tắt', () {
    test(
      '/me từng có nhóm, nay không còn → KHÔNG dọn dữ liệu vị trí, vẫn ready (ghi nhận là của tài khoản)',
      () async {
        var inFamily = true;
        final h = harness(
          () => ok(meJson(consentStatus: 'granted', withFamily: inFamily)),
        );
        await h.session.start();
        expect(h.session.state.activeFamily, isNotNull);

        inFamily = false; // bị chủ nhóm xóa / đã rời ở máy khác
        await h.session.refreshMe();
        expect(h.session.state.status, SessionStatus.ready);
        expect(h.session.state.activeFamily, isNull);
        expect(h.cleaner.clearLocationCalls, 0);
        expect(h.store.tokens, isNotNull);
      },
    );

    test(
      'ghi nhận bị tắt từ máy khác (granted → revoked) → dọn dữ liệu vị trí cục bộ, về consentIntro',
      () async {
        var consent = 'granted';
        final h = harness(() => ok(meJson(consentStatus: consent)));
        await h.session.start();
        expect(h.cleaner.clearLocationCalls, 0);

        consent = 'revoked';
        await h.session.refreshMe();
        expect(h.session.state.status, SessionStatus.consentIntro);
        expect(h.cleaner.clearLocationCalls, 1);
        expect(h.store.tokens, isNotNull);
      },
    );

    test('chưa từng bật ghi nhận thì không dọn gì', () async {
      final h = harness(() => ok(meJson(withFamily: false)));
      await h.session.start();
      await h.session.refreshMe();
      expect(h.cleaner.clearLocationCalls, 0);
    });
  });

  group('nhiều nhóm: nhóm đang xem', () {
    Map<String, dynamic> twoFamilies() {
      final json = meJson(consentStatus: 'granted');
      final second = {
        'family': {...familyJson(), 'id': 'f2', 'name': 'Hội bạn thân'},
        'member': {...memberJson(), 'member_id': 'm2'},
      };
      (json['families'] as List).add(second);
      return json;
    }

    test(
      'mặc định là nhóm đầu tiên; selectFamily đổi nhóm và giữ khi làm mới /me',
      () async {
        final h = harness(() => ok(twoFamilies()));
        await h.session.start();
        expect(h.session.state.families.map((f) => f.family.id), ['f1', 'f2']);
        expect(h.session.state.activeFamily!.family.id, 'f1');

        h.session.selectFamily('f2');
        expect(h.session.state.activeFamily!.family.name, 'Hội bạn thân');
        await h.session.refreshMe();
        expect(h.session.state.activeFamily!.family.id, 'f2');
      },
    );

    test(
      'selectFamily với nhóm không thuộc mình bị bỏ qua; nhóm đang xem biến mất → quay về nhóm đầu',
      () async {
        var both = true;
        final h = harness(
          () => ok(both ? twoFamilies() : meJson(consentStatus: 'granted')),
        );
        await h.session.start();
        h.session.selectFamily('khong-co');
        expect(h.session.state.activeFamily!.family.id, 'f1');

        h.session.selectFamily('f2');
        both = false; // rời nhóm f2
        await h.session.refreshMe();
        expect(h.session.state.activeFamily!.family.id, 'f1');
      },
    );
  });

  group('đăng xuất / hết phiên', () {
    test(
      'signOut: gọi API logout, dọn sạch, về unauthenticated và reset cờ "Để sau"',
      () async {
        final h = harness(() => ok(meJson()));
        await h.session.start();
        h.session.skipConsentIntro();

        await h.session.signOut();

        expect(h.adapter.to('/auth/logout').single.data, {
          'refresh_token': 'R1',
        });
        expect(
          h.session.state,
          const SessionState(status: SessionStatus.unauthenticated),
        );
        expect(h.session.state.consentIntroSkipped, isFalse);
        expect(h.store.tokens, isNull);
      },
    );

    test(
      'đăng nhập lại sau khi đăng xuất: không còn dữ liệu của phiên trước',
      () async {
        final h = harness(() => ok(meJson(consentStatus: 'granted')));
        await h.session.start();
        await h.session.signOut();
        expect(h.session.state.me, isNull);
      },
    );

    test(
      'refresh bị từ chối ở request bất kỳ (sessionExpired) → unauthenticated',
      () async {
        final h = Harness(
          FakeAdapter((o) {
            if (o.path == '/me') return ok(meJson(consentStatus: 'granted'));
            if (o.path == '/auth/refresh') {
              return apiError(401, 'REFRESH_TOKEN_INVALID');
            }
            return apiError(401, 'TOKEN_EXPIRED');
          }),
          tokens: tokensOf('A1', 'R1'),
        );
        await h.session.start();
        expect(h.session.state.status, SessionStatus.ready);

        await expectLater(h.api.get('/anything'), throwsA(isA<ApiException>()));
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(h.session.state.status, SessionStatus.unauthenticated);
        expect(h.store.tokens, isNull);
      },
    );
  });
}
