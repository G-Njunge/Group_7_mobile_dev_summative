import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/auth/domain/validators.dart';

void main() {
  group('validateFullName', () {
    test('rejects empty and whitespace-only names', () {
      expect(validateFullName(null), 'Enter your full name.');
      expect(validateFullName('   '), 'Enter your full name.');
    });

    test('rejects a single character', () {
      expect(validateFullName('A'), 'Your name looks too short.');
    });

    test('rejects digits and symbols', () {
      expect(validateFullName('Amina 2'), isNotNull);
      expect(validateFullName('@mina'), isNotNull);
    });

    test('accepts real names, including hyphens and apostrophes', () {
      expect(validateFullName('Amina Otieno'), isNull);
      expect(validateFullName("Wanjiru O'Neil-Kamau"), isNull);
      expect(validateFullName('  Amina  '), isNull);
    });
  });

  group('validateEmail', () {
    test('rejects empty', () {
      expect(validateEmail(''), 'Enter your email address.');
    });

    test('rejects incomplete addresses with the design message', () {
      const message = 'Enter a full email address, like name@gmail.com.';
      expect(validateEmail('amina.otieno@gmail'), message);
      expect(validateEmail('amina.otieno'), message);
      expect(validateEmail('amina @gmail.com'), message);
      expect(validateEmail('@gmail.com'), message);
    });

    test('accepts valid addresses, ignoring surrounding spaces', () {
      expect(validateEmail('amina.otieno@gmail.com'), isNull);
      expect(validateEmail(' name@alustudent.com '), isNull);
    });
  });

  group('validateNewPassword', () {
    test('rejects empty', () {
      expect(validateNewPassword(''), 'Enter a password.');
    });

    test('rejects fewer than 8 characters', () {
      expect(validateNewPassword('abc123'), 'Use at least 8 characters.');
    });

    test('requires a letter and a number', () {
      expect(validateNewPassword('12345678'), 'Add at least one letter.');
      expect(validateNewPassword('abcdefgh'), 'Add at least one number.');
    });

    test('accepts 8+ characters with a letter and a number', () {
      expect(validateNewPassword('hakikisha2026'), isNull);
    });
  });

  group('validateLoginPassword', () {
    test('only checks that something was typed', () {
      expect(validateLoginPassword(''), 'Enter your password.');
      expect(validateLoginPassword('abc'), isNull);
    });
  });

  group('validatePhone and normalizeKenyanPhone', () {
    test('rejects empty and invalid numbers', () {
      expect(validatePhone(''), 'Enter your phone number.');
      expect(validatePhone('12345'), isNotNull);
      expect(validatePhone('0812345678'), isNotNull);
      expect(validatePhone('+255712345678'), isNotNull);
    });

    test('accepts common Kenyan formats', () {
      expect(validatePhone('0712345678'), isNull);
      expect(validatePhone('0112 345 678'), isNull);
      expect(validatePhone('+254 712 345 678'), isNull);
      expect(validatePhone('254-712-345678'), isNull);
    });

    test('normalizes to +254 format', () {
      expect(normalizeKenyanPhone('0712 345 678'), '+254712345678');
      expect(normalizeKenyanPhone('+254-112-345678'), '+254112345678');
      expect(normalizeKenyanPhone('254712345678'), '+254712345678');
      expect(normalizeKenyanPhone('not a number'), isNull);
    });
  });
}
