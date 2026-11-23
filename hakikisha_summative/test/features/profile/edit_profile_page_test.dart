import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/profile/domain/entities/profile_entity.dart';
import 'package:hakikisha_summative/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:hakikisha_summative/features/profile/presentation/bloc/profile_state.dart';
import 'package:hakikisha_summative/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:mocktail/mocktail.dart';

class _MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

void main() {
  late _MockProfileCubit cubit;

  final sampleProfile = ProfileEntity(
    uid: 'u1',
    fullName: 'Erin Leyian',
    email: 'erin@example.com',
    phone: '+254704876902',
    authProvider: 'password',
    createdAt: DateTime(2026, 11, 1),
  );

  setUp(() {
    cubit = _MockProfileCubit();
    when(() => cubit.state).thenReturn(
      ProfileState(status: ProfileStatus.loaded, profile: sampleProfile),
    );
    when(() => cubit.deleteAccount()).thenAnswer((_) async {});
  });

  Widget buildSubject() {
    return MaterialApp(
      home: BlocProvider<ProfileCubit>.value(
        value: cubit,
        child: const EditProfilePage(),
      ),
    );
  }

  testWidgets(
    'tapping Delete account opens dialog and calls deleteAccount on confirm',
    (tester) async {
      await tester.pumpWidget(buildSubject());

      final deleteBtn = find.widgetWithText(OutlinedButton, 'Delete account');
      await tester.ensureVisible(deleteBtn);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      expect(find.text('Delete account?'), findsOneWidget);

      await tester.tap(find.text('Delete account').last);
      await tester.pumpAndSettle();

      verify(() => cubit.deleteAccount()).called(1);
    },
  );

  testWidgets('canceling Delete account dialog does not delete account', (
    tester,
  ) async {
    await tester.pumpWidget(buildSubject());

    final deleteBtn = find.widgetWithText(OutlinedButton, 'Delete account');
    await tester.ensureVisible(deleteBtn);
    await tester.tap(deleteBtn);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => cubit.deleteAccount());
  });

  testWidgets(
    'submitting valid form calls updateProfile and shows snackbar when saved',
    (tester) async {
      final controller = StreamController<ProfileState>();
      addTearDown(controller.close);

      when(
        () => cubit.updateProfile(
          fullName: any(named: 'fullName'),
          phone: any(named: 'phone'),
        ),
      ).thenAnswer((_) async {
        controller.add(
          ProfileState(status: ProfileStatus.saved, profile: sampleProfile),
        );
      });

      whenListen(
        cubit,
        controller.stream,
        initialState: ProfileState(
          status: ProfileStatus.loaded,
          profile: sampleProfile,
        ),
      );

      await tester.pumpWidget(buildSubject());

      final saveBtn = find.text('Save changes');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pump();

      verify(
        () => cubit.updateProfile(
          fullName: 'Erin Leyian',
          phone: '+254704876902',
        ),
      ).called(1);
      expect(find.text('Profile updated.'), findsOneWidget);
    },
  );

  testWidgets('shows error snackbar when ProfileStatus.error is emitted', (
    tester,
  ) async {
    whenListen(
      cubit,
      Stream.fromIterable([
        ProfileState(status: ProfileStatus.loaded, profile: sampleProfile),
        ProfileState(
          status: ProfileStatus.error,
          profile: sampleProfile,
          errorMessage: 'Could not delete your account.',
        ),
      ]),
      initialState: ProfileState(
        status: ProfileStatus.loaded,
        profile: sampleProfile,
      ),
    );

    await tester.pumpWidget(buildSubject());
    await tester.pump();

    expect(find.text('Could not delete your account.'), findsOneWidget);
  });
}
