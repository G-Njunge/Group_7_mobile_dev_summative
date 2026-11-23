import 'package:cupertino_ui/cupertino_ui.dart' as cupertino_ui;
import 'package:flutter/cupertino.dart' as flutter_cupertino;
import 'package:flutter/material.dart' as flutter_material;
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart'
    as flutter_l10n;
import 'package:material_ui/material_ui.dart' as material_ui;

import 'generated/app_localizations.dart';

/// Every localizations delegate the app needs, for `MaterialApp`.
///
/// The app uses two copies of the Material and Cupertino libraries.  Without
/// both package delegates, scaffold/drawer widgets can throw
/// `No MaterialLocalizations found` in localized widget tests.
///
/// Flutter and the UI packages do not cover every app locale, so unsupported
/// locales fall back to English for framework strings while
/// `AppLocalizations` continues to provide the app's translations.
const appLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  ...AppLocalizations.localizationsDelegates,
  material_ui.GlobalMaterialLocalizations.delegate,
  cupertino_ui.GlobalCupertinoLocalizations.delegate,
  _EnglishFallback<flutter_material.MaterialLocalizations>(
    flutter_l10n.GlobalMaterialLocalizations.delegate,
  ),
  _EnglishFallback<flutter_cupertino.CupertinoLocalizations>(
    flutter_l10n.GlobalCupertinoLocalizations.delegate,
  ),
  _EnglishFallback<WidgetsLocalizations>(
    flutter_l10n.GlobalWidgetsLocalizations.delegate,
  ),
  _EnglishFallback<material_ui.MaterialLocalizations>(
    material_ui.GlobalMaterialLocalizations.delegate,
  ),
  _EnglishFallback<cupertino_ui.CupertinoLocalizations>(
    cupertino_ui.GlobalCupertinoLocalizations.delegate,
  ),
];

/// Loads English framework strings when [_delegate] has no strings for a
/// locale.  Locales supported by [_delegate] are handled by its earlier
/// delegate and never reach this fallback.
class _EnglishFallback<T> extends LocalizationsDelegate<T> {
  const _EnglishFallback(this._delegate);

  final LocalizationsDelegate<T> _delegate;

  @override
  bool isSupported(Locale locale) => !_delegate.isSupported(locale);

  @override
  Future<T> load(Locale locale) => _delegate.load(const Locale('en'));

  @override
  bool shouldReload(_EnglishFallback<T> old) => false;
}
