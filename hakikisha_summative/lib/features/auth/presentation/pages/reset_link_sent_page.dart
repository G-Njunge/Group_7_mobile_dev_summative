// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../bloc/forgot_password_cubit.dart';
import '../bloc/form_status.dart';
import '../widgets/auth_band_scaffold.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_colors.dart';
import '../widgets/auth_snackbar.dart';

/// A2 Forgot password: check your inbox.
///
/// Firebase doesn't tell us whether the email is registered (that would let
/// anyone check who has an account), so the wording stays neutral.
class ResetLinkSentPage extends StatelessWidget {
  const ResetLinkSentPage({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ForgotPasswordCubit>(),
      child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == FormStatus.success) {
            showAuthSnackBar(
              context,
              'We’ve sent another link.',
              type: AuthSnackType.success,
            );
          } else if (state.status == FormStatus.failure) {
            showAuthSnackBar(context, state.errorMessage!);
          }
        },
        builder: (context, state) => AuthBandScaffold(
          badge: const AuthIconBadge(icon: Icons.mail_outline),
          child: Column(
            children: [
              const AuthHeading(title: 'Check your inbox', centered: true),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  text: 'If an account exists for\n',
                  children: [
                    TextSpan(
                      text: email,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(text: '\nwe’ve sent it a reset link.'),
                  ],
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AuthColors.text, height: 1.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'The link expires in 1 hour. Not there? Check your spam '
                'folder.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AuthColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Back to log in',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: state.isSubmitting ? 'Sending…' : 'Resend email',
                onPressed: state.isSubmitting
                    ? null
                    : () => context.read<ForgotPasswordCubit>().submit(email),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
