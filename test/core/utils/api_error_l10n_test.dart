import 'package:flutter_test/flutter_test.dart';
import 'package:happy_share/core/l10n/gen/app_localizations.dart';
import 'package:happy_share/core/l10n/gen/app_localizations_en.dart';
import 'package:happy_share/core/l10n/gen/app_localizations_vi.dart';
import 'package:happy_share/core/network/api_exception.dart';
import 'package:happy_share/core/utils/api_error_l10n.dart';

void main() {
  final locales = <String, AppLocalizations>{
    'vi': AppLocalizationsVi(),
    'en': AppLocalizationsEn(),
  };

  test('mọi ApiErrorCode đều có thông báo (vi + en), không rỗng', () {
    for (final entry in locales.entries) {
      for (final code in ApiErrorCode.values) {
        expect(
          code.localized(entry.value).trim(),
          isNotEmpty,
          reason: '${entry.key}/${code.code}',
        );
      }
    }
  });

  test(
    'đăng nhập bằng tên tài khoản/email/SĐT: thông báo không nói riêng "email" (D13)',
    () {
      final affected = [
        ApiErrorCode.invalidCredentials,
        ApiErrorCode.identifierTaken,
      ];
      for (final entry in locales.entries) {
        for (final code in affected) {
          final text = code.localized(entry.value).toLowerCase();
          expect(
            text.contains('email'),
            isFalse,
            reason: '${entry.key}/${code.code}: $text',
          );
        }
      }
    },
  );

  test('mã lỗi mới khác nhau về nội dung (không dùng nhầm chuỗi)', () {
    final vi = locales['vi']!;
    expect(
      ApiErrorCode.identifierTaken.localized(vi),
      isNot(ApiErrorCode.alreadyInFamily.localized(vi)),
    );
    expect(
      ApiErrorCode.rateLimited.localized(vi),
      isNot(ApiErrorCode.unknown.localized(vi)),
    );
  });

  test('không dùng chữ cấm theo B5 ("theo dõi liên tục", "real-time")', () {
    for (final entry in locales.entries) {
      for (final code in ApiErrorCode.values) {
        final text = code.localized(entry.value).toLowerCase();
        expect(text.contains('theo dõi liên tục'), isFalse);
        expect(text.contains('real-time'), isFalse);
        expect(text.contains('realtime'), isFalse);
      }
    }
  });
}
