import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hakikisha_summative/features/auth/auth_injection.dart';
import 'package:hakikisha_summative/features/auth/domain/entities/app_user.dart';
import 'package:hakikisha_summative/features/auth/domain/repositories/auth_repository.dart';
import 'package:hakikisha_summative/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:hakikisha_summative/main.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late StreamController<AppUser?> authChanges;

  setUp(() {
    repository = MockAuthRepository();
    authChanges = StreamController<AppUser?>();
    when(() => repository.authStateChanges())
        .thenAnswer((_) => authChanges.stream);
    GetIt.instance.registerSingleton<AuthRepository>(repository);
    registerAuthPresentation(GetIt.instance);
  });

  tearDown(() async {
    await authChanges.close();
    await GetIt.instance.reset();
  });

  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
    BlocProvider(
      create: (_) =>
          AuthBloc(repository)..add(const AuthSubscriptionRequested()),
      child: const HakikishaApp(),
    ),
  );

  testWidgets('signed out: Landing, and it opens Login and Register', (
    tester,
  ) async {
    await pumpApp(tester);
    authChanges.add(null);
    await tester.pumpAndSettle();

    expect(
      find.text('Know your medicine. Before you take it.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);

    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Try Hakikisha'));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsWidgets);
  });

  testWidgets('unverified user lands on Verify email', (tester) async {
    await pumpApp(tester);
    authChanges.add(
      const AppUser(uid: 'u', email: 'amina@gmail.com', emailVerified: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verify your email'), findsOneWidget);
    expect(find.textContaining('amina@gmail.com'), findsOneWidget);
  });

  testWidgets('signing in from Login replaces the stack with the home screen', (
    tester,
  ) async {
    await pumpApp(tester);
    authChanges.add(null);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

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
    expect(find.text('HABARI, AMINA'), findsOneWidget);
    // Login was popped, so there's nothing to go back to.
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      isFalse,
    );
  });
}
