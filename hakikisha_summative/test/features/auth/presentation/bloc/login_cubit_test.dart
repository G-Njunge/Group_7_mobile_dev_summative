import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/auth/domain/entities/app_user.dart';
import 'package:hakikisha_summative/features/auth/domain/failures/auth_failure.dart';
import 'package:hakikisha_summative/features/auth/domain/repositories/auth_repository.dart';
import 'package:hakikisha_summative/features/auth/presentation/bloc/form_status.dart';
import 'package:hakikisha_summative/features/auth/presentation/bloc/login_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() => repository = MockAuthRepository());

  When<Future<AppUser>> stubLogIn() => when(
    () => repository.logIn(
      email: any(named: 'email'),
      password: any(named: 'password'),
    ),
  );

  blocTest<LoginCubit, LoginState>(
    'shows field errors and does not call Firebase when fields are invalid',
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.submit(email: 'amina@gmail', password: ''),
    expect: () => [
      const LoginState(
        fieldErrors: {
          AuthField.email: 'Enter a full email address, like name@gmail.com.',
          AuthField.password: 'Enter your password.',
        },
      ),
    ],
    verify: (_) => verifyNever(
      () => repository.logIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ),
  );

  blocTest<LoginCubit, LoginState>(
    'clears a field error when that field is edited',
    build: () => LoginCubit(repository),
    seed: () => const LoginState(
      fieldErrors: {
        AuthField.email: 'Enter your email address.',
        AuthField.password: 'Enter your password.',
      },
    ),
    act: (cubit) => cubit.fieldEdited(AuthField.email),
    expect: () => [
      const LoginState(
        fieldErrors: {AuthField.password: 'Enter your password.'},
      ),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'submits valid details and ends in success',
    setUp: () => stubLogIn().thenAnswer(
      (_) async =>
          const AppUser(uid: 'u', email: 'a@b.com', emailVerified: true),
    ),
    build: () => LoginCubit(repository),
    act: (cubit) =>
        cubit.submit(email: 'amina@gmail.com', password: 'secret123'),
    expect: () => [
      const LoginState(status: FormStatus.submitting),
      const LoginState(status: FormStatus.success),
    ],
    verify: (_) => verify(
      () => repository.logIn(email: 'amina@gmail.com', password: 'secret123'),
    ).called(1),
  );

  blocTest<LoginCubit, LoginState>(
    'shows a readable message for a wrong password',
    setUp: () =>
        stubLogIn().thenThrow(AuthFailure.fromCode('invalid-credential')),
    build: () => LoginCubit(repository),
    act: (cubit) => cubit.submit(email: 'amina@gmail.com', password: 'nope'),
    expect: () => [
      const LoginState(status: FormStatus.submitting),
      const LoginState(
        status: FormStatus.failure,
        errorMessage: 'Wrong email or password. Try again.',
      ),
    ],
  );
}
