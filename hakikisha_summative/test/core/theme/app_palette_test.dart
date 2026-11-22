import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/core/theme/app_palette.dart';
import 'package:hakikisha_summative/core/theme/app_theme.dart';

/// WCAG 2.1 contrast ratio between two opaque colours.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  const minContrast = 4.5;

  for (final (name, p) in [
    ('light', AppPalette.light),
    ('dark', AppPalette.dark),
  ]) {
    group('$name palette meets WCAG AA (4.5:1)', () {
      final pairs = {
        'text on surface': (p.text, p.surface),
        'text on field': (p.text, p.field),
        'text on background': (p.text, p.background),
        'muted text on surface': (p.textMuted, p.surface),
        'muted text on field': (p.textMuted, p.field),
        'heading on surface': (p.heading, p.surface),
        'heading on background': (p.heading, p.background),
        'onBrand on brand': (p.onBrand, p.brand),
        'onBrand on danger': (p.onBrand, p.danger),
        'onBrand on success': (p.onBrand, p.success),
        'background on text (info snackbar)': (p.background, p.text),
      };
      for (final MapEntry(key: label, value: (fg, bg)) in pairs.entries) {
        test(label, () {
          expect(
            contrast(fg, bg),
            greaterThanOrEqualTo(minContrast),
            reason: '$label is ${contrast(fg, bg).toStringAsFixed(2)}:1',
          );
        });
      }
    });
  }

  test('form error colour is readable on fields in both themes', () {
    for (final (theme, p) in [
      (AppTheme.light, AppPalette.light),
      (AppTheme.dark, AppPalette.dark),
    ]) {
      expect(
        contrast(theme.colorScheme.error, p.field),
        greaterThanOrEqualTo(minContrast),
      );
    }
  });

  testWidgets('context.palette follows the theme brightness', (tester) async {
    Future<AppPalette> paletteFor(ThemeData theme) async {
      late AppPalette palette;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Builder(
            builder: (context) {
              palette = context.palette;
              return const SizedBox();
            },
          ),
        ),
      );
      // Switching themes animates; read the palette once it has finished.
      await tester.pumpAndSettle();
      return palette;
    }

    expect(await paletteFor(AppTheme.light), same(AppPalette.light));
    expect(await paletteFor(AppTheme.dark), same(AppPalette.dark));
  });

  test('buttons meet the 48dp minimum tap target', () {
    final size = AppTheme.light.filledButtonTheme.style!.minimumSize!.resolve(
      {},
    )!;
    expect(size.height, greaterThanOrEqualTo(AppTheme.minTapTarget));
  });
}
