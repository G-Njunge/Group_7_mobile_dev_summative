import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:hakikisha_summative/features/auth/data/models/user_model.dart';
import 'package:hakikisha_summative/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:hakikisha_summative/features/auth/domain/failures/auth_failure.dart';
import 'package:mocktail/mocktail.dart';

class MockRemote extends Mock implements AuthRemoteDataSource {}

class MockUser extends Mock implements User {}

void main() {
  late MockRemote remote;
  late MockUser user;
  late AuthRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      const UserModel(uid: '', fullName: '', email: '', authProvider: ''),
    );
  });

  setUp(() {
    remote = MockRemote();
    user = MockUser();
    repository = AuthRepositoryImpl(remote);

    when(() => user.uid).thenReturn('google-uid');
    when(() => user.email).thenReturn('brian.kamau@gmail.com');
    when(() => user.emailVerified).thenReturn(true);
    when(() => user.displayName).thenReturn('Brian Kamau');
    when(() => user.photoURL).thenReturn('https://example.com/brian.png');
    when(() => remote.createUserDoc(any())).thenAnswer((_) async {});
    when(() => remote.signOut()).thenAnswer((_) async {});
  });

  test('cancelled sign-in returns null and touches nothing', () async {
    when(() => remote.signInWithGoogle()).thenAnswer((_) async => null);

    expect(await repository.signInWithGoogle(), isNull);
    verifyNever(() => remote.userDocExists(any()));
    verifyNever(() => remote.createUserDoc(any()));
  });

  test('first Google sign-in creates the users doc', () async {
    when(() => remote.signInWithGoogle()).thenAnswer((_) async => user);
    when(() => remote.userDocExists('google-uid'))
        .thenAnswer((_) async => false);

    final result = await repository.signInWithGoogle();

    final saved =
        verify(() => remote.createUserDoc(captureAny())).captured.single
            as UserModel;
    expect(saved.uid, 'google-uid');
    expect(saved.fullName, 'Brian Kamau');
    expect(saved.email, 'brian.kamau@gmail.com');
    expect(saved.authProvider, 'google');
    expect(saved.phone, isNull);
    expect(saved.photoUrl, 'https://example.com/brian.png');
    // Google has already verified the address, so no Verify email screen.
    expect(result?.emailVerified, isTrue);
  });

  test('later Google sign-ins do not create a second doc', () async {
    when(() => remote.signInWithGoogle()).thenAnswer((_) async => user);
    when(() => remote.userDocExists('google-uid'))
        .thenAnswer((_) async => true);

    await repository.signInWithGoogle();

    verifyNever(() => remote.createUserDoc(any()));
  });

  test('signs back out if the users doc cannot be saved', () async {
    when(() => remote.signInWithGoogle()).thenAnswer((_) async => user);
    when(() => remote.userDocExists(any())).thenAnswer((_) async => false);
    when(() => remote.createUserDoc(any())).thenThrow(
      FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
    );

    await expectLater(
      repository.signInWithGoogle(),
      throwsA(isA<AuthFailure>().having((f) => f.code, 'code', 'unavailable')),
    );
    verify(() => remote.signOut()).called(1);
  });

  test('maps a Google configuration problem to a readable message', () async {
    when(
      () => remote.signInWithGoogle(),
    ).thenThrow(FirebaseAuthException(code: 'google-sign-in-not-configured'));

    await expectLater(
      repository.signInWithGoogle(),
      throwsA(
        isA<AuthFailure>().having(
          (f) => f.message,
          'message',
          contains('isn’t set up on this device'),
        ),
      ),
    );
  });
}
