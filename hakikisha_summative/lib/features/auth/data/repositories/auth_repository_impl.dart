import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/validators.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Stream<AppUser?> authStateChanges() =>
      _remote.authStateChanges().map(_toAppUser);

  @override
  AppUser? get currentUser => _toAppUser(_remote.currentUser);

  @override
  Future<AppUser> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) => _guard(() async {
    final name = fullName.trim();
    final user = await _remote.createAccount(
      email: email.trim(),
      password: password,
    );

    try {
      await _remote.updateDisplayName(user, name);
      await _remote.createUserDoc(
        UserModel(
          uid: user.uid,
          fullName: name,
          email: user.email ?? email.trim(),
          phone: normalizeKenyanPhone(phone) ?? phone.trim(),
          authProvider: UserModel.providerPassword,
        ),
      );
    } catch (_) {
      // Don't leave an Auth account without its users doc behind.
      try {
        await _remote.deleteUser(user);
      } catch (_) {
        // Best effort; the original error is the one worth reporting.
      }
      rethrow;
    }

    try {
      await _remote.sendEmailVerification(user);
    } on FirebaseException {
      // The account is fine; the user can tap "Resend email" on the
      // Verify email screen.
    }

    return AppUser(
      uid: user.uid,
      email: user.email ?? email.trim(),
      emailVerified: false,
      fullName: name,
      photoUrl: user.photoURL,
    );
  });

  @override
  Future<AppUser> logIn({required String email, required String password}) =>
      _guard(() async {
        final user = await _remote.signIn(
          email: email.trim(),
          password: password,
        );
        return _toAppUser(user)!;
      });

  @override
  Future<void> logOut() => _guard(_remote.signOut);

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      _guard(() => _remote.sendPasswordResetEmail(email.trim()));

  @override
  Future<void> sendEmailVerification() => _guard(() async {
    final user = _remote.currentUser;
    if (user == null) throw const AuthFailure(_signedOutMessage);
    await _remote.sendEmailVerification(user);
  });

  @override
  Future<AppUser?> reloadUser() =>
      _guard(() async => _toAppUser(await _remote.reloadCurrentUser()));

  static const _signedOutMessage = 'You’re signed out. Log in and try again.';

  static AppUser? _toAppUser(User? user) => user == null
      ? null
      : AppUser(
          uid: user.uid,
          email: user.email ?? '',
          emailVerified: user.emailVerified,
          fullName: user.displayName,
          photoUrl: user.photoURL,
        );

  /// Runs [action] and turns Firebase errors into [AuthFailure]s.
  /// (FirebaseAuthException is a FirebaseException, so one catch covers both
  /// Auth and Firestore errors.)
  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthFailure {
      rethrow;
    } on FirebaseException catch (e) {
      throw AuthFailure.fromCode(e.code);
    }
  }
}
