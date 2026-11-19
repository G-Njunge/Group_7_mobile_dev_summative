import 'package:flutter/material.dart';

/// Colours used by the auth screens, taken from the Figma designs.
///
/// Temporary: once M5's theme lands in `lib/core/theme/`, these move there
/// (or get replaced by the theme's colour scheme).
abstract final class AuthColors {
  /// Dark green used for headings, buttons and links.
  static const primary = Color(0xFF123F1F);

  /// Light grey-blue panel behind the forms.
  static const surface = Color(0xFFE6E9F0);

  /// Slightly darker fill for the inset text fields.
  static const field = Color(0xFFE2E6ED);

  /// Body text.
  static const text = Color(0xFF2B2F36);

  /// Secondary text (hints, captions). Still meets 4.5:1 on [field].
  static const textMuted = Color(0xFF555B66);

  /// Error red (field errors, error snackbar).
  static const error = Color(0xFF9B2C21);

  /// Success green (strong password hint, success snackbar).
  static const success = Color(0xFF1E6B34);

  /// Dark grey for the info snackbar.
  static const info = Color(0xFF3A3F47);

  /// Neumorphic shadow (bottom-right of raised shapes).
  static const shadowDark = Color(0x99A3B1C6);

  /// Neumorphic highlight (top-left of raised shapes).
  static const shadowLight = Color(0xE6FFFFFF);

  /// Green used to tint the abstract image band.
  static const bandTint = Color(0xFF7FC79A);
}
