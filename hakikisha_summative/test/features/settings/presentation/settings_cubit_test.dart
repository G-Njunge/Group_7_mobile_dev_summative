import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/settings/domain/entities/app_settings.dart';
import 'package:hakikisha_summative/features/settings/domain/repositories/settings_repository.dart';
import 'package:hakikisha_summative/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements SettingsRepository {}

void main() {
  late _MockRepo repo;
  const saved = AppSettings(theme: ThemePreference.light);
  final dark = saved.copyWith(theme: ThemePreference.dark);

  setUpAll(() => registerFallbackValue(const AppSettings()));

  setUp(() {
    repo = _MockRepo();
    when(() => repo.load()).thenReturn(saved);
    when(() => repo.save(any())).thenAnswer((_) async {});
  });

  test('starts with the saved settings, so the first frame is correct', () {
    expect(SettingsCubit(repo).state, const SettingsState(saved));
  });

  blocTest<SettingsCubit, SettingsState>(
    'update applies the change instantly and saves it',
    build: () => SettingsCubit(repo),
    act: (cubit) => cubit.update((_) => dark),
    expect: () => [SettingsState(dark)],
    verify: (_) => verify(() => repo.save(dark)).called(1),
  );

  blocTest<SettingsCubit, SettingsState>(
    'update with unchanged settings does nothing',
    build: () => SettingsCubit(repo),
    act: (cubit) => cubit.update((_) => saved),
    expect: () => <SettingsState>[],
    verify: (_) => verifyNever(() => repo.save(any())),
  );

  blocTest<SettingsCubit, SettingsState>(
    'a failed save rolls back and flags the failure',
    setUp: () =>
        when(() => repo.save(any())).thenThrow(const SettingsSaveException()),
    build: () => SettingsCubit(repo),
    act: (cubit) => cubit.update((_) => dark),
    expect: () => [
      SettingsState(dark),
      const SettingsState(saved, saveFailed: true),
    ],
  );

  blocTest<SettingsCubit, SettingsState>(
    'the next successful change clears the failure flag',
    setUp: () =>
        when(() => repo.save(dark)).thenThrow(const SettingsSaveException()),
    build: () => SettingsCubit(repo),
    act: (cubit) async {
      await cubit.update((_) => dark);
      await cubit.update((s) => s.copyWith(vibration: false));
    },
    skip: 2,
    expect: () => [SettingsState(saved.copyWith(vibration: false))],
  );

  test('two quick changes both apply (no stale overwrite)', () async {
    final cubit = SettingsCubit(repo);
    final first = cubit.update((s) => s.copyWith(theme: ThemePreference.dark));
    final second = cubit.update(
      (s) => s.copyWith(language: AppLanguage.swahili),
    );
    await Future.wait([first, second]);

    expect(
      cubit.state.settings,
      saved.copyWith(
        theme: ThemePreference.dark,
        language: AppLanguage.swahili,
      ),
    );
    await cubit.close();
  });

  test('copyWith changes only the given fields', () {
    final changed = const AppSettings().copyWith(language: AppLanguage.swahili);
    expect(changed.language, AppLanguage.swahili);
    expect(changed.copyWith(), changed);
    expect(changed.theme, const AppSettings().theme);
  });
}
