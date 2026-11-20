import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/auth/domain/entities/app_user.dart';
import 'package:hakikisha_summative/features/auth/domain/failures/auth_failure.dart';
import 'package:hakikisha_summative/features/auth/domain/repositories/auth_repository.dart';
import 'package:hakikisha_summative/features/auth/presentation/bloc/form_status.dart';
import 'package:hakikisha_summative/features/auth/presentation/bloc/google_sign_in_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  setUp(() => repository = MockAuthRepository());

  blocTest<GoogleSignInCubit, GoogleSignInState>(
    'succeeds when Google returns a user',
    setUp: () => when(() => repository.signInWithGoogle()).thenAnswer(
      (_) async =>
          const AppUser(uid: 'g', email: 'b@gmail.com', emailVerified: true),
    ),
    build: () => GoogleSignInCubit(repository),
    act: (cubit) => cubit.signIn(),
    expect: () => [
      const GoogleSignInState(status: FormStatus.submitting),
      const GoogleSignInState(status: FormStatus.success),
    ],
  );

  blocTest<GoogleSignInCubit, GoogleSignInState>(
    'goes quietly back to idle when the user cancels (no error)',
    setUp: () =>
        when(() => repository.signInWithGoogle()).thenAnswer((_) async => null),
    build: () => GoogleSignInCubit(repository),
    act: (cubit) => cubit.signIn(),
    expect: () => [
      const GoogleSignInState(status: FormStatus.submitting),
      const GoogleSignInState(),
    ],
  );

  blocTest<GoogleSignInCubit, GoogleSignInState>(
    'shows a readable message when Google sign-in fails',
    setUp: () =>
        when(() => repository.signInWithGoogle())
            .thenThrow(AuthFailure.fromCode('popup-blocked')),
    build: () => GoogleSignInCubit(repository),
    act: (cubit) => cubit.signIn(),
    skip: 1,
    expect: () => [
      isA<GoogleSignInState>()
          .having((s) => s.status, 'status', FormStatus.failure)
          .having((s) => s.errorMessage, 'message', contains('pop-up')),
    ],
  );
}
