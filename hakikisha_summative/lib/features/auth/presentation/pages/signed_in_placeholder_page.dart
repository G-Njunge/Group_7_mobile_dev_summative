import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_colors.dart';
import '../widgets/logout_dialog.dart';
import '../widgets/waves_background.dart';

/// TEMPORARY stand-in for M2's Home screen, so sign-in and logout can be
/// tested end to end. Delete it once Home exists and point the AuthGate (or
/// the router) at Home instead.
class SignedInPlaceholderPage extends StatelessWidget {
  const SignedInPlaceholderPage({super.key});

  Future<void> _logOut(BuildContext context) async {
    final bloc = context.read<AuthBloc>();
    if (await showLogoutDialog(context)) {
      bloc.add(const AuthLogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthBloc bloc) => bloc.state.user);
    final firstName = (user?.fullName ?? '').split(' ').first;

    return Scaffold(
      body: WavesBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    firstName.isEmpty
                        ? 'HABARI'
                        : 'HABARI, ${firstName.toUpperCase()}',
                    style: const TextStyle(
                      color: AuthColors.textMuted,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You’re signed in',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AuthColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: AuthColors.text),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: 'Log out',
                    expand: false,
                    onPressed: () => _logOut(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
