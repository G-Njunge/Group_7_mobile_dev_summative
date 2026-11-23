import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/core/router/app_routes.dart';
import 'package:hakikisha_summative/core/session/session_source.dart';

void main() {
  group('AppRoutes.redirect', () {
    // (status, location, expected target or null to stay)
    final cases = <(SessionStatus, String, String?)>[
      // Unknown: wait on the splash screen.
      (SessionStatus.unknown, AppRoutes.splash, null),
      (SessionStatus.unknown, AppRoutes.home, AppRoutes.splash),

      // Signed out: only public screens.
      (SessionStatus.signedOut, AppRoutes.splash, AppRoutes.landing),
      (SessionStatus.signedOut, AppRoutes.landing, null),
      (SessionStatus.signedOut, AppRoutes.login, null),
      (SessionStatus.signedOut, AppRoutes.register, null),
      (SessionStatus.signedOut, '${AppRoutes.forgotPassword}/sent', null),
      (SessionStatus.signedOut, AppRoutes.home, AppRoutes.landing),
      (SessionStatus.signedOut, AppRoutes.settings, AppRoutes.landing),
      (SessionStatus.signedOut, AppRoutes.verifyEmail, AppRoutes.landing),
      // A path that merely starts with a public one is not public.
      (SessionStatus.signedOut, '/loginx', AppRoutes.landing),

      // Unverified: stuck on verify email until verified.
      (SessionStatus.unverified, AppRoutes.verifyEmail, null),
      (SessionStatus.unverified, AppRoutes.home, AppRoutes.verifyEmail),
      (SessionStatus.unverified, AppRoutes.login, AppRoutes.verifyEmail),

      // Signed in: private screens, never the auth flow.
      (SessionStatus.signedIn, AppRoutes.home, null),
      (SessionStatus.signedIn, '${AppRoutes.home}/result', null),
      (SessionStatus.signedIn, AppRoutes.settings, null),
      (SessionStatus.signedIn, AppRoutes.splash, AppRoutes.home),
      (SessionStatus.signedIn, AppRoutes.login, AppRoutes.home),
      (SessionStatus.signedIn, AppRoutes.verifyEmail, AppRoutes.home),
    ];

    for (final (status, location, expected) in cases) {
      test('${status.name} at $location -> ${expected ?? 'stay'}', () {
        expect(AppRoutes.redirect(status, location), expected);
      });
    }
  });

  group('AppRoutes.reportFor', () {
    test('carries the scanned medicine and batch as query parameters', () {
      final uri = Uri.parse(
        AppRoutes.reportFor(
          medicineName: 'Panadol 500mg',
          batchNumber: 'PA23-0871',
        ),
      );
      expect(uri.path, AppRoutes.report);
      expect(
        uri.queryParameters[AppRoutes.reportMedicineParam],
        'Panadol 500mg',
      );
      expect(uri.queryParameters[AppRoutes.reportBatchParam], 'PA23-0871');
    });

    test('leaves out blank values', () {
      expect(AppRoutes.reportFor(), AppRoutes.report);
      expect(AppRoutes.reportFor(medicineName: '  '), AppRoutes.report);
    });
  });
}
