import 'dart:async';

// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hakikisha_summative/app.dart';
import 'package:hakikisha_summative/core/router/app_router.dart';
import 'package:hakikisha_summative/core/session/session_cubit.dart';
import 'package:hakikisha_summative/core/session/session_source.dart';
import 'package:hakikisha_summative/features/auth/auth_injection.dart';
import 'package:hakikisha_summative/features/auth/domain/entities/app_user.dart';
import 'package:hakikisha_summative/features/auth/domain/repositories/auth_repository.dart';
import 'package:hakikisha_summative/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hakikisha_summative/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:hakikisha_summative/features/settings/domain/entities/app_settings.dart';
import 'package:hakikisha_summative/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/pump_app.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

/// Whole-app tests: real router, redirect, drawer, auth screens, settings
/// and SharedPreferences, with only Firebase replaced by [FakeSessionSource]
/// and a mocked [AuthRepository].
void main() {
  late FakeSessionSource session;
  late SettingsCubit settings;
  late MockAuthRepository repository;
  late StreamController<AppUser?> authChanges;

  setUp(() {
    repository = MockAuthRepository();
    authChanges = StreamController<AppUser?>.broadcast();
    when(
      () => repository.authStateChanges(),
    ).thenAnswer((_) => authChanges.stream);
    GetIt.instance.registerSingleton<AuthRepository>(repository);
    registerAuthPresentation(GetIt.instance);
  });

  tearDown(() async {
    await authChanges.close();
    await GetIt.instance.reset();
  });

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
      BlocProvider(
        create: (_) =>
            AuthBloc(repository)..add(const AuthSubscriptionRequested()),
        child: HakikishaApp(
          router: createAppRouter(sessionCubit),
          sessionCubit: sessionCubit,
          settingsCubit: settings,
        ),
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

  const landingHeadline = 'Know your medicine. Before you take it.';

  testWidgets('a signed-out user lands on the landing screen', (tester) async {
    await launch(tester, status: SessionStatus.signedOut);
    expect(find.text(landingHeadline), findsOneWidget);
    expect(find.byTooltip('Open menu'), findsNothing);
  });

  testWidgets('landing opens Login and Register', (tester) async {
    await launch(tester, status: SessionStatus.signedOut);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Try Hakikisha'));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsWidgets);
  });

  testWidgets('an unverified user lands on Verify email', (tester) async {
    await launch(tester, status: SessionStatus.unverified);
    authChanges.add(
      const AppUser(uid: 'u', email: 'amina@gmail.com', emailVerified: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verify your email'), findsOneWidget);
    expect(find.textContaining('amina@gmail.com'), findsOneWidget);
  });

  testWidgets('a signed-in user lands on Home', (tester) async {
    await launch(tester);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('signing in from Login moves to Home and clears the stack', (
    tester,
  ) async {
    await launch(tester, status: SessionStatus.signedOut);
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    session.emit(SessionStatus.signedIn);
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsNothing);
    expect(find.text('Home'), findsOneWidget);
    // Login went with the landing page, so there's nothing to go back to.
    expect(find.byTooltip('Open menu'), findsOneWidget);
  });

  testWidgets('the drawer navigates between sections', (tester) async {
    await launch(tester);

    await openDrawerItem(tester, 'Settings');
    expect(find.text('APPEARANCE'), findsOneWidget);

    await openDrawerItem(tester, 'Scan history');
    expect(find.text('Scan history'), findsOneWidget);
  });

  testWidgets('log out asks first, then returns to the landing screen', (
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
    expect(find.text(landingHeadline), findsOneWidget);
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
