import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Từ cấm của sản phẩm (CLAUDE.md B5 + Design System): app KHÔNG theo dõi liên tục / giám sát,
/// và không hứa hẹn "real-time" vì hệ điều hành không đảm bảo. Dùng "Hành trình", "Nhật ký",
/// "Điểm đến", "Chia sẻ tự nguyện".
const _forbidden = [
  'real-time',
  'realtime',
  'real time',
  'giám sát',
  'theo dõi liên tục',
  'tracking',
  'live location',
];

void main() {
  for (final file in ['lib/core/l10n/app_vi.arb', 'lib/core/l10n/app_en.arb']) {
    test('$file không chứa từ cấm', () {
      final json =
          jsonDecode(File(file).readAsStringSync()) as Map<String, dynamic>;
      final hits = <String>[];
      for (final e in json.entries.where((e) => !e.key.startsWith('@'))) {
        final text = e.value.toString().toLowerCase();
        for (final w in _forbidden) {
          if (text.contains(w)) hits.add('${e.key}: "$w"');
        }
      }
      expect(hits, isEmpty);
    });
  }

  test('hai bản dịch vi/en có cùng bộ khóa', () {
    Set<String> keys(String f) =>
        (jsonDecode(File(f).readAsStringSync()) as Map<String, dynamic>).keys
            .where((k) => !k.startsWith('@'))
            .toSet();
    final vi = keys('lib/core/l10n/app_vi.arb');
    final en = keys('lib/core/l10n/app_en.arb');
    expect(vi.difference(en), isEmpty, reason: 'thiếu ở en');
    expect(en.difference(vi), isEmpty, reason: 'thiếu ở vi');
  });
}
