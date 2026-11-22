import '../entities/app_settings.dart';

/// Device-local storage for [AppSettings]. The SettingsCubit depends on this
/// interface so tests can swap in a mock.
abstract interface class SettingsRepository {
  /// Reads the saved settings synchronously, falling back to defaults for
  /// anything missing or unreadable, so the first frame already has the
  /// right theme and language.
  AppSettings load();

  /// Throws a [SettingsSaveException] if the device refused the write.
  Future<void> save(AppSettings settings);
}

class SettingsSaveException implements Exception {
  const SettingsSaveException();

  @override
  String toString() => 'SettingsSaveException: settings could not be saved';
}
