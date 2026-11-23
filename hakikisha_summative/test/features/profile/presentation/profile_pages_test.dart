import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/profile/domain/entities/profile_entity.dart';
import 'package:hakikisha_summative/features/profile/domain/repositories/profile_repository.dart';
import 'package:hakikisha_summative/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:hakikisha_summative/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:hakikisha_summative/features/profile/presentation/pages/profile_page.dart';

import '../../../helpers/pump_app.dart';

/// A stand-in repository: the test decides when and what it "sends".
class _FakeRepo implements ProfileRepository {
  final controller = StreamController<ProfileEntity?>();

  @override
  Stream<ProfileEntity?> watchProfile(String uid) => controller.stream;

  @override
  Future<void> updateProfile({
    required String uid,
    required String fullName,
    String? phone,
    String? photoUrl,
  }) async {}

  @override
  Future<void> deleteAccount(String uid) async {}
}

final _profile = ProfileEntity(
  uid: 'u1',
  fullName: 'Amina Wanjiru',
  email: 'amina@example.com',
  phone: '+254712345678',
  authProvider: 'password',
  createdAt: DateTime(2026, 11, 1),
);

/// Pumps [page] on a 360x800 phone with a ProfileCubit that has loaded
/// [_profile].
Future<void> _pumpWithProfile(WidgetTester tester, Widget page) async {
  final repo = _FakeRepo();
  final cubit = ProfileCubit(repo)..start('u1');
  addTearDown(() async {
    await cubit.close();
    await repo.controller.close();
  });

  tester.view
    ..physicalSize = const Size(360, 800)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpPage(
    page,
    providers: [BlocProvider<ProfileCubit>.value(value: cubit)],
    settle: false,
  );
  repo.controller.add(_profile);
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('profile page shows the name, email, phone and sign-in method', (
    tester,
  ) async {
    await _pumpWithProfile(tester, const ProfilePage());

    expect(find.text('Amina Wanjiru'), findsOneWidget);
    expect(find.text('amina@example.com'), findsOneWidget);
    expect(find.text('+254712345678'), findsOneWidget);
    expect(find.text('Email and password'), findsOneWidget);
    expect(find.text('Edit profile'), findsOneWidget);
  });

  testWidgets('edit page rejects an empty name', (tester) async {
    await _pumpWithProfile(tester, const EditProfilePage());

    await tester.enterText(find.byType(TextField).first, '');
    await tester.tap(find.text('Save changes'));
    await tester.pump();

    expect(find.text('Enter your full name.'), findsOneWidget);
  });

  testWidgets('edit page rejects a phone that is not a Kenyan number', (
    tester,
  ) async {
    await _pumpWithProfile(tester, const EditProfilePage());

    await tester.enterText(find.byType(TextField).at(2), 'abc123');
    await tester.tap(find.text('Save changes'));
    await tester.pump();

    expect(
      find.text('Enter a Kenyan mobile number, like 0712 345 678.'),
      findsOneWidget,
    );
  });
}
