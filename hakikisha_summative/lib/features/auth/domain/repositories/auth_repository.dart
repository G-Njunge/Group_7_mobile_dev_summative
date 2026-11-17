import '../entities/app_user.dart';

/// Everything the auth feature can do. The AuthBloc depends on this
/// interface (not on Firebase), which is what lets tests mock it.
///
/// Every method that can fail throws an `AuthFailure` with a readable
/// message.
abstract interface class AuthRepository {
  /// Emits the signed-in user, or `null` when signed out. Emits on app start
  /// too, which is how the session survives a restart.
  Stream<AppUser?> authStateChanges();

  /// The user signed in right now, if any.
  AppUser? get currentUser;

  /// Creates the account, saves the `users` doc and sends the verification
  /// email. If saving the doc fails, the new account is deleted again so no
  /// half-created user is left behind.
  Future<AppUser> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  });

  Future<AppUser> logIn({required String email, required String password});

  Future<void> logOut();

  /// Sends a reset link. Succeeds even for unregistered emails, because
  /// Firebase's email-enumeration protection hides whether an account exists.
  Future<void> sendPasswordResetEmail(String email);

  /// Sends the verification email to the signed-in user again.
  Future<void> sendEmailVerification();

  /// Re-fetches the signed-in user from Firebase, e.g. after they tap the
  /// verification link. `authStateChanges()` doesn't fire when an email gets
  /// verified, so the bloc calls this and checks `emailVerified` itself.
  Future<AppUser?> reloadUser();
}
