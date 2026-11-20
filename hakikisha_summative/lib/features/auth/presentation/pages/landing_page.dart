// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../widgets/auth_buttons.dart';
import '../widgets/auth_colors.dart';
import '../widgets/waves_background.dart';
import 'login_page.dart';
import 'register_page.dart';

/// 02 Landing: first screen for signed-out users.
///
/// Portrait: headline, pitch, photo and button stacked and centred.
/// Landscape: text and button on the left, photo on the right.
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  void _openLogin(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const LoginPage()));

  void _openRegister(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const RegisterPage()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WavesBackground(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(
                onLogin: () => _openLogin(context),
                onRegister: () => _openRegister(context),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > constraints.maxHeight;
                    final tryButton = PrimaryButton(
                      label: 'Try Hakikisha',
                      onPressed: () => _openRegister(context),
                      expand: false,
                      radius: 12,
                    );

                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                            child: wide
                                ? Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const _Headline(centered: false),
                                            const SizedBox(height: 16),
                                            const _Pitch(centered: false),
                                            const SizedBox(height: 24),
                                            tryButton,
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 32),
                                      const Expanded(
                                        child: _HeroImage(aspectRatio: 4 / 3),
                                      ),
                                    ],
                                  )
                                : ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 480,
                                    ),
                                    child: Column(
                                      children: [
                                        const _Headline(centered: true),
                                        const SizedBox(height: 16),
                                        const _Pitch(centered: true),
                                        const SizedBox(height: 24),
                                        const _HeroImage(aspectRatio: 16 / 10),
                                        const SizedBox(height: 28),
                                        tryButton,
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onLogin, required this.onRegister});

  final VoidCallback onLogin;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Image.asset(
            'assets/images/hakikisha-logo.png',
            height: 48,
            semanticLabel: 'Hakikisha logo',
          ),
          const Spacer(),
          TextButton(
            onPressed: onLogin,
            style: TextButton.styleFrom(
              foregroundColor: AuthColors.primary,
              minimumSize: const Size(48, 48),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
            child: const Text('Login'),
          ),
          const SizedBox(width: 8),
          PrimaryButton(
            label: 'Register',
            onPressed: onRegister,
            expand: false,
            radius: 12,
          ),
        ],
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.centered});

  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Know your medicine. Before you take it.',
      textAlign: centered ? TextAlign.center : TextAlign.start,
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
        color: AuthColors.primary,
        fontWeight: FontWeight.w800,
        height: 1.1,
      ),
    );
  }
}

class _Pitch extends StatelessWidget {
  const _Pitch({required this.centered});

  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hakikisha verifies packs against the official registry in seconds, '
      'flags counterfeit batches, and helps you find pharmacies you can '
      'trust.',
      textAlign: centered ? TextAlign.center : TextAlign.start,
      style: const TextStyle(color: AuthColors.text, fontSize: 15, height: 1.5),
    );
  }
}

/// Pills-around-a-face photo with rounded corners and a soft shadow.
class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.aspectRatio});

  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Image.asset(
            'assets/images/pills-face.png',
            fit: BoxFit.cover,
            // Keep the face in frame when the photo is cropped.
            alignment: const Alignment(0, -0.15),
            semanticLabel: 'A face surrounded by pills and capsules',
          ),
        ),
      ),
    );
  }
}
