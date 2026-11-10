import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happy_share/app.dart';
import 'package:happy_share/core/session/session_state.dart';

import '../helpers/fakes.dart';

void main() {
  testWidgets(
    'luồng vào app: splash → đăng nhập → giới thiệu ghi lại hành trình → shell (nhóm là tùy chọn) → đăng xuất',
    (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('vi')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      var meResponse = ok(meJson(withFamily: false));
      final h = Harness(
        FakeAdapter((o) {
          switch (o.path) {
            case '/me':
              return meResponse;
            case '/auth/login':
              return ok({'user': userJson(), 'tokens': tokensJson('A1', 'R1')});
          }
          return ok({});
        }),
      );
      addTearDown(h.dispose);

      // Future thật (FakeAdapter/Dio) không chạy trong FakeAsync của widget test → dùng runAsync.
      Future<void> settle() async {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 30)),
        );
        await tester.pumpAndSettle();
      }

      Finder appBarTitle(String text) => find.widgetWithText(AppBar, text);

      await tester.pumpWidget(HappyShareApp(session: h.session));
      await tester.pump();
      // Chưa start(): đang khởi tạo → màn chờ.
      expect(h.session.state.status, SessionStatus.initializing);
      expect(appBarTitle('Happy Share'), findsOneWidget);

      // Không có token → màn đăng nhập.
      await tester.runAsync(h.session.start);
      await tester.pumpAndSettle();
      expect(appBarTitle('Đăng nhập'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      // Đăng nhập (chưa có nhóm, chưa bật ghi nhận) → màn giới thiệu ghi lại hành trình. Nhóm là
      // tùy chọn nên KHÔNG bị ép tạo/tham gia nhóm trước.
      await tester.runAsync(() async {
        await h.auth.login(identifier: 'mai.tran', password: 'matkhau123');
        await h.session.refreshMe();
      });
      await settle();
      expect(appBarTitle('Ghi lại hành trình'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      // Có nhóm mà vẫn chưa bật ghi nhận → vẫn ở màn giới thiệu; không vào được shell dù có deep link.
      meResponse = ok(meJson());
      await tester.runAsync(h.session.refreshMe);
      await settle();
      expect(appBarTitle('Ghi lại hành trình'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);

      // "Để sau" → shell 5 tab.
      h.session.skipConsentIntro();
      await settle();
      expect(find.byType(NavigationBar), findsOneWidget);

      // Đăng xuất → quay lại đăng nhập, shell biến mất.
      await tester.runAsync(h.session.signOut);
      await settle();
      expect(appBarTitle('Đăng nhập'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(h.store.tokens, isNull);
    },
  );

  testWidgets(
    'đã đồng ý chia sẻ thì vào thẳng shell; hết phiên giữa chừng đá về đăng nhập',
    (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('vi')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      var expired = false;
      final h = Harness(
        FakeAdapter((o) {
          if (o.path == '/me') return ok(meJson(consentStatus: 'granted'));
          if (o.path == '/auth/refresh') {
            return apiError(401, 'REFRESH_TOKEN_INVALID');
          }
          return expired ? apiError(401, 'TOKEN_EXPIRED') : ok({});
        }),
        tokens: tokensOf('A1', 'R1'),
      );
      addTearDown(h.dispose);

      await tester.pumpWidget(HappyShareApp(session: h.session));
      await tester.runAsync(h.session.start);
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);

      // Một request bất kỳ phát hiện refresh token bị từ chối → xóa phiên → về đăng nhập.
      expired = true;
      await tester.runAsync(() async {
        try {
          await h.api.get('/anything');
        } on Object {
          // lỗi dự kiến
        }
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Đăng nhập'), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    },
  );
}
