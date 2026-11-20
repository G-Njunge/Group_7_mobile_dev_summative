import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/core/di/injection.dart';
import 'package:hakikisha_summative/core/session/session_source.dart';
import 'package:hakikisha_summative/features/settings/domain/repositories/settings_repository.dart';
import 'package:hakikisha_summative/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(sl.reset);

  test('wires settings end to end and keeps cubits as factories', () async {
    await configureDependencies();

    expect(sl<SettingsRepository>(), same(sl<SettingsRepository>()));
    final first = sl<SettingsCubit>();
    final second = sl<SettingsCubit>();
    expect(first, isNot(same(second)), reason: 'cubits must be factories');
    await first.close();
    await second.close();
  });

  test('registers Firebase clients lazily (nothing touched at start-up)', () async {
    await configureDependencies();

    // Registered, but not created: resolving them needs Firebase.initializeApp.
    expect(sl.isRegistered<FirebaseAuth>(), isTrue);
    expect(sl.isRegistered<SessionSource>(), isTrue);
  });
}
