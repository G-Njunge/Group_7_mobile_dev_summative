import 'package:flutter/material.dart';

import '../widgets/auth_band_scaffold.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_colors.dart';

/// A3 Verify email.
///
/// [resendSecondsLeft] is the resend cooldown: while it's set, the resend
/// button is disabled and shows a countdown. The AuthBloc provides both
/// values and handles the buttons in Phase 2.
class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({
    super.key,
    required this.email,
    this.resendSecondsLeft,
  });

  final String email;
  final int? resendSecondsLeft;

  @override
  Widget build(BuildContext context) {
    final cooldown = resendSecondsLeft;

    return AuthBandScaffold(
      badge: const AuthIconBadge(icon: Icons.mark_email_unread_outlined),
      child: Column(
        children: [
          const AuthHeading(title: 'Verify your email', centered: true),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: 'Tap the link we sent to\n',
              children: [
                TextSpan(
                  text: email,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AuthColors.text, height: 1.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'You need a verified email before you can scan and save results.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AuthColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'I’ve verified',
            // Phase 2: reloads the user and re-checks emailVerified.
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: cooldown == null
                ? 'Resend email'
                : 'Resend email in ${_formatSeconds(cooldown)}',
            // Phase 2: resends the verification email.
            onPressed: cooldown == null ? () {} : null,
          ),
          const SizedBox(height: 8),
          AuthLinkRow(
            prompt: 'Wrong email?',
            linkLabel: 'Change it',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );
  }

  static String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }
}
