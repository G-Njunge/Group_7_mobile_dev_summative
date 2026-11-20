import '../session/session_source.dart';

/// Every top-level path in the app. Feature owners add sub-routes (e.g.
/// `/home/result`) under their own path so the redirect rules below still
/// apply to them.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const landing = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const verifyEmail = '/verify-email';

  static const home = '/home';
  static const history = '/history';
  static const pharmacies = '/pharmacies';
  static const report = '/report';
  static const myReports = '/my-reports';
  static const profile = '/profile';
  static const settings = '/settings';

  /// Reachable only while signed out.
  static const publicRoutes = [landing, login, register, forgotPassword];

  /// Screens of the auth flow itself, never a valid place for a signed-in user.
  static const _authFlow = [...publicRoutes, splash, verifyEmail];

  static bool isPublic(String location) => _matchesAny(location, publicRoutes);

  static bool _matchesAny(String location, List<String> roots) =>
      roots.any((root) => location == root || location.startsWith('$root/'));

  /// Where the router should send the user, or `null` to stay on [location].
  ///
  /// - unknown: wait on the splash screen
  /// - signed out: public screens only, otherwise the landing page
  /// - unverified: the verify-email screen only
  /// - signed in: anything except the auth flow, which goes to home
  static String? redirect(SessionStatus status, String location) {
    final target = switch (status) {
      SessionStatus.unknown => splash,
      SessionStatus.signedOut => isPublic(location) ? location : landing,
      SessionStatus.unverified => verifyEmail,
      SessionStatus.signedIn =>
        _matchesAny(location, _authFlow) ? home : location,
    };
    return target == location ? null : target;
  }
}
