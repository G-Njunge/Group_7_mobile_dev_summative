import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/auth/domain/failures/auth_failure.dart';

void main() {
  group('AuthFailure.fromCode', () {
    test('wrong password and unknown email give the same message', () {
      // Same message on purpose, so nobody can tell which emails have
      // accounts.
      const expected = 'Wrong email or password. Try again.';
      expect(AuthFailure.fromCode('invalid-credential').message, expected);
      expect(AuthFailure.fromCode('wrong-password').message, expected);
      expect(AuthFailure.fromCode('user-not-found').message, expected);
    });

    test('maps the required codes to specific messages', () {
      expect(
        AuthFailure.fromCode('email-already-in-use').message,
        contains('already exists'),
      );
      expect(
        AuthFailure.fromCode('weak-password').message,
        contains('stronger password'),
      );
      expect(
        AuthFailure.fromCode('too-many-requests').message,
        contains('Too many attempts'),
      );
      expect(
        AuthFailure.fromCode('network-request-failed').message,
        contains('offline'),
      );
    });

    test('treats Firestore "unavailable" as offline', () {
      expect(
        AuthFailure.fromCode('unavailable').message,
        AuthFailure.fromCode('network-request-failed').message,
      );
    });

    test('falls back to a generic message for unknown codes', () {
      final failure = AuthFailure.fromCode('some-new-code');
      expect(failure.message, 'Something went wrong. Please try again.');
      expect(failure.code, 'some-new-code');
    });
  });
}
