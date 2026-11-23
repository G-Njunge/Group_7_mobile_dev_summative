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

  @override
  String get profileLoadError =>
      'We couldn\'t load your profile. Please try again.';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profileNotSet => 'Not set';

  @override
  String get profileSignedInWith => 'Signed in with';

  @override
  String get profileSignInGoogle => 'Google';

  @override
  String get profileSignInPassword => 'Email and password';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileSaved => 'Profile updated.';

  @override
  String get profileSaveError =>
      'We couldn\'t save your changes. Please try again.';

  @override
  String get profileFullName => 'Full name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileSaveChanges => 'Save changes';

  @override
  String get historyScans => 'Scans';

  @override
  String get historyGenuine => 'Genuine';

  @override
  String get historyFlagged => 'Flagged';

  @override
  String get historyNotFound => 'Not found';

  @override
  String get historyRecentScans => 'RECENT SCANS';

  @override
  String get historyEmpty => 'No scans to show yet.';

  @override
  String get historyLoadError =>
      'We couldn\'t load your scan history. Please try again.';

  @override
  String get historyUnknownMedicine => 'Unknown medicine';

  @override
  String get historyResult => 'Result';

  @override
  String get historyMethod => 'Method';

  @override
  String get historyScanned => 'Scanned';

  @override
  String get historyBatch => 'Batch';

  @override
  String get historyScanId => 'Scan ID';

  @override
  String get historyMethodCamera => 'Camera';

  @override
  String get historyMethodManual => 'Entered by hand';

  @override
  String get historyMethodUpload => 'Photo upload';

  @override
  String get historyDeleteTitle => 'Delete this scan?';

  @override
  String get historyDeleteMessage => 'It will be removed from your history.';

  @override
  String get historyDeleteConfirm => 'Delete';

  @override
  String get historyDeleteCancel => 'Cancel';

  @override
  String get historyDeleted => 'Scan deleted.';

  @override
  String get historyDeleteError =>
      'We couldn\'t delete that scan. Please try again.';

  @override
  String get historyDeleteTooltip => 'Delete scan';
}
