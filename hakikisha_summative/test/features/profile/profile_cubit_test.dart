import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/profile/domain/entities/profile_entity.dart';
import 'package:hakikisha_summative/features/profile/domain/repositories/profile_repository.dart';
import 'package:hakikisha_summative/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:hakikisha_summative/features/profile/presentation/bloc/profile_state.dart';

/// A stand-in repository the test controls. No Firebase needed.
class FakeProfileRepository implements ProfileRepository {
  final controller = StreamController<ProfileEntity?>();
  bool shouldFail = false;
  String? savedName;
  String? savedPhone;
  bool accountDeleted = false;

  @override
  Stream<ProfileEntity?> watchProfile(String uid) => controller.stream;

  @override
  Future<void> updateProfile({
    required String uid,
    required String fullName,
    String? phone,
    String? photoUrl,
  }) async {
    if (shouldFail) throw Exception('boom');
    savedName = fullName;
    savedPhone = phone;
  }

  @override
  Future<void> deleteAccount(String uid) async {
    if (shouldFail) throw Exception('boom');
    accountDeleted = true;
  }
}

void main() {
  final profile = ProfileEntity(
    uid: 'u1',
    fullName: 'Amina Wanjiru',
    email: 'amina@example.com',
    phone: '+254712345678',
    authProvider: 'password',
    createdAt: DateTime(2026, 11, 1),
  );

  late FakeProfileRepository repo;
  late ProfileCubit cubit;

  setUp(() async {
    repo = FakeProfileRepository();
    cubit = ProfileCubit(repo)..start('u1');
    repo.controller.add(profile);
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() async {
    await cubit.close();
    await repo.controller.close();
  });

  test('loads the profile from the repository', () {
    expect(cubit.state.status, ProfileStatus.loaded);
    expect(cubit.state.profile, profile);
  });

  test(
    'a missing profile document puts the cubit in the error state',
    () async {
      repo.controller.add(null);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, ProfileStatus.error);
    },
  );

  test('updateProfile saves the trimmed name and a normalised phone', () async {
    await cubit.updateProfile(fullName: '  Amina W  ', phone: '0700 000 000');

    expect(repo.savedName, 'Amina W');
    expect(repo.savedPhone, '+254700000000');
    expect(cubit.state.status, ProfileStatus.saved);
  });

  test('an invalid phone is never sent to the repository', () async {
    await cubit.updateProfile(fullName: 'Amina', phone: 'abc');

    expect(repo.savedPhone, isNull);
  });

  test('a failed save ends in error but keeps the profile', () async {
    repo.shouldFail = true;
    await cubit.updateProfile(fullName: 'Amina');

    expect(cubit.state.status, ProfileStatus.error);
    expect(cubit.state.profile, profile);
  });

  test('deleteAccount ends in deleted', () async {
    await cubit.deleteAccount();

    expect(repo.accountDeleted, isTrue);
    expect(cubit.state.status, ProfileStatus.deleted);
  });

  test('a failed delete ends in error', () async {
    repo.shouldFail = true;
    await cubit.deleteAccount();

    expect(cubit.state.status, ProfileStatus.error);
  });
}
