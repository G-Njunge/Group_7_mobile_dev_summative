import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:hakikisha_summative/features/settings/domain/entities/app_settings.dart';
import 'package:hakikisha_summative/features/settings/domain/repositories/settings_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockPrefs extends Mock implements SharedPreferences {}

void main() {
  Future<SettingsRepositoryImpl> repoWith(Map<String, Object> stored) async {
    SharedPreferences.setMockInitialValues(stored);
    return SettingsRepositoryImpl(await SharedPreferences.getInstance());
  }

  const custom = AppSettings(
    theme: ThemePreference.dark,
    language: AppLanguage.swahili,
    scanSound: false,
    vibration: false,
    saveHistory: false,
  );

  test('every language survives a save and relaunch', () async {
    for (final language in AppLanguage.values) {
      final settings = AppSettings(language: language);
      await (await repoWith({})).save(settings);
      final relaunched = SettingsRepositoryImpl(
        await SharedPreferences.getInstance(),
      );
      expect(relaunched.load(), settings, reason: language.name);
    }
  });

  test('first launch returns the defaults', () async {
    expect((await repoWith({})).load(), const AppSettings());
  });

  test('saved settings are restored by a fresh instance (relaunch)', () async {
    await (await repoWith({})).save(custom);

    // A new repository over the same storage simulates restarting the app.
    final relaunched = SettingsRepositoryImpl(
      await SharedPreferences.getInstance(),
    );
    expect(relaunched.load(), custom);
  });

  test('stores enums by name under stable keys', () async {
    final repo = await repoWith({});
    await repo.save(custom);
    final prefs = await SharedPreferences.getInstance();

    expect(prefs.getString(SettingsRepositoryImpl.themeKey), 'dark');
    expect(prefs.getString(SettingsRepositoryImpl.languageKey), 'swahili');
    expect(prefs.getBool(SettingsRepositoryImpl.saveHistoryKey), isFalse);
  });

  test('unknown or wrongly typed values fall back to defaults', () async {
    final repo = await repoWith({
      SettingsRepositoryImpl.themeKey: 'purple',
      SettingsRepositoryImpl.languageKey: 42,
      SettingsRepositoryImpl.scanSoundKey: 'yes',
      SettingsRepositoryImpl.vibrationKey: false,
    });

    expect(repo.load(), const AppSettings(vibration: false));
  });

  test('throws SettingsSaveException when the device rejects a write', () {
    final prefs = _MockPrefs();
    when(() => prefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => prefs.setBool(any(), any())).thenAnswer((_) async => false);

    expect(
      SettingsRepositoryImpl(prefs).save(custom),
      throwsA(isA<SettingsSaveException>()),
    );
  });
}
