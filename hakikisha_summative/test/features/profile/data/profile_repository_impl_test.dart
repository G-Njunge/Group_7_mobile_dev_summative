import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:hakikisha_summative/features/profile/data/repositories/profile_repository_impl.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ProfileRepositoryImpl repository;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repository = ProfileRepositoryImpl(ProfileRemoteDataSource(firestore));

    await firestore.collection('users').doc('u1').set({
      'uid': 'u1',
      'fullName': 'Amina Wanjiru',
      'email': 'amina@example.com',
      'phone': '+250788123456',
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
    expect(profile.phone, '+250788123456');
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
      phone: '+250788000000',
    );

    final data = (await firestore.collection('users').doc('u1').get()).data()!;
    expect(data['fullName'], 'Amina W');
    expect(data['phone'], '+250788000000');
    expect(data['email'], 'amina@example.com');
    expect(data['authProvider'], 'password');
    expect(data['createdAt'], isA<Timestamp>());
  });

  test('updateProfile with no phone stores null', () async {
    await repository.updateProfile(uid: 'u1', fullName: 'Amina W');

    final data = (await firestore.collection('users').doc('u1').get()).data()!;
    expect(data['phone'], isNull);
  });

  test('deleteAccount is not available yet', () {
    expect(() => repository.deleteAccount('u1'), throwsUnsupportedError);
  });
}
