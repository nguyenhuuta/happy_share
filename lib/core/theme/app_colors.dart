import 'package:flutter/material.dart';

import '../constants/domain_enums.dart';

/// Màu thiết kế "Warm Indigo & Terracotta" (Design System Happy Share).
///
/// Nguồn: bảng thiết kế do chủ dự án cung cấp (2026-11-09, thay bảng Sage Green & Honey Amber cũ).
/// Giá trị trong [AppPalette] là **nguyên văn bảng thiết kế**; giá trị đánh dấu `// điều chỉnh` hoặc
/// `// suy ra` là phần bổ sung để đạt WCAG (chữ ≥ 4.5:1, viền điều khiển ≥ 3:1) hoặc vì bảng chưa nêu —
/// xem `test/core/theme_test.dart` (kiểm tra tỷ lệ tương phản của mọi cặp màu).
abstract final class AppPalette {
  // ---------------- Light ----------------
  static const primary = Color(0xFF2B4C7E); // Xanh chàm ấm áp (Warm Indigo)
  static const primaryContainer = Color(0xFFDDE7F5);
  static const onPrimaryContainer = Color(
    0xFF14294A,
  ); // suy ra: chữ trên primaryContainer
  static const accent = Color(0xFFD96B43); // Cam đất nung (Terracotta)
  static const accentContainer = Color(0xFFFCE8E0);
  static const canvas = Color(0xFFF8F9FB);
  static const card = Color(0xFFFFFFFF);
  static const surfaceLow = Color(0xFFF3F4F7);
  static const border = Color(0xFFDDE2E8); // viền thẻ, đường kẻ
  static const text = Color(0xFF1A2533);
  static const textMuted = Color(0xFF556578);
  static const error = Color(0xFFDC3545);
  static const errorContainer = Color(0xFFFEE2E2);

  // Chữ trắng trên Terracotta chỉ đạt 3.42:1 → dùng chữ đậm (4.5:1). Không đặt chữ accent nguyên bản lên nền sáng.
  static const onAccent = text; // điều chỉnh
  static const accentText = Color(
    0xFFAE4C28,
  ); // điều chỉnh: bản đậm của accent để dùng làm CHỮ/liên kết (≥ 4.5:1)
  static const onErrorContainer = Color(
    0xFFC21F2F,
  ); // điều chỉnh: #CF2434 chỉ 4.3:1 trên #FEE2E2
  // Viền ô nhập liệu/nút viền là thành phần điều khiển → cần ≥ 3:1 (WCAG 1.4.11). #DDE2E8 chỉ ~1.3:1
  // nên chỉ dùng cho viền thẻ/đường kẻ; ô nhập dùng màu đậm hơn cùng tông.
  static const outlineControl = Color(0xFF7F8B9C); // điều chỉnh

  // ---------------- Dark ----------------
  static const darkCanvas = Color(0xFF141A24);
  static const darkCard = Color(0xFF1F2837);
  static const darkPrimary = Color(0xFF79A7DF);
  static const darkAccent = Color(0xFFE28562);
  static const darkText = Color(0xFFF0F4F8);
  static const darkTextMuted = Color(0xFF94A3B8);

  // Bảng chưa nêu → suy ra cùng tông, đã kiểm tra tương phản.
  static const darkSurfaceHigh = Color(0xFF2A3548); // suy ra
  static const darkBorder = Color(0xFF2F3B50); // suy ra
  static const darkPrimaryContainer = Color(0xFF22385A); // suy ra
  static const darkOnPrimary = Color(0xFF0E2038); // suy ra
  static const darkOnPrimaryContainer = Color(0xFFDDE7F5); // suy ra
  static const darkOnAccent = Color(0xFF141A24); // suy ra
  static const darkAccentContainer = Color(0xFF4A2A1F); // suy ra
  static const darkOnAccentContainer = Color(0xFFFCE8E0); // suy ra
  static const darkError = Color(0xFFF2828C); // suy ra
  static const darkOnError = Color(0xFF3A0A10); // suy ra
  static const darkErrorContainer = Color(0xFF4A1F25); // suy ra
  static const darkOnErrorContainer = Color(0xFFFDE8E8); // suy ra
  static const darkOutlineControl = Color(
    0xFF66768F,
  ); // điều chỉnh: viền điều khiển ≥ 3:1
}

/// Bán kính bo góc và kích thước tối thiểu (M3, bảng thiết kế).
abstract final class AppRadius {
  static const double card = 16;
  static const double input = 12;
  static const double chip = 9999; // bo tròn hoàn toàn
}

