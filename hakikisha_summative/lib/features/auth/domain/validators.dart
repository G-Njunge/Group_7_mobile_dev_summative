/// Form validators for the auth screens.
///
/// Each returns a short, polite message when the value is invalid, or `null`
/// when it's fine. They're plain Dart (no Flutter or Firebase), so they're
/// easy to unit test and other features (e.g. Edit profile) can reuse them.
library;

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
final _namePattern = RegExp(r"^[\p{L}][\p{L} '\-]*$", unicode: true);
final _letter = RegExp(r'[A-Za-z]');
final _digit = RegExp(r'\d');

/// Rwandan mobile numbers: 07XX XXX XXX (10 digits) or +2507XX… / 2507XX…
/// Covers MTN (078/079) and Airtel (072/073).
final _rwandanPhone = RegExp(r'^(?:\+250|250|0)(7\d{8})$');

/// Minimum password length for new accounts.
const minPasswordLength = 8;

String? validateFullName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return 'Enter your full name.';
  if (name.length < 2) return 'Your name looks too short.';
  if (!_namePattern.hasMatch(name)) {
    return 'Names can only use letters, spaces, hyphens and apostrophes.';
  }
  return null;
}

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email address.';
  if (!_emailPattern.hasMatch(email)) {
    return 'Enter a full email address, like name@gmail.com.';
  }
  return null;
}

/// Password rules for **new** accounts (Register).
String? validateNewPassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return 'Enter a password.';
  if (password.length < minPasswordLength) {
    return 'Use at least $minPasswordLength characters.';
  }
  if (!_letter.hasMatch(password)) return 'Add at least one letter.';
  if (!_digit.hasMatch(password)) return 'Add at least one number.';
  return null;
}

/// Login only checks that a password was typed. Strength rules don't apply
/// to existing passwords.
String? validateLoginPassword(String? value) =>
    (value ?? '').isEmpty ? 'Enter your password.' : null;

String? validatePhone(String? value) {
  final phone = value?.trim() ?? '';
  if (phone.isEmpty) return 'Enter your phone number.';
  if (normalizeRwandanPhone(phone) == null) {
    return 'Enter a Rwandan mobile number, like 0788 123 456.';
  }
  return null;
}

/// Turns any accepted format ("0788 123 456", "+250-788-123456", ...) into
/// `+250788123456`, the format saved in Firestore. Returns `null` if the
/// number isn't a valid Rwandan mobile number.
String? normalizeRwandanPhone(String value) {
  final compact = value.replaceAll(RegExp(r'[\s\-()]'), '');
  final match = _rwandanPhone.firstMatch(compact);
  return match == null ? null : '+250${match.group(1)}';
}
