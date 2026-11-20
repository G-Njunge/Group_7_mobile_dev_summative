import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/auth/domain/entities/app_user.dart';
import 'package:hakikisha_summative/features/auth/domain/failures/auth_failure.dart';
import 'package:hakikisha_summative/features/auth/domain/repositories/auth_repository.dart';
import 'package:hakikisha_summative/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  const unverified = AppUser(
    uid: 'uid-123',
    email: 'amina.otieno@gmail.com',
    emailVerified: false,
    fullName: 'Amina Otieno',
  );
  const verified = AppUser(
    uid: 'uid-123',
    email: 'amina.otieno@gmail.com',
    emailVerified: true,
    fullName: 'Amina Otieno',
  );

  setUp(() => repository = MockAuthRepository());

  test('starts in the unknown status (splash moment)', () {
    expect(AuthBloc(repository).state.status, AuthStatus.unknown);
  });

  group('AuthSubscriptionRequested', () {
    blocTest<AuthBloc, AuthState>(
      'maps signed out, unverified and verified users to statuses',
      setUp: () => when(() => repository.authStateChanges())
          .thenAnswer((_) => Stream.fromIterable([null, unverified, verified])),
      build: () => AuthBloc(repository),
      act: (bloc) => bloc.add(const AuthSubscriptionRequested()),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.status,
          'status',
          AuthStatus.unauthenticated,
        ),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unverified)
            .having((s) => s.user, 'user', unverified),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user, 'user', verified),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'goes back to unauthenticated and drops the user on logout',
      setUp: () =>
          when(() => repository.authStateChanges())
              .thenAnswer((_) => Stream.fromIterable([verified, null])),
      build: () => AuthBloc(repository),
      act: (bloc) => bloc.add(const AuthSubscriptionRequested()),
      skip: 1,
      expect: () => [
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unauthenticated)
            .having((s) => s.user, 'user', isNull),
      ],
    );
  });

  group('AuthLogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'asks the repository to log out',
      setUp: () => when(() => repository.logOut()).thenAnswer((_) async {}),
      build: () => AuthBloc(repository),
      act: (bloc) => bloc.add(const AuthLogoutRequested()),
      verify: (_) => verify(() => repository.logOut()).called(1),
    );
  });

  group('AuthVerificationCheckRequested', () {
    blocTest<AuthBloc, AuthState>(
      'becomes authenticated once the reloaded user is verified',
      setUp: () =>
          when(() => repository.reloadUser()).thenAnswer((_) async => verified),
      build: () => AuthBloc(repository),
      seed: () => AuthState.fromUser(unverified),
      act: (bloc) => bloc.add(const AuthVerificationCheckRequested()),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.verificationCheck,
          'check',
          VerificationCheck.checking,
        ),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.authenticated)
            .having((s) => s.user, 'user', verified),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'stays unverified and reports notVerified if the link was not tapped',
      setUp: () =>
          when(() => repository.reloadUser())
              .thenAnswer((_) async => unverified),
      build: () => AuthBloc(repository),
      seed: () => AuthState.fromUser(unverified),
      act: (bloc) => bloc.add(const AuthVerificationCheckRequested()),
      expect: () => [
        isA<AuthState>().having(
          (s) => s.verificationCheck,
          'check',
          VerificationCheck.checking,
        ),
        isA<AuthState>()
            .having((s) => s.status, 'status', AuthStatus.unverified)
            .having(
              (s) => s.verificationCheck,
              'check',
              VerificationCheck.notVerified,
            ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'reports a readable error when the check fails',
      setUp: () =>
          when(() => repository.reloadUser())
              .thenThrow(AuthFailure.fromCode('network-request-failed')),
      build: () => AuthBloc(repository),
      seed: () => AuthState.fromUser(unverified),
      act: (bloc) => bloc.add(const AuthVerificationCheckRequested()),
      skip: 1,
      expect: () => [
        isA<AuthState>()
            .having(
              (s) => s.verificationCheck,
              'check',
              VerificationCheck.failed,
            )
            .having((s) => s.errorMessage, 'message', contains('offline')),
      ],
    );
  });
}
