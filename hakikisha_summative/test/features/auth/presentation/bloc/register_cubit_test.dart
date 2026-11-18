import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/auth/domain/entities/app_user.dart';
import 'package:hakikisha_summative/features/auth/domain/failures/auth_failure.dart';
import 'package:hakikisha_summative/features/auth/domain/repositories/auth_repository.dart';
import 'package:hakikisha_summative/features/auth/presentation/bloc/form_status.dart';
import 'package:hakikisha_summative/features/auth/presentation/bloc/register_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() => repository = MockAuthRepository());

  When<Future<AppUser>> stubSignUp() => when(
    () => repository.signUp(
      fullName: any(named: 'fullName'),
      email: any(named: 'email'),
      phone: any(named: 'phone'),
      password: any(named: 'password'),
    ),
  );

  Future<void> submitValid(RegisterCubit cubit) => cubit.submit(
    fullName: 'Amina Otieno',
    email: 'amina.otieno@gmail.com',
    phone: '0712 345 678',
    password: 'hakikisha2026',
  );

  blocTest<RegisterCubit, RegisterState>(
    'shows an error for every invalid field and does not call Firebase',
    build: () => RegisterCubit(repository),
    act: (cubit) => cubit.submit(
      fullName: '',
      email: 'amina',
      phone: '123',
      password: 'abc',
    ),
    expect: () => [
      isA<RegisterState>().having(
        (s) => s.fieldErrors.keys.toSet(),
        'fields with errors',
        AuthField.values.toSet(),
      ),
    ],
    verify: (_) => verifyNever(
      () => repository.signUp(
        fullName: any(named: 'fullName'),
        email: any(named: 'email'),
        phone: any(named: 'phone'),
        password: any(named: 'password'),
      ),
    ),
  );

  blocTest<RegisterCubit, RegisterState>(
    'shows "Strong password" only once the password meets the rules',
    build: () => RegisterCubit(repository),
    act: (cubit) => cubit
      ..passwordChanged('hakikisha2026')
      ..passwordChanged('abc'),
    expect: () => [
      const RegisterState(passwordStrong: true),
      const RegisterState(),
    ],
  );

  blocTest<RegisterCubit, RegisterState>(
    'creates the account with the typed details',
    setUp: () => stubSignUp().thenAnswer(
      (_) async =>
          const AppUser(uid: 'u', email: 'a@b.com', emailVerified: false),
    ),
    build: () => RegisterCubit(repository),
    act: submitValid,
    expect: () => [
      const RegisterState(status: FormStatus.submitting, passwordStrong: true),
      const RegisterState(status: FormStatus.success, passwordStrong: true),
    ],
    verify: (_) => verify(
      () => repository.signUp(
        fullName: 'Amina Otieno',
        email: 'amina.otieno@gmail.com',
        phone: '0712 345 678',
        password: 'hakikisha2026',
      ),
    ).called(1),
  );

  blocTest<RegisterCubit, RegisterState>(
    'shows a readable message when the email is already registered',
    setUp: () =>
        stubSignUp().thenThrow(AuthFailure.fromCode('email-already-in-use')),
    build: () => RegisterCubit(repository),
    act: submitValid,
    skip: 1,
    expect: () => [
      isA<RegisterState>()
          .having((s) => s.status, 'status', FormStatus.failure)
          .having((s) => s.errorMessage, 'message', contains('already exists')),
    ],
  );
}
