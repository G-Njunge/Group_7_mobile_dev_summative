import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/form_status.dart';
import '../bloc/verify_email_cubit.dart';
import '../widgets/auth_band_scaffold.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_colors.dart';
import '../widgets/auth_snackbar.dart';

/// A3 Verify email. Shown by the AuthGate while the user is unverified.
///
/// - "I've verified" asks the [AuthBloc] to re-check; once verified, the
///   AuthGate moves on by itself.
/// - "Resend email" uses [VerifyEmailCubit], which adds a 60s cooldown.
/// - "Change it" logs out, so the user can register with another email.
class VerifyEmailPage extends StatelessWidget {
  const VerifyEmailPage({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<VerifyEmailCubit>(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) =>
                previous.verificationCheck != current.verificationCheck,
            listener: (context, state) {
              switch (state.verificationCheck) {
                case VerificationCheck.notVerified:
                  showAuthSnackBar(
                    context,
                    'Not verified yet. Tap the link in the email, then try '
                    'again.',
                    type: AuthSnackType.info,
                  );
                case VerificationCheck.failed:
                  showAuthSnackBar(context, state.errorMessage!);
                case VerificationCheck.idle || VerificationCheck.checking:
                  break;
              }
            },
          ),
          BlocListener<VerifyEmailCubit, VerifyEmailState>(
            listenWhen: (previous, current) =>
                previous.status != current.status,
            listener: (context, state) {
              if (state.status == FormStatus.success) {
                showAuthSnackBar(
                  context,
                  'We’ve sent a new link to $email.',
                  type: AuthSnackType.success,
                );
              } else if (state.status == FormStatus.failure) {
                showAuthSnackBar(context, state.errorMessage!);
              }
            },
          ),
        ],
        child: _VerifyEmailView(email: email),
      ),
    );
  }
}

class _VerifyEmailView extends StatelessWidget {
  const _VerifyEmailView({required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final checking = context.select(
      (AuthBloc bloc) =>
          bloc.state.verificationCheck == VerificationCheck.checking,
    );
    final resend = context.watch<VerifyEmailCubit>().state;

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
            loading: checking,
            loadingLabel: 'Checking…',
            onPressed: () => context.read<AuthBloc>().add(
              const AuthVerificationCheckRequested(),
            ),
          ),
          const SizedBox(height: 12),
          SecondaryButton(
            label: resend.secondsLeft > 0
                ? 'Resend email in ${_formatSeconds(resend.secondsLeft)}'
                : resend.status == FormStatus.submitting
                ? 'Sending…'
                : 'Resend email',
            onPressed: resend.canResend
                ? context.read<VerifyEmailCubit>().resend
                : null,
          ),
          const SizedBox(height: 8),
          AuthLinkRow(
            prompt: 'Wrong email?',
            linkLabel: 'Change it',
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthLogoutRequested()),
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
