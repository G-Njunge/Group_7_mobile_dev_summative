import 'package:material_ui/material_ui.dart';

import '../widgets/auth_band_scaffold.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/logout_dialog.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';

/// 03 Login.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthBandScaffold(
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthHeading(
              title: 'Welcome back',
              subtitle: 'Log in to keep verifying your medicine.',
            ),
            const SizedBox(height: 24),
            const AuthTextField(
              label: 'Email',
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: [AutofillHints.email],
            ),
            const SizedBox(height: 16),
            const AuthTextField(
              label: 'Password',
              hint: '••••••••',
              obscure: true,
              textInputAction: TextInputAction.done,
              autofillHints: [AutofillHints.password],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: AuthLinkButton(
                label: 'Forgot password?',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ForgotPasswordPage(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: 'Log in',
              // Temporary, so the logout dialog can be reviewed in Phase 1.
              // Phase 2: the AuthBloc logs the user in.
              onPressed: () => showLogoutDialog(context),
            ),
            const SizedBox(height: 8),
            AuthLinkRow(
              prompt: 'No account?',
              linkLabel: 'Register',
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const RegisterPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
