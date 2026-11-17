import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

/// Thin wrapper around Firebase Auth and the `users` collection.
///
/// No error handling or business rules here; the repository does that. This
/// class only exists so the repository can be tested with a mock instead of
/// real Firebase.
class AuthRemoteDataSource {
  AuthRemoteDataSource({required this._auth, required this._firestore});

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  static const usersCollection = 'users';

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

  Future<void> signOut() => _auth.signOut();

  Future<void> updateDisplayName(User user, String name) =>
      user.updateDisplayName(name);

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
