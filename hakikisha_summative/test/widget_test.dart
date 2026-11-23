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
import 'package:hakikisha_summative/features/history/domain/repositories/history_repository.dart';
import 'package:hakikisha_summative/features/history/presentation/bloc/history_cubit.dart';
import 'package:hakikisha_summative/features/scan/domain/entities/scan_record_entity.dart';
import 'package:hakikisha_summative/features/scan/domain/repositories/scan_repository.dart';
import 'package:hakikisha_summative/features/scan/domain/usecases/verify_medicine_usecase.dart';
import 'package:hakikisha_summative/features/scan/presentation/bloc/scan_bloc.dart';
import 'package:hakikisha_summative/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:hakikisha_summative/features/settings/domain/entities/app_settings.dart';
import 'package:hakikisha_summative/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/pump_app.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockHistoryRepository extends Mock implements HistoryRepository {}

class MockScanRepository extends Mock implements ScanRepository {}

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
    when(() => repository.authStateChanges())
        .thenAnswer((_) => authChanges.stream);
    GetIt.instance.registerSingleton<AuthRepository>(repository);
    registerAuthPresentation(GetIt.instance);

    // Home is the real scan screen, so it needs the scan dependencies.
    final scan = MockScanRepository();
    when(() => scan.watchLatestScan(any()))
        .thenAnswer((_) => Stream<ScanRecordEntity?>.value(null));
    GetIt.instance
      ..registerLazySingleton<ScanRepository>(() => scan)
      ..registerFactory<ScanBloc>(
        () => ScanBloc(
          repository: scan,
          verifyMedicineUseCase: VerifyMedicineUseCase(),
          getCurrentUserId: () => 'u',
        ),
      );
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
        // Created up front like in main.dart, where a listener reads it.
        lazy: false,
        create: (_) =>
            AuthBloc(repository)..add(const AuthSubscriptionRequested()),
        child: HakikishaApp(
          router: createAppRouter(sessionCubit),
          sessionCubit: sessionCubit,
          settingsCubit: settings,
        ),
      ),
    );
    // A signed-in session always has a user in the real app, so give the
    // AuthBloc one — Home reads it for the greeting and the user id.
    if (status == SessionStatus.signedIn) {
      authChanges.add(
        const AppUser(
          uid: 'u',
          email: 'amina@gmail.com',
          emailVerified: true,
          fullName: 'Amina Otieno',
        ),
      );
    }
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
    expect(find.text('What are you checking today?'), findsOneWidget);
  });

  testWidgets('signing in from Login moves to Home and clears the stack', (
    tester,
  ) async {
    await launch(tester, status: SessionStatus.signedOut);
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    session.emit(SessionStatus.signedIn);
    authChanges.add(
      const AppUser(
        uid: 'u',
        email: 'amina@gmail.com',
        emailVerified: true,
        fullName: 'Amina Otieno',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsNothing);
    expect(find.text('What are you checking today?'), findsOneWidget);
    // Login went with the landing page, so there's nothing to go back to.
    expect(find.byTooltip('Open menu'), findsOneWidget);
  });

  testWidgets('the drawer navigates between sections', (tester) async {
    final history = MockHistoryRepository();
    when(() => history.watchScans('u')).thenAnswer((_) => Stream.value([]));
    GetIt.instance.registerFactory(() => HistoryCubit(history));

    await launch(tester);
    authChanges.add(
      const AppUser(uid: 'u', email: 'amina@gmail.com', emailVerified: true),
    );
    await tester.pumpAndSettle();

    await openDrawerItem(tester, 'Settings');
    expect(find.text('APPEARANCE'), findsOneWidget);

    // The real History page, loaded for the signed-in user.
    await openDrawerItem(tester, 'Scan history');
    expect(find.text('No scans to show yet.'), findsOneWidget);
    verify(() => history.watchScans('u')).called(1);
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
    // Swahili applied app-wide: the drawer labels are translated. Open the
    // menu by icon, since its tooltip is itself translated.
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    expect(find.text('Mipangilio'), findsOneWidget);
  });
}
