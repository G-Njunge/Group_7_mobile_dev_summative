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
/// The app uses two copies of the Material and Cupertino libraries: the core
/// widgets come from the `material_ui` / `cupertino_ui` packages and the other
/// screens from `flutter/material`. Each copy looks up its own localizations
/// type, so both sets are registered here. Without the package ones, every
/// screen with the drawer crashed in Kiswahili ("No MaterialLocalizations
/// found").
///
/// Neither copy has built-in strings for Kinyarwanda, so the fallbacks at the
/// end load English for those widgets (dialog buttons, tooltips), while the
/// app's own strings still come from `AppLocalizations` (`app_rw.arb`).
const appLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  // App strings plus flutter/material, flutter/cupertino and widgets strings.
  ...AppLocalizations.localizationsDelegates,
  // Strings for widgets from the material_ui / cupertino_ui packages.
  material_ui.GlobalMaterialLocalizations.delegate,
  cupertino_ui.GlobalCupertinoLocalizations.delegate,
  // English for languages a library doesn't cover, such as Kinyarwanda.
  // The type arguments must be explicit: inside this list Dart would
  // otherwise infer `dynamic`, and the fallback would match nothing.
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

/// Serves [_delegate]'s English strings for locales [_delegate] doesn't
/// support. Locales it does support never reach this delegate, because
/// `Localizations` uses the first delegate that supports the locale.
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
