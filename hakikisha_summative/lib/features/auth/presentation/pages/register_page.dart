import 'package:flutter/material.dart';

import '../widgets/auth_band_scaffold.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_text_field.dart';
import 'login_page.dart';
import 'verify_email_page.dart';

/// 04 Register.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBandScaffold(
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeading(
              title: 'Create account',
              subtitle: 'It takes less than a minute.',
            ),
            const SizedBox(height: 24),
            const AuthTextField(
              label: 'Full name',
              hint: 'Amina Wanjiru',
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              autofillHints: [AutofillHints.name],
            ),
            const SizedBox(height: 16),
            const AuthTextField(
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: [AutofillHints.email],
            ),
            const SizedBox(height: 16),
            const AuthTextField(
              label: 'Phone',
              hint: '+254 7XX XXX XXX',
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: [AutofillHints.telephoneNumber],
            ),
            const SizedBox(height: 16),
            const AuthTextField(
              label: 'Password',
              hint: '••••••••',
              obscure: true,
              textInputAction: TextInputAction.done,
              autofillHints: [AutofillHints.newPassword],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Create account',
              loadingLabel: 'Creating account…',
              // Phase 2: the AuthBloc creates the account, then this screen
              // moves on with the real address.
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      const VerifyEmailPage(email: 'you@example.com'),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AuthLinkRow(
              prompt: 'Already registered?',
              linkLabel: 'Log in',
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
