// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Hakikisha';

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'Scan history';

  @override
  String get navPharmacies => 'Nearby pharmacies';

  @override
  String get navReport => 'Report a medicine';

  @override
  String get navMyReports => 'My reports';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get navLogout => 'Log out';

  @override
  String get openMenu => 'Open menu';

  @override
  String get back => 'Back';

  @override
  String get logoutTitle => 'Log out of Hakikisha?';

  @override
  String get logoutMessage => 'Your scan history stays saved to your account.';

  @override
  String get stayLoggedIn => 'Stay logged in';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsScanning => 'Scanning';

  @override
  String get scanSound => 'Scan sound';

  @override
  String get scanSoundHint => 'Play a sound when a scan finishes';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationHint => 'Vibrate when a scan finishes';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get saveHistory => 'Save scan history';

  @override
  String get saveHistoryHint =>
      'When off, new scans are not added to your history';

  @override
  String get settingsSaveError =>
      'We couldn\'t save that setting. Please try again.';

  @override
  String get placeholderBody => 'This screen is being built.';
}
