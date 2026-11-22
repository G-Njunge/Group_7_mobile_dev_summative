import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Builds the app's [ThemeData] from an [AppPalette].
///
/// Component themes here give stock Material widgets (switches, dialogs,
/// snackbars, text buttons) the Hakikisha look, so feature code can use them
/// directly without restyling.
abstract final class AppTheme {
  static final ThemeData light = _build(AppPalette.light, Brightness.light);
  static final ThemeData dark = _build(AppPalette.dark, Brightness.dark);

  /// Material's minimum tap target. Every button uses at least this height.
  static const double minTapTarget = 48;

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: p.brand,
          brightness: brightness,
        ).copyWith(
          // In dark mode the light heading green reads better than the fill.
          primary: isDark ? p.heading : p.brand,
          onPrimary: isDark ? p.background : p.onBrand,
          surface: p.surface,
          onSurface: p.text,
          onSurfaceVariant: p.textMuted,
          error: isDark ? const Color(0xFFFFB4AB) : p.danger,
        );

    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    final textTheme = base.textTheme
        .apply(bodyColor: p.text, displayColor: p.heading)
        .copyWith(
          headlineLarge: _heading(base.textTheme.headlineLarge, p),
          headlineMedium: _heading(base.textTheme.headlineMedium, p),
          headlineSmall: _heading(base.textTheme.headlineSmall, p),
          titleLarge: _heading(base.textTheme.titleLarge, p),
          titleMedium: base.textTheme.titleMedium?.copyWith(
            color: p.heading,
            fontWeight: FontWeight.w700,
          ),
        );
    const pill = StadiumBorder();
    const buttonText = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

    return base.copyWith(
      scaffoldBackgroundColor: p.background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: p.heading,
        titleTextStyle: textTheme.titleMedium,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.brand,
          foregroundColor: p.onBrand,
          minimumSize: const Size(minTapTarget, 52),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: pill,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.heading,
          minimumSize: const Size(minTapTarget, minTapTarget),
          textStyle: buttonText,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.onBrand : p.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.brand : p.field,
        ),
        trackOutlineColor: WidgetStatePropertyAll(
          p.textMuted.withValues(alpha: 0.4),
        ),
      ),
      drawerTheme: DrawerThemeData(backgroundColor: p.surface),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
      dividerTheme: DividerThemeData(color: p.textMuted.withValues(alpha: 0.2)),
    );
  }

  static TextStyle? _heading(TextStyle? style, AppPalette p) =>
      style?.copyWith(color: p.heading, fontWeight: FontWeight.w800);
}
