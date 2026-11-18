import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/settings/presentation/pages/settings_page.dart';
import '../session/session_cubit.dart';
import 'app_routes.dart';
import 'placeholder_page.dart';

/// Builds the app's router. Redirects run on every navigation and whenever
/// [session] changes, so signing in or out moves the user automatically and
/// logged-out users can never open a private screen.
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
    _placeholder(AppRoutes.landing, 'Welcome', drawer: false),
    _placeholder(AppRoutes.login, 'Log in', drawer: false),
    _placeholder(AppRoutes.register, 'Create account', drawer: false),
    _placeholder(AppRoutes.forgotPassword, 'Forgot password', drawer: false),
    _placeholder(AppRoutes.verifyEmail, 'Verify your email', drawer: false),
    // M2: scan & verification
    _placeholder(AppRoutes.home, 'Home'),
    // M3: history & profile
    _placeholder(AppRoutes.history, 'Scan history'),
    _placeholder(AppRoutes.profile, 'Profile'),
    // M4: pharmacy map & reporting
    _placeholder(AppRoutes.pharmacies, 'Nearby pharmacies'),
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
