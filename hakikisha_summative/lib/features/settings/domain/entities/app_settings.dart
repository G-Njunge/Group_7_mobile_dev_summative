import 'package:equatable/equatable.dart';

/// Light, dark or follow the phone. Kept separate from Flutter's `ThemeMode`
/// so the domain layer has no Flutter dependency.
enum ThemePreference { system, light, dark }

enum AppLanguage {
  english('en', 'English'),
  swahili('sw', 'Kiswahili');

  const AppLanguage(this.code, this.nativeName);

  /// Locale language code.
  final String code;

  /// Shown in the language picker in its own language, whatever the app
  /// language is.
  final String nativeName;
}

/// The user's device preferences, saved with SharedPreferences and restored on
/// every launch.
class AppSettings extends Equatable {
  const AppSettings({
    this.theme = ThemePreference.system,
    this.language = AppLanguage.english,
    this.scanSound = true,
    this.vibration = true,
    this.saveHistory = true,
  });

  final ThemePreference theme;
  final AppLanguage language;

  /// Play a sound when a scan finishes (read by the scan feature).
  final bool scanSound;

  /// Vibrate when a scan finishes (read by the scan feature).
  final bool vibration;

  /// When false, the scan feature doesn't write new `scans` docs.
  final bool saveHistory;

  AppSettings copyWith({
    ThemePreference? theme,
    AppLanguage? language,
    bool? scanSound,
    bool? vibration,
    bool? saveHistory,
  }) => AppSettings(
    theme: theme ?? this.theme,
    language: language ?? this.language,
    scanSound: scanSound ?? this.scanSound,
    vibration: vibration ?? this.vibration,
    saveHistory: saveHistory ?? this.saveHistory,
  );

  @override
  List<Object> get props => [
    theme,
    language,
    scanSound,
    vibration,
    saveHistory,
  ];
}
