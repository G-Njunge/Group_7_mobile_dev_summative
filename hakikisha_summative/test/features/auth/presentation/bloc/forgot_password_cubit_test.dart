import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/auth/domain/failures/auth_failure.dart';
import 'package:hakikisha_summative/features/auth/domain/repositories/auth_repository.dart';
import 'package:hakikisha_summative/features/auth/presentation/bloc/forgot_password_cubit.dart';
import 'package:hakikisha_summative/features/auth/presentation/bloc/form_status.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() => repository = MockAuthRepository());

  blocTest<ForgotPasswordCubit, ForgotPasswordState>(
    'rejects an invalid email without calling Firebase',
    build: () => ForgotPasswordCubit(repository),
    act: (cubit) => cubit.submit('amina@gmail'),
    expect: () => [
      const ForgotPasswordState(
        fieldErrors: {
          AuthField.email: 'Enter a full email address, like name@gmail.com.',
        },
      ),
    ],
    verify: (_) => verifyNever(() => repository.sendPasswordResetEmail(any())),
  );

  blocTest<ForgotPasswordCubit, ForgotPasswordState>(
    'sends the link and remembers the trimmed address',
    setUp: () =>
        when(() => repository.sendPasswordResetEmail(any()))
            .thenAnswer((_) async {}),
    build: () => ForgotPasswordCubit(repository),
    act: (cubit) => cubit.submit(' amina@gmail.com '),
    expect: () => [
      const ForgotPasswordState(status: FormStatus.submitting),
      const ForgotPasswordState(
        status: FormStatus.success,
        sentTo: 'amina@gmail.com',
      ),
    ],
  );

  blocTest<ForgotPasswordCubit, ForgotPasswordState>(
    'shows a readable message when sending fails',
    setUp: () =>
        when(() => repository.sendPasswordResetEmail(any()))
            .thenThrow(AuthFailure.fromCode('too-many-requests')),
    build: () => ForgotPasswordCubit(repository),
    act: (cubit) => cubit.submit('amina@gmail.com'),
    skip: 1,
    expect: () => [
      isA<ForgotPasswordState>()
          .having((s) => s.status, 'status', FormStatus.failure)
          .having(
            (s) => s.errorMessage,
            'message',
            contains('Too many attempts'),
          ),
    ],
  );
}
