import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:hakikisha_summative/features/profile/data/repositories/profile_repository_impl.dart';

class _FakeUser extends Fake implements User {
  bool deleted = false;

  @override
  Future<void> delete() async {
    deleted = true;
  }
}

class _FakeFirebaseAuth extends Fake implements FirebaseAuth {
  _FakeFirebaseAuth(this._user);

  final _FakeUser? _user;

  @override
  User? get currentUser => _user;
}

void main() {
  late FakeFirebaseFirestore firestore;
  late _FakeUser fakeUser;
  late ProfileRepositoryImpl repository;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    fakeUser = _FakeUser();
    repository = ProfileRepositoryImpl(
      ProfileRemoteDataSource(firestore, auth: _FakeFirebaseAuth(fakeUser)),
    );

    await firestore.collection('users').doc('u1').set({
      'uid': 'u1',
      'fullName': 'Amina Wanjiru',
      'email': 'amina@example.com',
      'phone': '+254712345678',
      'authProvider': 'password',
      'photoUrl': null,
      'createdAt': Timestamp.fromDate(DateTime(2026, 11, 1)),
    });
  });

  test('watchProfile turns the users document into a ProfileEntity', () async {
    final profile = await repository.watchProfile('u1').first;

    expect(profile, isNotNull);
    expect(profile!.uid, 'u1');
    expect(profile.fullName, 'Amina Wanjiru');
    expect(profile.phone, '+254712345678');
    expect(profile.authProvider, 'password');
    expect(profile.createdAt, DateTime(2026, 11, 1));
  });

  test('watchProfile gives null when the document does not exist', () async {
    final profile = await repository.watchProfile('nobody').first;

    expect(profile, isNull);
  });

  test('updateProfile changes the name and phone and nothing else', () async {
    await repository.updateProfile(
      uid: 'u1',
      fullName: 'Amina W',
      phone: '+254700000000',
    );

    final data = (await firestore.collection('users').doc('u1').get()).data()!;
    expect(data['fullName'], 'Amina W');
    expect(data['phone'], '+254700000000');
    expect(data['email'], 'amina@example.com');
    expect(data['authProvider'], 'password');
    expect(data['createdAt'], isA<Timestamp>());
  });

  test('updateProfile with no phone stores null', () async {
    await repository.updateProfile(uid: 'u1', fullName: 'Amina W');

    final data = (await firestore.collection('users').doc('u1').get()).data()!;
    expect(data['phone'], isNull);
  });

  test('deleteAccount deletes the users document and auth user', () async {
    await repository.deleteAccount('u1');

    final doc = await firestore.collection('users').doc('u1').get();
    expect(doc.exists, isFalse);
    expect(fakeUser.deleted, isTrue);
  });
}
