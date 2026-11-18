import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../widgets/waves_background.dart';
import 'landing_page.dart';
import 'home_hub_page.dart';
import 'verify_email_page.dart';

/// Picks the first screen from the AuthBloc's status.
///
/// Temporary: once M5's go_router lands, this same logic becomes the router's
/// auth redirect.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      // When the status changes (logged in, verified, logged out), drop any
      // screens pushed on top (Login, Register, Forgot password) so the
      // back button can't return to them.
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, _) =>
          Navigator.of(context).popUntil((route) => route.isFirst),
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.user?.email != current.user?.email,
      builder: (context, state) => switch (state.status) {
        AuthStatus.unknown => const _Loading(),
        AuthStatus.unauthenticated => const LandingPage(),
        AuthStatus.unverified => VerifyEmailPage(
          email: state.user?.email ?? '',
        ),
        AuthStatus.authenticated => const HomeHubPage(),
      },
    );
  }
}

/// Shown for the split second before Firebase reports the auth state.
class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: WavesBackground(child: SizedBox.expand()));
  }
}
