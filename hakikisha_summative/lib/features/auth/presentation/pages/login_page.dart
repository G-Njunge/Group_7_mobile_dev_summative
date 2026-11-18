import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../bloc/form_status.dart';
import '../bloc/login_cubit.dart';
import '../widgets/auth_band_scaffold.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_snackbar.dart';
import '../widgets/auth_text_field.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';

/// 03 Login. Provides a fresh [LoginCubit]; on success the AuthGate moves
/// on by itself.
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<LoginCubit>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Text controllers are UI-only; all decisions live in the cubit.
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<LoginCubit>().submit(
      email: _email.text,
      password: _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();

    return BlocConsumer<LoginCubit, LoginState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == FormStatus.failure,
      listener: (context, state) =>
          showAuthSnackBar(context, state.errorMessage!),
      builder: (context, state) {
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
                AuthTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  errorText: state.fieldErrors[AuthField.email],
                  onChanged: (_) => cubit.fieldEdited(AuthField.email),
                  enabled: !state.isSubmitting,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _password,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  errorText: state.fieldErrors[AuthField.password],
                  onChanged: (_) => cubit.fieldEdited(AuthField.password),
                  onSubmitted: (_) => _submit(),
                  enabled: !state.isSubmitting,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: AuthLinkButton(
                    label: 'Forgot password?',
                    onPressed: state.isSubmitting
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const ForgotPasswordPage(),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: 'Log in',
                  loading: state.isSubmitting,
                  loadingLabel: 'Logging in…',
                  onPressed: _submit,
                ),
                const SizedBox(height: 8),
                AuthLinkRow(
                  prompt: 'No account?',
                  linkLabel: 'Register',
                  onPressed: state.isSubmitting
                      ? null
                      : () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => const RegisterPage(),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
