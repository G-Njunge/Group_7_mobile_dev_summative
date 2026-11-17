import 'package:flutter/material.dart';

import '../widgets/auth_band_scaffold.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_text_field.dart';
import 'reset_link_sent_page.dart';

/// A1 Forgot password: form.
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBandScaffold(
      showBack: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeading(
            title: 'Reset your password',
            subtitle:
                'Enter the email you registered with. We’ll send you a link '
                'to choose a new password.',
          ),
          const SizedBox(height: 24),
          const AuthTextField(
            label: 'Email',
            hint: 'you@example.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: [AutofillHints.email],
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Send reset link',
            // Phase 2: the AuthBloc sends the email, then this screen moves
            // on with the real address.
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) =>
                    const ResetLinkSentPage(email: 'you@example.com'),
              ),
            ),
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
  }
}
