import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/app_localizations.dart';

/// Adds English framework labels for Kinyarwanda, which Flutter's built-in
/// Material and Cupertino localization delegates do not currently provide.
class AppLocalizationDelegates {
  const AppLocalizationDelegates._();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    ...AppLocalizations.localizationsDelegates,
    _KinyarwandaMaterialLocalizationsDelegate(),
    _KinyarwandaCupertinoLocalizationsDelegate(),
  ];
}

class _KinyarwandaMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _KinyarwandaMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(_KinyarwandaMaterialLocalizationsDelegate old) => false;
}

class _KinyarwandaCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _KinyarwandaCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'rw';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(_KinyarwandaCupertinoLocalizationsDelegate old) => false;
}
