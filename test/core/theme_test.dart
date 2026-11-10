import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:happy_share/core/constants/domain_enums.dart';
import 'package:happy_share/core/l10n/gen/app_localizations_en.dart';
import 'package:happy_share/core/l10n/gen/app_localizations_vi.dart';
import 'package:happy_share/core/theme/app_colors.dart';
import 'package:happy_share/core/theme/app_theme.dart';
import 'package:happy_share/core/utils/status_l10n.dart';

/// Tỷ lệ tương phản WCAG 2.x giữa hai màu.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  group('token khớp bảng thiết kế (chặn sai lệch âm thầm)', () {
    test('Light', () {
      expect(AppPalette.primary, const Color(0xFF2B4C7E));
      expect(AppPalette.primaryContainer, const Color(0xFFDDE7F5));
      expect(AppPalette.accent, const Color(0xFFD96B43));
      expect(AppPalette.accentContainer, const Color(0xFFFCE8E0));
      expect(AppPalette.canvas, const Color(0xFFF8F9FB));
      expect(AppPalette.card, const Color(0xFFFFFFFF));
      expect(AppPalette.surfaceLow, const Color(0xFFF3F4F7));
      expect(AppPalette.border, const Color(0xFFDDE2E8));
      expect(AppPalette.text, const Color(0xFF1A2533));
      expect(AppPalette.textMuted, const Color(0xFF556578));
      expect(AppPalette.error, const Color(0xFFDC3545));
      expect(AppPalette.errorContainer, const Color(0xFFFEE2E2));
    });

    test('Dark', () {
      expect(AppPalette.darkCanvas, const Color(0xFF141A24));
      expect(AppPalette.darkCard, const Color(0xFF1F2837));
      expect(AppPalette.darkPrimary, const Color(0xFF79A7DF));
      expect(AppPalette.darkAccent, const Color(0xFFE28562));
      expect(AppPalette.darkText, const Color(0xFFF0F4F8));
      expect(AppPalette.darkTextMuted, const Color(0xFF94A3B8));
    });

    test(
      'Màu nhấn (accent) và nền của các trạng thái chia sẻ đúng bảng thiết kế',
      () {
        final c = AppStatusColors.light;
        expect(c.sharing.accent, const Color(0xFF2E7D32));
        expect(c.sharing.background, const Color(0xFFE8F5E9));
        expect(c.limited.accent, const Color(0xFFD97706));
        expect(c.limited.background, const Color(0xFFFEF3C7));
        expect(c.paused.accent, const Color(0xFF4B5563));
        expect(c.paused.background, const Color(0xFFF3F4F6));
        // "Chưa chia sẻ" bảng mới chưa nêu → giữ giá trị cũ.
        expect(c.notShared.accent, const Color(0xFF6B7280));
        expect(c.notShared.background, const Color(0xFFF3F4F6));
      },
    );

    test('ColorScheme dựng từ token', () {
      expect(AppColorSchemes.light.primary, AppPalette.primary);
      expect(AppColorSchemes.light.secondary, AppPalette.accent);
      expect(AppColorSchemes.light.surface, AppPalette.canvas); // nền app
      expect(AppColorSchemes.light.surfaceContainerLowest, AppPalette.card);
      expect(AppColorSchemes.light.surfaceContainerLow, AppPalette.surfaceLow);
      expect(AppColorSchemes.light.outlineVariant, AppPalette.border);
      expect(AppColorSchemes.dark.primary, AppPalette.darkPrimary);
      expect(AppColorSchemes.dark.surface, AppPalette.darkCanvas);
      expect(AppColorSchemes.dark.surfaceContainerLow, AppPalette.darkCard);
      expect(
        AppColorSchemes.dark.surfaceContainerHigh,
        AppPalette.darkSurfaceHigh,
      );
    });
  });

  group('tương phản WCAG (chữ ≥ 4.5:1)', () {
    void check(String name, Color fg, Color bg, [double min = 4.5]) {
      final r = contrast(fg, bg);
      expect(
        r,
        greaterThanOrEqualTo(min),
        reason: '$name: ${r.toStringAsFixed(2)}:1 < $min:1',
      );
    }

    test('Light — chữ và nút chính', () {
      const l = AppPalette.canvas;
      check('chữ chính/nền', AppPalette.text, l);
      check('chữ chính/thẻ', AppPalette.text, AppPalette.card);
      check('chữ phụ/nền', AppPalette.textMuted, l);
      check('chữ phụ/thẻ', AppPalette.textMuted, AppPalette.card);
      check(
        'chữ phụ/surface thấp',
        AppPalette.textMuted,
        AppPalette.surfaceLow,
      );
      check('chữ trắng/primary (nút chính)', Colors.white, AppPalette.primary);
      check(
        'primary/thẻ (nút viền, liên kết)',
        AppPalette.primary,
        AppPalette.card,
      );
      check(
        'on-primary-container/primary-container',
        AppPalette.onPrimaryContainer,
        AppPalette.primaryContainer,
      );
      check(
        'chữ/accent-container',
        AppPalette.text,
        AppPalette.accentContainer,
      );
      check(
        'chữ đậm/accent (nút nhấn)',
        AppPalette.onAccent,
        AppPalette.accent,
      );
      check('accent đậm làm chữ/thẻ', AppPalette.accentText, AppPalette.card);
      check(
        'accent đậm làm chữ/accent-container',
        AppPalette.accentText,
        AppPalette.accentContainer,
      );
      check(
        'accent đậm làm chữ/nền (liên kết "Đăng ký")',
        AppPalette.accentText,
        AppPalette.canvas,
      );
      check('chữ trắng/error (nút xóa)', Colors.white, AppPalette.error);
      check(
        'chữ lỗi/error-container',
        AppPalette.onErrorContainer,
        AppPalette.errorContainer,
      );
      check('chữ lỗi/nền', AppPalette.onErrorContainer, l);
    });

    test(
      'Light — Terracotta nguyên bản KHÔNG dùng được cho chữ trắng/chữ nhỏ (ghi nhận hạn chế)',
      () {
        expect(
          contrast(Colors.white, AppPalette.accent),
          lessThan(4.5),
        ); // 3.42:1
        expect(contrast(AppPalette.accent, AppPalette.card), lessThan(4.5));
      },
    );

    test('Dark', () {
      for (final bg in [
        AppPalette.darkCanvas,
        AppPalette.darkCard,
        AppPalette.darkSurfaceHigh,
      ]) {
        check('chữ chính', AppPalette.darkText, bg);
        check('chữ phụ', AppPalette.darkTextMuted, bg);
      }
      check('primary/nền', AppPalette.darkPrimary, AppPalette.darkCanvas);
      check('primary/thẻ', AppPalette.darkPrimary, AppPalette.darkCard);
      check(
        'on-primary/primary',
        AppPalette.darkOnPrimary,
        AppPalette.darkPrimary,
      );
      check(
        'on-primary-container/primary-container',
        AppPalette.darkOnPrimaryContainer,
        AppPalette.darkPrimaryContainer,
      );
      check('accent/nền', AppPalette.darkAccent, AppPalette.darkCanvas);
      check('on-accent/accent', AppPalette.darkOnAccent, AppPalette.darkAccent);
      check(
        'on-accent-container/accent-container',
        AppPalette.darkOnAccentContainer,
        AppPalette.darkAccentContainer,
      );
      check('lỗi/nền', AppPalette.darkError, AppPalette.darkCanvas);
      check('lỗi/thẻ', AppPalette.darkError, AppPalette.darkCard);
      check('on-error/error', AppPalette.darkOnError, AppPalette.darkError);
      check(
        'on-error-container/error-container',
        AppPalette.darkOnErrorContainer,
        AppPalette.darkErrorContainer,
      );
    });

    test('mọi cặp on*/nền của hai ColorScheme đạt 4.5:1', () {
      for (final s in [AppColorSchemes.light, AppColorSchemes.dark]) {
        final pairs = <String, (Color, Color)>{
          'onPrimary/primary': (s.onPrimary, s.primary),
          'onPrimaryContainer/primaryContainer': (
            s.onPrimaryContainer,
            s.primaryContainer,
          ),
          'onSecondary/secondary': (s.onSecondary, s.secondary),
          'onSecondaryContainer/secondaryContainer': (
            s.onSecondaryContainer,
            s.secondaryContainer,
          ),
          'onError/error': (s.onError, s.error),
          'onErrorContainer/errorContainer': (
            s.onErrorContainer,
            s.errorContainer,
          ),
          'onSurface/surface': (s.onSurface, s.surface),
          'onSurfaceVariant/surface': (s.onSurfaceVariant, s.surface),
          'onSurfaceVariant/surfaceContainerLow': (
            s.onSurfaceVariant,
            s.surfaceContainerLow,
          ),
        };
        for (final e in pairs.entries) {
          check('${s.brightness.name} ${e.key}', e.value.$1, e.value.$2);
        }
      }
    });

    test(
      'viền ô nhập/nút viền (thành phần điều khiển) ≥ 3:1 so với nền và thẻ',
      () {
        check('light/nền', AppPalette.outlineControl, AppPalette.canvas, 3);
        check('light/thẻ', AppPalette.outlineControl, AppPalette.card, 3);
        check(
          'dark/nền',
          AppPalette.darkOutlineControl,
          AppPalette.darkCanvas,
          3,
        );
        check(
          'dark/thẻ',
          AppPalette.darkOutlineControl,
          AppPalette.darkCard,
          3,
        );
        // Màu viền mảnh của bảng thiết kế chỉ dành cho thẻ/đường kẻ (trang trí).
        expect(AppColorSchemes.light.outlineVariant, AppPalette.border);
      },
    );
  });

  group('trạng thái chia sẻ & độ mới', () {
    for (final entry in {
      'light': AppStatusColors.light,
      'dark': AppStatusColors.dark,
    }.entries) {
      test('${entry.key}: chữ/biểu tượng trên nền chip ≥ 4.5:1', () {
        final c = entry.value;
        for (final s in [c.sharing, c.limited, c.paused, c.notShared]) {
          expect(
            contrast(s.foreground, s.background),
            greaterThanOrEqualTo(4.5),
          );
        }
        for (final f in [
          c.freshnessFresh,
          c.freshnessRecent,
          c.freshnessStale,
          c.freshnessNone,
        ]) {
          expect(
            contrast(f.foreground, f.background),
            greaterThanOrEqualTo(4.5),
          );
        }
      });
    }

    test(
      'mỗi trạng thái có biểu tượng RIÊNG (không chỉ phân biệt bằng màu)',
      () {
        for (final c in [AppStatusColors.light, AppStatusColors.dark]) {
          final icons = {
            c.sharing.icon,
            c.limited.icon,
            c.paused.icon,
            c.notShared.icon,
          };
          expect(icons, hasLength(4));
          expect(c.sharing.icon, Icons.check_circle_rounded);
          expect(c.limited.icon, Icons.info_rounded);
          expect(c.paused.icon, Icons.pause_circle_rounded);
          expect(c.notShared.icon, Icons.remove_circle_rounded);
        }
      },
    );

    test('forSharing: đủ 4 giá trị, unknown → như "Chưa chia sẻ"', () {
      const c = AppStatusColors.light;
      expect(c.forSharing(SharingState.sharing), same(c.sharing));
      expect(c.forSharing(SharingState.limited), same(c.limited));
      expect(c.forSharing(SharingState.paused), same(c.paused));
      expect(c.forSharing(SharingState.notShared), same(c.notShared));
      expect(c.forSharing(SharingState.unknown), same(c.notShared));
    });

    test('forFreshness: đủ giá trị, unknown → như "Chưa có dữ liệu"', () {
      const c = AppStatusColors.light;
      expect(c.forFreshness(Freshness.fresh), same(c.freshnessFresh));
      expect(c.forFreshness(Freshness.recent), same(c.freshnessRecent));
      expect(c.forFreshness(Freshness.stale), same(c.freshnessStale));
      expect(c.forFreshness(Freshness.none), same(c.freshnessNone));
      expect(c.forFreshness(Freshness.unknown), same(c.freshnessNone));
    });

    test('nhãn đúng bảng thiết kế (vi) và có bản en', () {
      final vi = AppLocalizationsVi();
      expect(SharingState.sharing.label(vi), 'Đang chia sẻ');
      expect(SharingState.limited.label(vi), 'Chia sẻ hạn chế');
      expect(SharingState.paused.label(vi), 'Đã tạm dừng');
      expect(SharingState.notShared.label(vi), 'Chưa chia sẻ');
      expect(SharingState.unknown.label(vi), 'Chưa chia sẻ');
      expect(vi.freshnessStale, 'Dữ liệu cũ');
      expect(vi.freshnessNone, 'Chưa có dữ liệu');

      final en = AppLocalizationsEn();
      final labels = SharingState.values.map((s) => s.label(en)).toSet();
      expect(labels.every((l) => l.isNotEmpty), isTrue);
      expect(
        SharingState.sharing.label(en),
        isNot(SharingState.paused.label(en)),
      );
    });
  });

  group('ThemeData', () {
    for (final entry in {
      'light': AppTheme.light(),
      'dark': AppTheme.dark(),
    }.entries) {
      final t = entry.value;

      test(
        '${entry.key}: font Be Vietnam Pro, M3, extension có mặt, nền app = canvas',
        () {
          expect(t.useMaterial3, isTrue);
          expect(t.textTheme.bodyMedium?.fontFamily, AppTheme.fontFamily);
          expect(t.extension<AppStatusColors>(), isNotNull);
          expect(
            t.scaffoldBackgroundColor,
            entry.key == 'light' ? AppPalette.canvas : AppPalette.darkCanvas,
          );
        },
      );

      test('${entry.key}: bo góc thẻ 16, ô nhập 12, chip pill', () {
        final card = t.cardTheme.shape! as RoundedRectangleBorder;
        expect(card.borderRadius, BorderRadius.circular(16));
        final input =
            t.inputDecorationTheme.enabledBorder! as OutlineInputBorder;
        expect(input.borderRadius, BorderRadius.circular(12));
        expect(t.chipTheme.shape, isA<StadiumBorder>());
        expect(AppRadius.chip, 9999);
      });

      test('${entry.key}: nút có vùng chạm ≥ 48dp', () {
        double minHeight(ButtonStyle? s) => s!.minimumSize!.resolve({})!.height;
        expect(minHeight(t.filledButtonTheme.style), greaterThanOrEqualTo(48));
        expect(
          minHeight(t.outlinedButtonTheme.style),
          greaterThanOrEqualTo(48),
        );
        expect(minHeight(t.textButtonTheme.style), greaterThanOrEqualTo(48));
        expect(t.materialTapTargetSize, MaterialTapTargetSize.padded);
        expect(kMinTouchTarget, 48);
      });
    }
  });

  testWidgets(
    'chip trạng thái dựng được từ theme (biểu tượng + chữ) ở cả sáng và tối',
    (tester) async {
      for (final theme in [AppTheme.light(), AppTheme.dark()]) {
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Builder(
              builder: (context) {
                final s = context.statusColors.forSharing(SharingState.limited);
                return Scaffold(
                  body: Container(
                    color: s.background,
                    child: Row(
                      children: [
                        Icon(s.icon, color: s.foreground),
                        Text(
                          SharingState.limited.label(AppLocalizationsVi()),
                          style: TextStyle(color: s.foreground),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
        expect(find.text('Chia sẻ hạn chế'), findsOneWidget);
        expect(find.byIcon(Icons.info_rounded), findsOneWidget);
      }
    },
  );
}
