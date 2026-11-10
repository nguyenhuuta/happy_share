import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happy_share/app.dart';

void main() {
  testWidgets('hiển thị shell 5 tab và chuyển tab được', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('vi')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const HappyShareApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    Finder navLabel(String label) => find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(label),
    );
    for (final label in [
      'Nhóm',
      'Hành trình',
      'Địa điểm',
      'Thành viên',
      'Cài đặt',
    ]) {
      expect(navLabel(label), findsOneWidget);
    }

    await tester.tap(navLabel('Cài đặt'));
    await tester.pumpAndSettle();
    expect(find.text('Sắp có'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Cài đặt'), findsOneWidget);
  });
}
