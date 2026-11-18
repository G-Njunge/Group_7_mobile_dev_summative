import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

/// Thin wrapper around Firebase Auth, Google Sign-In and the `users`
/// collection.
///
/// No business rules here; the repository does that. This class only exists
/// so the repository can be tested with a mock instead of real Firebase.
class AuthRemoteDataSource {
  AuthRemoteDataSource({
    required this._auth,
    required this._firestore,
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleInit;

  static const usersCollection = 'users';

  /// The project's **Web** OAuth client ID (Firebase console > Authentication
  /// > Google > Web SDK configuration). Android needs it to get an ID token
  /// Firebase accepts. Not a secret.
  static const googleServerClientId =
      '183764806924-ui5qoko8lg1aspoiuvorlj8bse903emr.apps.googleusercontent.com';

  /// Firebase codes that mean the user closed the Google pop-up (web).
  static const _webCancelCodes = {
    'popup-closed-by-user',
    'cancelled-popup-request',
    'user-cancelled',
  };

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User> createAccount({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  Future<User> signIn({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!;
  }

  /// Signs in with Google. Returns `null` if the user cancelled.
  ///
  /// Web uses Firebase's pop-up. Android uses google_sign_in v7 to get an ID
  /// token, then signs in to Firebase with it.
  ///
  /// If the email already has a password account (and isn't @gmail.com),
  /// Firebase refuses with `account-exists-with-different-credential`. The
  /// Google credential is kept so the next password login can link it; see
  /// [linkPendingGoogle].
  Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      try {
        final credential = await _auth.signInWithPopup(GoogleAuthProvider());
        return credential.user;
      } on FirebaseAuthException catch (e) {
        if (_webCancelCodes.contains(e.code)) return null;
        _rememberForLinking(e, null);
        rethrow;
      }
    }

    await _initGoogle();
    final GoogleSignInAccount account;
    try {
      account = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        return null;
      }
      // Turn it into a Firebase-style error so the repository maps it like
      // every other auth error.
      throw FirebaseAuthException(
        code:
            e.code == GoogleSignInExceptionCode.clientConfigurationError ||
                e.code == GoogleSignInExceptionCode.providerConfigurationError
            ? 'google-sign-in-not-configured'
            : 'google-sign-in-failed',
        message: e.description,
      );
    }

    final googleCredential = GoogleAuthProvider.credential(
      idToken: account.authentication.idToken,
    );
    try {
      final credential = await _auth.signInWithCredential(googleCredential);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      _rememberForLinking(e, googleCredential);
      rethrow;
    }
  }

  /// Google credential waiting to be linked after a password login.
  AuthCredential? _pendingGoogleCredential;

  void _rememberForLinking(FirebaseAuthException e, AuthCredential? fallback) {
    if (e.code == 'account-exists-with-different-credential') {
      _pendingGoogleCredential = e.credential ?? fallback;
    }
  }

  /// After a password login, attaches the Google credential from a refused
  /// Google sign-in (if any), so both methods open the same account.
  /// Returns `true` if Google was linked.
  Future<bool> linkPendingGoogle(User user) async {
    final pending = _pendingGoogleCredential;
    if (pending == null) return false;
    _pendingGoogleCredential = null;
    await user.linkWithCredential(pending);
    return true;
  }

  /// Signs out of Firebase and, on Android, out of Google too, so the
  /// account picker shows again next time.
  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await _initGoogle();
        await _googleSignIn.signOut();
      } catch (_) {
        // Not signed in with Google, or Google Sign-In unavailable; the
        // Firebase sign-out below is what matters.
      }
    }
    await _auth.signOut();
  }

  /// google_sign_in v7 must be initialised exactly once before use.
  Future<void> _initGoogle() => _googleInit ??= _googleSignIn.initialize(
    serverClientId: googleServerClientId,
  );

  Future<void> updateDisplayName(User user, String name) =>
      user.updateDisplayName(name);

  Future<bool> userDocExists(String uid) async =>
      (await _firestore.collection(usersCollection).doc(uid).get()).exists;

  /// Writes the `users/{uid}` doc. `createdAt` is set by the server.
  Future<void> createUserDoc(UserModel user) => _firestore
      .collection(usersCollection)
      .doc(user.uid)
      .set({...user.toJson(), 'createdAt': FieldValue.serverTimestamp()});

  Future<void> deleteUser(User user) => user.delete();

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> sendEmailVerification(User user) => user.sendEmailVerification();

  /// Reloads the signed-in user and returns the fresh copy.
  Future<User?> reloadCurrentUser() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser;
  }
}
