// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import 'auth_colors.dart';
import 'logo_badge.dart';
import 'neumorphic.dart';

/// Layout shared by Login, Register, Forgot password and Verify email:
/// green abstract image band on top, light form panel, and the band showing
/// again below the panel.
///
/// - [showBack] puts a back button in the band instead of the logo.
/// - [badge] is a round icon that overlaps the top edge of the panel
///   (Check your inbox / Verify email).
///
/// Scrolls, so the keyboard and landscape never cause overflow.
class AuthBandScaffold extends StatelessWidget {
  const AuthBandScaffold({
    super.key,
    required this.child,
    this.showBack = false,
    this.badge,
  });

  final Widget child;
  final bool showBack;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final bandHeight = landscape ? 88.0 : 170.0;

    return Scaffold(
      // Expand so the band fills the screen even when the form is short.
      body: Container(
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          color: AuthColors.primary,
          image: DecorationImage(
            image: AssetImage('assets/images/login-abstract.png'),
            fit: BoxFit.cover,
            // The source image is black and white; this tints it green.
            colorFilter: ColorFilter.mode(AuthColors.bandTint, BlendMode.color),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: bandHeight,
                  width: double.infinity,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: showBack ? const _BackButton() : const LogoBadge(),
                    ),
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topCenter,
                      children: [
                        Container(
                          width: double.infinity,
                          color: AuthColors.surface,
                          padding: EdgeInsets.fromLTRB(
                            24,
                            badge == null ? 28 : 56,
                            24,
                            28,
                          ),
                          child: child,
                        ),
                        if (badge != null) Positioned(top: -36, child: badge!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 56),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: Neu.raisedBox(radius: 14, distance: 4, blur: 10),
      child: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        style: IconButton.styleFrom(
          foregroundColor: AuthColors.primary,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: const Icon(Icons.chevron_left),
      ),
    );
  }
}

/// Raised neumorphic circle with the icon in a pressed-in centre, placed over
/// the panel's top edge.
class AuthIconBadge extends StatelessWidget {
  const AuthIconBadge({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      padding: const EdgeInsets.all(10),
      decoration: Neu.raisedCircle(distance: 6, blur: 14),
      child: NeuInset(
        radius: 28,
        color: AuthColors.surface,
        child: Center(child: Icon(icon, size: 28, color: AuthColors.primary)),
      ),
    );
  }
}

/// Screen title and subtitle at the top of an auth panel.
class AuthHeading extends StatelessWidget {
  const AuthHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.centered = false,
  });

  final String title;
  final String? subtitle;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final align = centered ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: align,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AuthColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            textAlign: align,
            style: const TextStyle(color: AuthColors.text, height: 1.4),
          ),
        ],
      ],
    );
  }
}
