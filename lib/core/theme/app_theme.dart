import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Theme Material 3 theo Design System (màu Warm Indigo & Terracotta, font Be Vietnam Pro).
abstract final class AppTheme {
  static const String fontFamily = 'BeVietnamPro';

  static ThemeData light() =>
      _build(AppColorSchemes.light, AppStatusColors.light);
  static ThemeData dark() => _build(AppColorSchemes.dark, AppStatusColors.dark);

  static ThemeData _build(ColorScheme scheme, AppStatusColors status) {
    final isLight = scheme.brightness == Brightness.light;
    // Thẻ/hộp thoại/bottom sheet dùng "Surface Card" (trắng ở sáng, #202B23 ở tối).
    final cardColor = isLight
        ? scheme.surfaceContainerLowest
        : scheme.surfaceContainerLow;
    final inputShape = BorderRadius.circular(AppRadius.input);

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: inputShape,
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: scheme.surface,
      // Vùng chạm ≥ 48dp ở mọi nút.
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      extensions: [status],
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isLight ? cardColor : scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isLight ? cardColor : scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.card),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        space: 1,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: border(scheme.outline),
        enabledBorder: border(scheme.outline),
        focusedBorder: border(scheme.primary, 2),
        errorBorder: border(scheme.error),
        focusedErrorBorder: border(scheme.error, 2),
        disabledBorder: border(scheme.outlineVariant),
        helperStyle: TextStyle(color: scheme.onSurfaceVariant),
        errorStyle: TextStyle(
          color: isLight ? AppPalette.onErrorContainer : scheme.error,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, kMinTouchTarget),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, kMinTouchTarget),
          side: BorderSide(color: scheme.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, kMinTouchTarget),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(), // pill
        side: BorderSide(color: scheme.outlineVariant),
        backgroundColor: scheme.surfaceContainerLow,
        labelStyle: TextStyle(color: scheme.onSurface),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isLight ? AppPalette.text : AppPalette.darkSurfaceHigh,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: isLight ? AppPalette.canvas : AppPalette.darkText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        backgroundColor: cardColor,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primaryContainer,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
    );
  }
}
