import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../bloc/form_status.dart';
import '../bloc/register_cubit.dart';
import '../widgets/auth_band_scaffold.dart';
import '../widgets/auth_buttons.dart';
import '../widgets/auth_snackbar.dart';
import '../widgets/auth_text_field.dart';
import 'login_page.dart';

/// 04 Register. On success the new user is unverified, so the AuthGate shows
/// Verify email by itself.
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<RegisterCubit>(),
      child: const RegisterView(),
    );
  }
}

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<RegisterCubit>().submit(
      fullName: _fullName.text,
      email: _email.text,
      phone: _phone.text,
      password: _password.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RegisterCubit>();

    return BlocConsumer<RegisterCubit, RegisterState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == FormStatus.failure,
      listener: (context, state) =>
          showAuthSnackBar(context, state.errorMessage!),
      builder: (context, state) {
        final errors = state.fieldErrors;
        final busy = state.isSubmitting;

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
                AuthTextField(
                  label: 'Full name',
                  hint: 'Amina Wanjiru',
                  controller: _fullName,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  errorText: errors[AuthField.fullName],
                  onChanged: (_) => cubit.fieldEdited(AuthField.fullName),
                  enabled: !busy,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  errorText: errors[AuthField.email],
                  onChanged: (_) => cubit.fieldEdited(AuthField.email),
                  enabled: !busy,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Phone',
                  hint: '+254 7XX XXX XXX',
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  errorText: errors[AuthField.phone],
                  onChanged: (_) => cubit.fieldEdited(AuthField.phone),
                  enabled: !busy,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _password,
                  obscure: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  errorText: errors[AuthField.password],
                  successText: state.passwordStrong ? 'Strong password' : null,
                  onChanged: cubit.passwordChanged,
                  onSubmitted: (_) => _submit(),
                  enabled: !busy,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Create account',
                  loading: busy,
                  loadingLabel: 'Creating account…',
                  onPressed: _submit,
                ),
                const SizedBox(height: 8),
                AuthLinkRow(
                  prompt: 'Already registered?',
                  linkLabel: 'Log in',
                  onPressed: busy
                      ? null
                      : () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => const LoginPage(),
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