/// Vùng chạm tối thiểu (WCAG / M3).
const double kMinTouchTarget = 48;

/// ColorScheme sáng/tối dựng tường minh từ [AppPalette] (không dùng `fromSeed` để màu đúng thiết kế).
abstract final class AppColorSchemes {
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: AppPalette.primary,
    onPrimary: Colors.white,
    primaryContainer: AppPalette.primaryContainer,
    onPrimaryContainer: AppPalette.onPrimaryContainer,
    secondary: AppPalette.accent,
    onSecondary: AppPalette.onAccent,
    secondaryContainer: AppPalette.accentContainer,
    onSecondaryContainer: AppPalette.text,
    error: AppPalette.error,
    onError: Colors.white,
    errorContainer: AppPalette.errorContainer,
    onErrorContainer: AppPalette.onErrorContainer,
    surface: AppPalette.canvas, // nền app
    onSurface: AppPalette.text,
    onSurfaceVariant: AppPalette.textMuted,
    outline: AppPalette.outlineControl,
    outlineVariant: AppPalette.border,
    surfaceContainerLowest: AppPalette.card,
    surfaceContainerLow: AppPalette.surfaceLow,
    surfaceContainer: AppPalette.surfaceLow,
    surfaceContainerHigh: AppPalette.surfaceLow,
    surfaceContainerHighest: AppPalette.surfaceLow,
  );

  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: AppPalette.darkPrimary,
    onPrimary: AppPalette.darkOnPrimary,
    primaryContainer: AppPalette.darkPrimaryContainer,
    onPrimaryContainer: AppPalette.darkOnPrimaryContainer,
    secondary: AppPalette.darkAccent,
    onSecondary: AppPalette.darkOnAccent,
    secondaryContainer: AppPalette.darkAccentContainer,
    onSecondaryContainer: AppPalette.darkOnAccentContainer,
    error: AppPalette.darkError,
    onError: AppPalette.darkOnError,
    errorContainer: AppPalette.darkErrorContainer,
    onErrorContainer: AppPalette.darkOnErrorContainer,
    surface: AppPalette.darkCanvas,
    onSurface: AppPalette.darkText,
    onSurfaceVariant: AppPalette.darkTextMuted,
    outline: AppPalette.darkOutlineControl,
    outlineVariant: AppPalette.darkBorder,
    surfaceContainerLowest: AppPalette.darkCanvas,
    surfaceContainerLow: AppPalette.darkCard,
    surfaceContainer: AppPalette.darkCard,
    surfaceContainerHigh: AppPalette.darkSurfaceHigh,
    surfaceContainerHighest: AppPalette.darkSurfaceHigh,
  );
}

/// Kiểu hiển thị của một trạng thái chia sẻ: luôn dùng **biểu tượng + chữ**, không chỉ màu.
@immutable
class SharingStateStyle {
  const SharingStateStyle({
    required this.accent,
    required this.foreground,
    required this.background,
    required this.icon,
  });

  /// Màu nhấn theo bảng thiết kế (viền, chấm, nền biểu tượng lớn) — KHÔNG dùng cho chữ nhỏ.
  final Color accent;

  /// Màu chữ + biểu tượng trên [background], đạt ≥ 4.5:1.
  final Color foreground;
  final Color background;
  final IconData icon;
}

/// Kiểu chip độ mới dữ liệu.
@immutable
class FreshnessStyle {
  const FreshnessStyle({required this.foreground, required this.background});
  final Color foreground;
  final Color background;
}

/// Màu ngữ nghĩa của app (trạng thái chia sẻ, độ mới) — lấy bằng `context.statusColors`.
@immutable
class AppStatusColors extends ThemeExtension<AppStatusColors> {
  const AppStatusColors({
    required this.sharing,
    required this.limited,
    required this.paused,
    required this.notShared,
    required this.freshnessFresh,
    required this.freshnessRecent,
    required this.freshnessStale,
    required this.freshnessNone,
  });

  final SharingStateStyle sharing;
  final SharingStateStyle limited;
  final SharingStateStyle paused;
  final SharingStateStyle notShared;
  final FreshnessStyle freshnessFresh;
  final FreshnessStyle freshnessRecent;
  final FreshnessStyle freshnessStale;
  final FreshnessStyle freshnessNone;

