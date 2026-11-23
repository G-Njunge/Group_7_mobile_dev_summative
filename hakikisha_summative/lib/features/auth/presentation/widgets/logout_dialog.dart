// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import 'auth_buttons.dart';
import 'auth_colors.dart';
import 'neumorphic.dart';

/// Shows the "Log out of Hakikisha?" dialog (design 11).
///
/// Returns `true` if the user chose "Log out", `false` otherwise.
/// M5's drawer calls this; the AuthBloc does the actual logout.
Future<bool> showLogoutDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => const LogoutDialog(),
  );
  return result ?? false;
}

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: Neu.raisedBox(radius: 24, distance: 8, blur: 20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/hakikisha-logo.png',
                height: 56,
                semanticLabel: 'Hakikisha logo',
              ),
              const SizedBox(height: 16),
              Text(
                'Log out of Hakikisha?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AuthColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your scan history stays saved to your account.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AuthColors.textMuted),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Log out',
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Stay logged in',
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
