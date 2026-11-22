import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/landing_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/verify_email_page.dart';
import '../../features/pharmacy/presentation/bloc/pharmacy_map_cubit.dart';
import '../../features/pharmacy/presentation/pages/pharmacy_map_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/bloc/profile_cubit.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../di/injection.dart';
import '../session/session_cubit.dart';
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
    _placeholder(AppRoutes.home, 'Home'),
    // M3: history & profile
    _placeholder(AppRoutes.history, 'Scan history'),
    GoRoute(
      path: AppRoutes.profile,
      // BlocProvider owns the cubit, so it is closed when the page is left.
      // The router only shows this to signed-in users, so currentUser is set.
      builder: (_, _) => BlocProvider(
        create: (_) =>
            sl<ProfileCubit>()..start(sl<FirebaseAuth>().currentUser!.uid),
        child: const ProfilePage(),
      ),
    ), // M4: pharmacy map & reporting
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
    _placeholder(AppRoutes.report, 'Report a medicine'),
    _placeholder(AppRoutes.myReports, 'My reports'),
    // M5: settings
    GoRoute(path: AppRoutes.settings, builder: (_, _) => const SettingsPage()),
  ],
);

GoRoute _placeholder(String path, String title, {bool drawer = true}) =>
    GoRoute(
      path: path,
      builder: (_, _) => PlaceholderPage(title: title, showDrawer: drawer),
    );

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