  static const light = AppStatusColors(
    sharing: SharingStateStyle(
      accent: Color(0xFF2E7D32),
      foreground: Color(0xFF2E7D32),
      background: Color(0xFFE8F5E9),
      icon: Icons.check_circle_rounded,
    ),
    limited: SharingStateStyle(
      accent: Color(0xFFD97706),
      foreground: Color(
        0xFFA35600,
      ), // điều chỉnh: #D97706 chỉ 2.9:1 trên nền chip
      background: Color(0xFFFEF3C7),
      icon: Icons.info_rounded,
    ),
    paused: SharingStateStyle(
      accent: Color(0xFF4B5563),
      foreground: Color(0xFF4B5563),
      background: Color(0xFFF3F4F6),
      icon: Icons.pause_circle_rounded,
    ),
    // Bảng mới chưa nêu "Chưa chia sẻ" → giữ nguyên giá trị cũ (xám trung tính).
    notShared: SharingStateStyle(
      accent: Color(0xFF6B7280),
      foreground: Color(0xFF69707E), // điều chỉnh: 4.39:1 → 4.52:1
      background: Color(0xFFF3F4F6),
      icon: Icons.remove_circle_rounded,
    ),
    // Mới: badge xanh chàm nhẹ. Cũ: badge đất nung nhẹ. Không có: xám trung tính.
    freshnessFresh: FreshnessStyle(
      foreground: AppPalette.onPrimaryContainer,
      background: AppPalette.primaryContainer,
    ),
    // "recent" (≤ 2 giờ) bảng thiết kế chưa nêu → trung tính, tách khỏi "mới" và "cũ".
    freshnessRecent: FreshnessStyle(
      foreground: AppPalette.textMuted,
      background: AppPalette.surfaceLow,
    ),
    freshnessStale: FreshnessStyle(
      foreground: AppPalette.accentText,
      background: AppPalette.accentContainer,
    ),
    freshnessNone: FreshnessStyle(
      foreground: Color(0xFF69707E),
      background: Color(0xFFF3F4F6),
    ),
  );

  // Bảng thiết kế chưa có màu trạng thái cho dark mode → suy ra: nền tối pha màu, chữ/biểu tượng sáng.
  static const dark = AppStatusColors(
    sharing: SharingStateStyle(
      accent: Color(0xFF68C188),
      foreground: Color(0xFF8FD6A8),
      background: Color(0xFF1E3A29),
      icon: Icons.check_circle_rounded,
    ),
    limited: SharingStateStyle(
      accent: Color(0xFFF5A84B),
      foreground: Color(0xFFF5B766),
      background: Color(0xFF3A2D14),
      icon: Icons.info_rounded,
    ),
    paused: SharingStateStyle(
      accent: Color(0xFF94A3B8),
      foreground: Color(0xFFB4C0D0),
      background: Color(0xFF263042),
      icon: Icons.pause_circle_rounded,
    ),
    notShared: SharingStateStyle(
      accent: Color(0xFF9CA3AF),
      foreground: Color(0xFFB3B9C3),
      background: Color(0xFF2A2F36),
      icon: Icons.remove_circle_rounded,
    ),
    freshnessFresh: FreshnessStyle(
      foreground: AppPalette.darkOnPrimaryContainer,
      background: AppPalette.darkPrimaryContainer,
    ),
    freshnessRecent: FreshnessStyle(
      foreground: AppPalette.darkTextMuted,
      background: AppPalette.darkSurfaceHigh,
    ),
    freshnessStale: FreshnessStyle(
      foreground: AppPalette.darkAccent,
      background: AppPalette.darkAccentContainer,
    ),
    freshnessNone: FreshnessStyle(
      foreground: Color(0xFFB3B9C3),
      background: Color(0xFF2A2F36),
    ),
  );

  /// `unknown` (giá trị lạ từ server) hiển thị như "Chưa chia sẻ": an toàn, không khẳng định gì.
  SharingStateStyle forSharing(SharingState s) => switch (s) {
    SharingState.sharing => sharing,
    SharingState.limited => limited,
    SharingState.paused => paused,
    SharingState.notShared || SharingState.unknown => notShared,
  };

  FreshnessStyle forFreshness(Freshness f) => switch (f) {
    Freshness.fresh => freshnessFresh,
    Freshness.recent => freshnessRecent,
    Freshness.stale => freshnessStale,
    Freshness.none || Freshness.unknown => freshnessNone,
  };

  @override
  AppStatusColors copyWith() => this;

  @override
  AppStatusColors lerp(ThemeExtension<AppStatusColors>? other, double t) =>
      t < 0.5 || other is! AppStatusColors ? this : other;
}

extension AppStatusColorsContext on BuildContext {
  /// Màu trạng thái chia sẻ / độ mới theo theme hiện tại.
  AppStatusColors get statusColors =>
      Theme.of(this).extension<AppStatusColors>() ?? AppStatusColors.light;
}
