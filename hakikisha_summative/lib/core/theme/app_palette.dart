import 'package:material_ui/material_ui.dart';

/// Brand colours from the Figma file, in a light and a dark variant.
///
/// Widgets read the variant that matches the current theme with
/// `context.palette`, so nothing outside `lib/core/theme/` hard-codes a colour.
/// Every text/background pair used here is checked for 4.5:1 contrast in
/// `test/core/theme/app_palette_test.dart`.
@immutable
class AppPalette {
  const AppPalette({
    required this.brand,
    required this.onBrand,
    required this.heading,
    required this.text,
    required this.textMuted,
    required this.background,
    required this.surface,
    required this.field,
    required this.shadowDark,
    required this.shadowLight,
    required this.danger,
    required this.success,
  });

  /// Fill for primary buttons, the Genuine card and selected pills.
  final Color brand;

  /// Text and icons drawn on [brand], [danger] or [success].
  final Color onBrand;

  /// Screen titles, labels and links.
  final Color heading;

  /// Body text.
  final Color text;

  /// Hints, captions and secondary text.
  final Color textMuted;

  /// Behind the waves image, visible while it loads.
  final Color background;

  /// Raised neumorphic cards, dialogs and the drawer.
  final Color surface;

  /// Inset fields, slightly darker than [surface].
  final Color field;

  /// Neumorphic shadow, bottom-right of raised shapes.
  final Color shadowDark;

  /// Neumorphic highlight, top-left of raised shapes.
  final Color shadowLight;

  /// Fill for errors and the Flagged card. Text on it uses [onBrand].
  final Color danger;

  /// Fill for success messages. Text on it uses [onBrand].
  final Color success;

  static const light = AppPalette(
    brand: Color(0xFF123F1F),
    onBrand: Color(0xFFFFFFFF),
    heading: Color(0xFF123F1F),
    text: Color(0xFF2B2F36),
    textMuted: Color(0xFF555B66),
    background: Color(0xFFE9EBF0),
    surface: Color(0xFFE6E9F0),
    field: Color(0xFFE2E6ED),
    shadowDark: Color(0x99A3B1C6),
    shadowLight: Color(0xE6FFFFFF),
    danger: Color(0xFF9B2C21),
    success: Color(0xFF1E6B34),
  );

  static const dark = AppPalette(
    brand: Color(0xFF2B6E43),
    onBrand: Color(0xFFFFFFFF),
    heading: Color(0xFFA3DBB5),
    text: Color(0xFFE6EAE7),
    textMuted: Color(0xFFA9B3AD),
    background: Color(0xFF171C19),
    surface: Color(0xFF212824),
    field: Color(0xFF1B211E),
    shadowDark: Color(0xCC0B0E0C),
    shadowLight: Color(0x14FFFFFF),
    danger: Color(0xFFA8392D),
    success: Color(0xFF2B6E43),
  );
}

extension AppPaletteX on BuildContext {
  /// The palette for the current theme brightness.
  AppPalette get palette => Theme.of(this).brightness == Brightness.dark
      ? AppPalette.dark
      : AppPalette.light;
}
