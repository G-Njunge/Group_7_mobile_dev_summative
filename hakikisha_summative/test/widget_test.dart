import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/app.dart';
import 'package:hakikisha_summative/core/router/app_router.dart';
import 'package:hakikisha_summative/core/session/session_cubit.dart';
import 'package:hakikisha_summative/core/session/session_source.dart';
import 'package:hakikisha_summative/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:hakikisha_summative/features/settings/domain/entities/app_settings.dart';
import 'package:hakikisha_summative/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/pump_app.dart';

/// Whole-app tests: real router, redirect, drawer, settings and
/// SharedPreferences, with only Firebase replaced by [FakeSessionSource].
void main() {
  late FakeSessionSource session;
  late SettingsCubit settings;

  Future<void> launch(
    WidgetTester tester, {
    SessionStatus status = SessionStatus.signedIn,
    Map<String, Object> savedPrefs = const {},
  }) async {
    SharedPreferences.setMockInitialValues(savedPrefs);
    session = FakeSessionSource(status);
    final sessionCubit = SessionCubit(session);
    settings = SettingsCubit(
      SettingsRepositoryImpl(await SharedPreferences.getInstance()),
    );
    addTearDown(sessionCubit.close);
    addTearDown(settings.close);

    await tester.pumpWidget(
      HakikishaApp(
        router: createAppRouter(sessionCubit),
        sessionCubit: sessionCubit,
        settingsCubit: settings,
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openDrawerItem(WidgetTester tester, String label) async {
    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('a signed-out user lands on the welcome screen', (tester) async {
    await launch(tester, status: SessionStatus.signedOut);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.byTooltip('Open menu'), findsNothing);
  });

  testWidgets('a signed-in user lands on Home', (tester) async {
    await launch(tester);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('signing in from another device state moves to Home', (
    tester,
  ) async {
    await launch(tester, status: SessionStatus.signedOut);

    session.emit(SessionStatus.signedIn);
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('the drawer navigates between sections', (tester) async {
    await launch(tester);

    await openDrawerItem(tester, 'Settings');
    expect(find.text('APPEARANCE'), findsOneWidget);

    await openDrawerItem(tester, 'Scan history');
    expect(find.text('Scan history'), findsOneWidget);
  });

  testWidgets('log out asks first, then returns to the welcome screen', (
    tester,
  ) async {
    await launch(tester);
    await openDrawerItem(tester, 'Log out');

    // Cancelling keeps the user signed in.
    await tester.tap(find.text('Stay logged in'));
    await tester.pumpAndSettle();
    expect(session.signOutCalls, 0);

    await tester.tap(find.widgetWithText(ListTile, 'Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Log out'));
    await tester.pumpAndSettle();

    expect(session.signOutCalls, 1);
    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets('theme and language changes apply app-wide immediately', (
    tester,
  ) async {
    await launch(tester);
    await openDrawerItem(tester, 'Settings');

    await tester.tap(find.text('Dark'));
    await tester.tap(find.text('Kiswahili'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.text('Mipangilio'), findsOneWidget);
  });

  testWidgets('saved preferences are restored on relaunch', (tester) async {
    await launch(
      tester,
      savedPrefs: {
        SettingsRepositoryImpl.themeKey: ThemePreference.dark.name,
        SettingsRepositoryImpl.languageKey: AppLanguage.swahili.name,
      },
    );

    expect(settings.state.settings.theme, ThemePreference.dark);
    final context = tester.element(find.byType(Scaffold).first);
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(find.text('Skrini hii inajengwa.'), findsOneWidget);
  });
}
