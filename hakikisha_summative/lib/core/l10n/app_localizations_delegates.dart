import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/app_localizations.dart';

/// Every localizations delegate the app needs, for `MaterialApp`.
///
/// Flutter ships its built-in widget strings (back-button tooltips, dialog
/// labels, date pickers) for Swahili but not for Kinyarwanda. Without a
/// fallback, choosing Kinyarwanda would leave those widgets with no
/// localizations and crash them. The fallbacks below load Flutter's English
/// strings for any language it doesn't cover, while the app's own strings
/// still come from `AppLocalizations` (`app_rw.arb`).
const appLocalizationsDelegates = <LocalizationsDelegate<dynamic>>[
  ...AppLocalizations.localizationsDelegates,
  _EnglishFallback<MaterialLocalizations>(GlobalMaterialLocalizations.delegate),
  _EnglishFallback<CupertinoLocalizations>(
    GlobalCupertinoLocalizations.delegate,
  ),
  _EnglishFallback<WidgetsLocalizations>(GlobalWidgetsLocalizations.delegate),
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
