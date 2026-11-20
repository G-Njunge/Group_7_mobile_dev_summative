import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../bloc/forgot_password_cubit.dart';
import '../bloc/form_status.dart';
import '../widgets/auth_band_scaffold.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_snackbar.dart';
import '../widgets/auth_text_field.dart';
import 'reset_link_sent_page.dart';

/// A1 Forgot password: form. On success moves to Check your inbox.
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ForgotPasswordCubit>(),
      child: const ForgotPasswordView(),
    );
  }
}

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<ForgotPasswordCubit>().submit(_email.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == FormStatus.success) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => ResetLinkSentPage(email: state.sentTo!),
            ),
          );
        } else if (state.status == FormStatus.failure) {
          showAuthSnackBar(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        return AuthBandScaffold(
          showBack: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AuthHeading(
                title: 'Reset your password',
                subtitle:
                    'Enter the email you registered with. We’ll send you a '
                    'link to choose a new password.',
              ),
              const SizedBox(height: 24),
              AuthTextField(
                label: 'Email',
                hint: 'you@example.com',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                errorText: state.fieldErrors[AuthField.email],
                onChanged: (_) => context
                    .read<ForgotPasswordCubit>()
                    .fieldEdited(AuthField.email),
                onSubmitted: (_) => _submit(),
                enabled: !state.isSubmitting,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Send reset link',
                loading: state.isSubmitting,
                loadingLabel: 'Sending…',
                onPressed: _submit,
              ),
              const SizedBox(height: 8),
              AuthLinkRow(
                prompt: 'Remembered it?',
                linkLabel: 'Back to log in',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        );
      },
    );
  }
}
