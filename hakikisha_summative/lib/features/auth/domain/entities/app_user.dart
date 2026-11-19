import 'package:equatable/equatable.dart';

/// The signed-in user, as the rest of the app sees it.
///
/// Comes from Firebase Auth (not the `users` doc), so it's available as soon
/// as the auth state changes, without waiting for a Firestore read.
class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.email,
    required this.emailVerified,
    this.fullName,
    this.photoUrl,
  });

  final String uid;
  final String email;

  /// Email/password users must verify before using the app.
  final bool emailVerified;

  final String? fullName;
  final String? photoUrl;

  @override
  List<Object?> get props => [uid, email, emailVerified, fullName, photoUrl];
}
