import 'package:equatable/equatable.dart';

/// An auth error with a message that's safe to show to the user.
///
/// The repository turns Firebase error codes into this, so the bloc and UI
/// never deal with Firebase exceptions directly.
class AuthFailure extends Equatable implements Exception {
  const AuthFailure(this.message, {this.code});

  /// Maps a Firebase Auth / Firestore error code to a readable message.
  factory AuthFailure.fromCode(String code) =>
      AuthFailure(_messages[code] ?? _fallback, code: code);

  final String message;

  /// The original Firebase code, kept for logging and tests.
  final String? code;

  static const _fallback = 'Something went wrong. Please try again.';
  static const _wrongCredentials = 'Wrong email or password. Try again.';
  static const _offline =
      'You’re offline. Check your connection and try again.';

  static const _messages = <String, String>{
    // Login. Firebase now returns invalid-credential for both a wrong
    // password and an unknown email; the older codes are kept just in case.
    'invalid-credential': _wrongCredentials,
    'wrong-password': _wrongCredentials,
    'user-not-found': _wrongCredentials,
    'invalid-email':
        'That email address doesn’t look right. Check it and '
        'try again.',
    'user-disabled':
        'This account has been disabled. Contact support for '
        'help.',
    // Register.
    'email-already-in-use':
        'An account already exists with this email. Try '
        'logging in instead.',
    'weak-password':
        'Choose a stronger password: at least 8 characters, '
        'with a letter and a number.',
    'operation-not-allowed': 'This sign-in method isn’t available right now.',
    // Shared.
    'too-many-requests':
        'Too many attempts. Wait a few minutes, then try '
        'again.',
    'network-request-failed': _offline,
    'unavailable': _offline, // Firestore's code for "can't reach the server".
    'requires-recent-login': 'For your security, log in again and then retry.',
    'permission-denied': 'We couldn’t save your details. Please try again.',
  };

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'AuthFailure($code): $message';
}
