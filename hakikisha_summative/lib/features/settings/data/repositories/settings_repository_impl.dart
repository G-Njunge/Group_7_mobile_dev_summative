import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// [SettingsRepository] backed by SharedPreferences. Enums are stored by
/// name, so reordering an enum never changes what a saved value means.
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  static const themeKey = 'settings.theme';
  static const languageKey = 'settings.language';
  static const scanSoundKey = 'settings.scanSound';
  static const vibrationKey = 'settings.vibration';
  static const saveHistoryKey = 'settings.saveHistory';

  @override
  AppSettings load() {
    const defaults = AppSettings();
    return AppSettings(
      theme: _enum(ThemePreference.values, themeKey) ?? defaults.theme,
      language: _enum(AppLanguage.values, languageKey) ?? defaults.language,
      scanSound: _bool(scanSoundKey) ?? defaults.scanSound,
      vibration: _bool(vibrationKey) ?? defaults.vibration,
      saveHistory: _bool(saveHistoryKey) ?? defaults.saveHistory,
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    final results = await Future.wait([
      _prefs.setString(themeKey, settings.theme.name),
      _prefs.setString(languageKey, settings.language.name),
      _prefs.setBool(scanSoundKey, settings.scanSound),
      _prefs.setBool(vibrationKey, settings.vibration),
      _prefs.setBool(saveHistoryKey, settings.saveHistory),
    ]);
    if (results.contains(false)) throw const SettingsSaveException();
  }

  /// `null` when the key is missing or holds a value from an older version.
  T? _enum<T extends Enum>(List<T> values, String key) {
    final stored = _prefs.get(key);
    return stored is String ? values.asNameMap()[stored] : null;
  }

  /// `null` when the key is missing or holds a non-bool.
  bool? _bool(String key) {
    final stored = _prefs.get(key);
    return stored is bool ? stored : null;
  }
}
