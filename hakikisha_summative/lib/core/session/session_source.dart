import 'package:firebase_auth/firebase_auth.dart';

/// Where the user is in the auth flow. The router redirects on this.
enum SessionStatus {
  /// Firebase hasn't reported yet (first frames after a cold start).
  unknown,
  signedOut,

  /// Signed in with email/password but the email isn't verified yet.
  unverified,
  signedIn,
}

/// App-wide view of the signed-in session. The router and drawer depend on
/// this interface, not on Firebase, so they can be tested with a fake.
abstract interface class SessionSource {
  /// Emits on sign-in, sign-out and user changes (e.g. email verified).
  Stream<SessionStatus> watch();

  /// The status right now, without waiting for the stream.
  SessionStatus get current;

  Future<void> signOut();
}

class FirebaseSessionSource implements SessionSource {
  FirebaseSessionSource(this._auth);

  final FirebaseAuth _auth;

  // userChanges (not authStateChanges) also fires when the user is reloaded,
  // which is how a freshly verified email is picked up.
  @override
  Stream<SessionStatus> watch() => _auth.userChanges().map(statusOf).distinct();

  @override
  SessionStatus get current => statusOf(_auth.currentUser);

  @override
  Future<void> signOut() => _auth.signOut();

  /// Google accounts arrive verified, so only unverified email/password
  /// accounts land on [SessionStatus.unverified].
  static SessionStatus statusOf(User? user) => switch (user) {
    null => SessionStatus.signedOut,
    User(emailVerified: true) => SessionStatus.signedIn,
    _ => SessionStatus.unverified,
  };
}
