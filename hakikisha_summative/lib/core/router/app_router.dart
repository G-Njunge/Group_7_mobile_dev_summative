import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/landing_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/history/presentation/bloc/history_cubit.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/pharmacy/presentation/bloc/pharmacy_map_cubit.dart';
import '../../features/pharmacy/presentation/pages/pharmacy_map_page.dart';
import '../../features/profile/presentation/bloc/profile_cubit.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/report/domain/entities/report_entity.dart';
import '../../features/report/presentation/pages/counterfeit_report_page.dart';
import '../../features/report/presentation/pages/my_reports_page.dart';
import '../../features/scan/domain/repositories/scan_repository.dart';
import '../../features/scan/presentation/bloc/scan_bloc.dart';
import '../../features/scan/presentation/pages/home_scan_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../di/injection.dart';
import '../session/session_cubit.dart';
import '../widgets/app_scaffold.dart';
import 'app_routes.dart';
import 'placeholder_page.dart';

/// Builds the app's router. Redirects run on every navigation and whenever
/// [session] changes, so signing in or out moves the user automatically and
/// logged-out users can never open a private screen.
///
/// The auth screens read the app-wide `AuthBloc`, which `main.dart` provides
/// above the router.
///
/// Feature owners: replace your `PlaceholderPage` with your real page and add
/// sub-routes under your own path.
GoRouter createAppRouter(SessionCubit session) => GoRouter(
  initialLocation: AppRoutes.splash,
  refreshListenable: _StreamListenable(session.stream),
  redirect: (_, state) =>
      AppRoutes.redirect(session.state, state.matchedLocation),
  routes: [
    // M1: auth & onboarding
    _placeholder(AppRoutes.splash, 'Hakikisha', drawer: false),
    GoRoute(path: AppRoutes.landing, builder: (_, _) => const LandingPage()),
    GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
    GoRoute(path: AppRoutes.register, builder: (_, _) => const RegisterPage()),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (_, _) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: AppRoutes.verifyEmail,
      builder: (context, _) => VerifyEmailPage(
        email: context.select((AuthBloc bloc) => bloc.state.user?.email) ?? '',
      ),
    ),
    // M2: scan & verification
    GoRoute(
      path: AppRoutes.home,
      builder: (context, _) {
        final user = context.select((AuthBloc bloc) => bloc.state.user);
        // On a cold start the AuthBloc can be a frame behind the session.
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final firstName = (user.fullName ?? user.email)
            .trim()
            .split(RegExp(r'\s+'))
            .first;
        // BlocProvider owns the ScanBloc, so it's closed when Home is left.
        // AppScaffold gives Home the shared frame and the drawer.
        return BlocProvider(
          create: (_) => sl<ScanBloc>(),
          child: AppScaffold(
            showLogo: true,
            maxContentWidth: null,
            body: HomeScanPage(
              userFirstName: firstName,
              userId: user.uid,
              scanRepository: sl<ScanRepository>(),
              onOpenPharmacyMap: () => context.go(AppRoutes.pharmacies),
              // Carry what the scan found into the report form.
              onOpenReport: ({medicineName, batchNumber}) => context.go(
                AppRoutes.reportFor(
                  medicineName: medicineName,
                  batchNumber: batchNumber,
                ),
              ),
              onOpenHistory: () => context.go(AppRoutes.history),
            ),
          ),
        );
      },
    ),
    // M3: history & profile
    GoRoute(
      path: AppRoutes.history,
      // BlocProvider owns the cubit, so it's closed when the page is left.
      builder: (context, _) => _forUser(
        context,
        (uid) => BlocProvider(
          create: (_) => sl<HistoryCubit>()..start(uid),
          child: const HistoryPage(),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, _) => _forUser(
        context,
        (uid) => BlocProvider(
          create: (_) => sl<ProfileCubit>()..start(uid),
          child: const ProfilePage(),
        ),
      ),
    ),
    // M4: pharmacy map & reporting
    GoRoute(
      path: AppRoutes.pharmacies,
      // BlocProvider owns the cubit, so it's closed when the map is left.
      builder: (_, _) => BlocProvider(
        create: (_) => sl<PharmacyMapCubit>(),
        child: Builder(
          builder: (context) =>
              PharmacyMapPage(cubit: context.read<PharmacyMapCubit>()),
        ),
      ),
    ),
    GoRoute(
      path: AppRoutes.report,
      builder: (context, state) {
        final query = state.uri.queryParameters;
        return _forUser(
          context,
          (uid) => CounterfeitReportPage(
            userId: uid,
            prefill: ReportDraft(
              medicineName: query[AppRoutes.reportMedicineParam] ?? '',
              batchNumber: query[AppRoutes.reportBatchParam],
            ),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.myReports,
      builder: (context, _) =>
          _forUser(context, (uid) => MyReportsPage(userId: uid)),
    ),
    // M5: settings
    GoRoute(path: AppRoutes.settings, builder: (_, _) => const SettingsPage()),
  ],
);

GoRoute _placeholder(String path, String title, {bool drawer = true}) =>
    GoRoute(
      path: path,
      builder: (_, _) => PlaceholderPage(title: title, showDrawer: drawer),
    );

/// Builds a signed-in page for the current user's uid. On a cold start the
/// `AuthBloc` can be a frame behind the session, so this shows a spinner
/// until the user arrives instead of starting a page with no uid.
Widget _forUser(BuildContext context, Widget Function(String uid) page) {
  final uid = context.select((AuthBloc bloc) => bloc.state.user?.uid);
  return uid == null
      ? const Scaffold(body: Center(child: CircularProgressIndicator()))
      : page(uid);
}

/// Turns a stream into a [Listenable] for `refreshListenable`. The router
/// lives as long as the app, so the subscription does too.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<Object?> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<Object?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
