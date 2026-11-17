import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/auth/data/models/user_model.dart';

void main() {
  // Local time, because Timestamp.toDate() returns local time.
  final createdAt = DateTime(2026, 11, 17, 9, 41);

  final user = UserModel(
    uid: 'uid-123',
    fullName: 'Amina Otieno',
    email: 'amina.otieno@gmail.com',
    phone: '+254712345678',
    authProvider: UserModel.providerPassword,
    photoUrl: 'https://example.com/amina.png',
    createdAt: createdAt,
  );

  final json = <String, dynamic>{
    'uid': 'uid-123',
    'fullName': 'Amina Otieno',
    'email': 'amina.otieno@gmail.com',
    'phone': '+254712345678',
    'authProvider': 'password',
    'photoUrl': 'https://example.com/amina.png',
    'createdAt': Timestamp.fromDate(createdAt),
  };

  test('toJson uses the exact Firestore contract field names', () {
    expect(user.toJson().keys.toSet(), {
      'uid',
      'fullName',
      'email',
      'phone',
      'authProvider',
      'photoUrl',
      'createdAt',
    });
    expect(user.toJson(), json);
  });

  test('fromJson reads every field', () {
    expect(UserModel.fromJson(json), user);
  });

  test('round-trips through toJson and fromJson', () {
    expect(UserModel.fromJson(user.toJson()), user);
  });

  test('handles a null createdAt (pending server timestamp)', () {
    final model = UserModel.fromJson({...json, 'createdAt': null});
    expect(model.createdAt, isNull);
    expect(model.toJson()['createdAt'], isNull);
  });

  test('allows a Google user with no phone or photo', () {
    final model = UserModel.fromJson({
      'uid': 'uid-456',
      'fullName': 'Brian Kamau',
      'email': 'brian@gmail.com',
      'authProvider': 'google',
    });
    expect(model.phone, isNull);
    expect(model.photoUrl, isNull);
    expect(model.authProvider, UserModel.providerGoogle);
  });
}
