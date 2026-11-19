import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:hakikisha_summative/features/auth/data/models/user_model.dart';
import 'package:hakikisha_summative/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:hakikisha_summative/features/auth/domain/entities/app_user.dart';
import 'package:hakikisha_summative/features/auth/domain/failures/auth_failure.dart';
import 'package:mocktail/mocktail.dart';

class MockRemote extends Mock implements AuthRemoteDataSource {}

class MockUser extends Mock implements User {}

void main() {
  late MockRemote remote;
  late MockUser user;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(MockUser());
    registerFallbackValue(
      const UserModel(uid: '', fullName: '', email: '', authProvider: ''),
    );
  });

  setUp(() {
    remote = MockRemote();
    user = MockUser();
    repository = AuthRepositoryImpl(remote);

    when(() => user.uid).thenReturn('uid-123');
    when(() => user.email).thenReturn('amina.otieno@gmail.com');
    when(() => user.emailVerified).thenReturn(false);
    when(() => user.displayName).thenReturn('Amina Otieno');
    when(() => user.photoURL).thenReturn(null);
  });

  Future<AppUser> signUp() => repository.signUp(
    fullName: '  Amina Otieno ',
    email: ' amina.otieno@gmail.com ',
    phone: '0712 345 678',
    password: 'hakikisha2026',
  );

  group('signUp', () {
    setUp(() {
      when(
        () => remote.createAccount(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => user);
      when(() => remote.updateDisplayName(any(), any()))
          .thenAnswer((_) async {});
      when(() => remote.createUserDoc(any())).thenAnswer((_) async {});
      when(() => remote.sendEmailVerification(any())).thenAnswer((_) async {});
      when(() => remote.deleteUser(any())).thenAnswer((_) async {});
    });

    test('creates the account with a trimmed email', () async {
      await signUp();
      verify(
        () => remote.createAccount(
          email: 'amina.otieno@gmail.com',
          password: 'hakikisha2026',
        ),
      ).called(1);
    });

    test(
      'saves the users doc with contract fields and normalized phone',
      () async {
        await signUp();
        final saved =
            verify(() => remote.createUserDoc(captureAny())).captured.single
                as UserModel;
        expect(saved.uid, 'uid-123');
        expect(saved.fullName, 'Amina Otieno');
        expect(saved.email, 'amina.otieno@gmail.com');
        expect(saved.phone, '+254712345678');
        expect(saved.authProvider, 'password');
      },
    );

    test(
      'sends the verification email and returns an unverified user',
      () async {
        final result = await signUp();
        verify(() => remote.sendEmailVerification(user)).called(1);
        expect(
          result,
          const AppUser(
            uid: 'uid-123',
            email: 'amina.otieno@gmail.com',
            emailVerified: false,
            fullName: 'Amina Otieno',
          ),
        );
      },
    );

    test('deletes the new account if the users doc write fails', () async {
      when(() => remote.createUserDoc(any())).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
      );

      await expectLater(
        signUp(),
        throwsA(
          isA<AuthFailure>().having((f) => f.code, 'code', 'unavailable'),
        ),
      );
      verify(() => remote.deleteUser(user)).called(1);
      verifyNever(() => remote.sendEmailVerification(any()));
    });

    test('still succeeds if only the verification email fails', () async {
      when(() => remote.sendEmailVerification(any()))
          .thenThrow(FirebaseAuthException(code: 'too-many-requests'));
      await expectLater(signUp(), completes);
      verifyNever(() => remote.deleteUser(any()));
    });

    test('maps email-already-in-use to a readable failure', () async {
      when(
        () => remote.createAccount(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      await expectLater(
        signUp(),
        throwsA(AuthFailure.fromCode('email-already-in-use')),
      );
    });
  });

  group('logIn', () {
    setUp(
      () =>
          when(() => remote.linkPendingGoogle(any()))
              .thenAnswer((_) async => false),
    );

    test('returns the signed-in user', () async {
      when(
        () => remote.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => user);

      final result = await repository.logIn(
        email: 'amina.otieno@gmail.com ',
        password: 'secret',
      );

      expect(result.uid, 'uid-123');
      verify(
        () =>
            remote.signIn(email: 'amina.otieno@gmail.com', password: 'secret'),
      ).called(1);
    });

    test('links a Google account that was refused for this email', () async {
      when(
        () => remote.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => user);

      await repository.logIn(email: 'g.njunge@alustudent.com', password: 'pw');

      verify(() => remote.linkPendingGoogle(user)).called(1);
    });

    test('still logs in if linking Google fails', () async {
      when(
        () => remote.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => user);
      when(() => remote.linkPendingGoogle(any()))
          .thenThrow(FirebaseAuthException(code: 'credential-already-in-use'));

      final result = await repository.logIn(email: 'a@b.com', password: 'pw');

      expect(result.uid, 'uid-123');
    });

    test('maps invalid-credential to "Wrong email or password"', () async {
      when(
        () => remote.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'invalid-credential'));

      await expectLater(
        repository.logIn(email: 'a@b.com', password: 'nope'),
        throwsA(
          isA<AuthFailure>().having(
            (f) => f.message,
            'message',
            'Wrong email or password. Try again.',
          ),
        ),
      );
    });
  });

  group('session and verification', () {
    test('authStateChanges maps Firebase users to AppUser and null', () {
      when(() => remote.authStateChanges())
          .thenAnswer((_) => Stream.fromIterable([user, null]));

      expect(
        repository.authStateChanges(),
        emitsInOrder([
          isA<AppUser>().having((u) => u.uid, 'uid', 'uid-123'),
          isNull,
        ]),
      );
    });

    test('reloadUser returns the fresh emailVerified value', () async {
      when(() => user.emailVerified).thenReturn(true);
      when(() => remote.reloadCurrentUser()).thenAnswer((_) async => user);

      final result = await repository.reloadUser();
      expect(result?.emailVerified, isTrue);
    });

    test('sendEmailVerification fails politely when signed out', () async {
      when(() => remote.currentUser).thenReturn(null);
      await expectLater(
        repository.sendEmailVerification(),
        throwsA(isA<AuthFailure>()),
      );
    });

    test('sendPasswordResetEmail trims the email', () async {
      when(() => remote.sendPasswordResetEmail(any())).thenAnswer((_) async {});
      await repository.sendPasswordResetEmail(' amina@gmail.com ');
      verify(() => remote.sendPasswordResetEmail('amina@gmail.com')).called(1);
    });
  });
}
