// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hakikisha_summative/features/auth/auth_injection.dart';
import 'package:hakikisha_summative/features/auth/domain/entities/app_user.dart';
import 'package:hakikisha_summative/features/auth/domain/failures/auth_failure.dart';
import 'package:hakikisha_summative/features/auth/domain/repositories/auth_repository.dart';
import 'package:hakikisha_summative/features/auth/presentation/pages/login_page.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
    GetIt.instance.registerSingleton<AuthRepository>(repository);
    registerAuthPresentation(GetIt.instance);
  });

  tearDown(GetIt.instance.reset);

  Future<void> pumpLogin(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
  }

  Finder field(String label) =>
      find.byType(TextField).at(label == 'Email' ? 0 : 1);

  testWidgets('empty form shows both field errors and does not log in', (
    tester,
  ) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    verifyNever(
      () => repository.logIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });

  testWidgets('incomplete email shows the design error message', (
    tester,
  ) async {
    await pumpLogin(tester);

    await tester.enterText(field('Email'), 'amina.otieno@gmail');
    await tester.enterText(field('Password'), 'secret123');
    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(
      find.text('Enter a full email address, like name@gmail.com.'),
      findsOneWidget,
    );
    expect(find.text('Enter your password.'), findsNothing);
  });

  testWidgets('typing in a field clears its error', (tester) async {
    await pumpLogin(tester);

    await tester.tap(find.text('Log in'));
    await tester.pump();
    await tester.enterText(field('Email'), 'a');
    await tester.pump();

    expect(find.text('Enter your email address.'), findsNothing);
    expect(find.text('Enter your password.'), findsOneWidget);
  });

  testWidgets('valid details log in; a wrong password shows a snackbar', (
    tester,
  ) async {
    when(
      () => repository.logIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(AuthFailure.fromCode('invalid-credential'));
    await pumpLogin(tester);

    await tester.enterText(field('Email'), 'amina.otieno@gmail.com');
    await tester.enterText(field('Password'), 'wrong-pass');
    await tester.tap(find.text('Log in'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));

    verify(
      () => repository.logIn(
        email: 'amina.otieno@gmail.com',
        password: 'wrong-pass',
      ),
    ).called(1);
    expect(find.text('Wrong email or password. Try again.'), findsOneWidget);
  });

  testWidgets('button shows a loading state while logging in', (tester) async {
    when(
      () => repository.logIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer(
      (_) => Future.delayed(
        const Duration(seconds: 1),
        () => const AppUser(uid: 'u', email: 'a@b.com', emailVerified: true),
      ),
    );
    await pumpLogin(tester);

    await tester.enterText(field('Email'), 'amina.otieno@gmail.com');
    await tester.enterText(field('Password'), 'secret123');
    await tester.tap(find.text('Log in'));
    await tester.pump();

    expect(find.text('Logging in…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
  });
}
