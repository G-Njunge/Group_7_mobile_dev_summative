import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../bloc/form_status.dart';
import '../bloc/google_sign_in_cubit.dart';
import 'auth_colors.dart';
import 'auth_snackbar.dart';
import 'neumorphic.dart';

/// "or" divider plus a "Continue with Google" button. Self-contained: it
/// creates its own [GoogleSignInCubit] and shows its own error snackbar, so
/// Login and Register can both just drop it in.
class ContinueWithGoogle extends StatelessWidget {
  const ContinueWithGoogle({super.key, this.enabled = true});

  /// Lets the page lock this button while its own form is submitting.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<GoogleSignInCubit>(),
      child: BlocConsumer<GoogleSignInCubit, GoogleSignInState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            current.status == FormStatus.failure,
        listener: (context, state) =>
            showAuthSnackBar(context, state.errorMessage!),
        builder: (context, state) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _OrDivider(),
            _GoogleButton(
              loading: state.isSubmitting,
              onPressed: enabled
                  ? context.read<GoogleSignInCubit>().signIn
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: AuthColors.shadowDark)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text('or', style: TextStyle(color: AuthColors.textMuted)),
          ),
          Expanded(child: Divider(color: AuthColors.shadowDark)),
        ],
      ),
    );
  }
}

/// Raised neumorphic pill with the Google "G", per Google's sign-in button
/// guidance (logo + "Continue with Google").
class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.loading, required this.onPressed});

  final bool loading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final active = onPressed != null && !loading;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        boxShadow: active ? Neu.raised(distance: 5, blur: 12) : const [],
      ),
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AuthColors.surface,
          foregroundColor: AuthColors.text,
          disabledBackgroundColor: AuthColors.surface,
          disabledForegroundColor: AuthColors.textMuted,
          minimumSize: const Size(48, 52),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AuthColors.primary,
                ),
              )
            else
              const _GoogleG(size: 20),
            const SizedBox(width: 12),
            // Flexible so large text settings shrink the label, not overflow.
            Flexible(
              child: Text(
                loading ? 'Connecting to Google…' : 'Continue with Google',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The four-colour Google "G", drawn so no image asset is needed.
class _GoogleG extends StatelessWidget {
  const _GoogleG({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Google',
      child: CustomPaint(size: Size.square(size), painter: _GooglePainter()),
    );
  }
}

class _GooglePainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.2;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    Paint arc(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    double deg(double d) => d * math.pi / 180;

    // Angles go clockwise from 3 o'clock.
    canvas
      ..drawArc(rect, deg(-40), deg(-100), false, arc(_red)) // top
      ..drawArc(rect, deg(-140), deg(-80), false, arc(_yellow)) // left
      ..drawArc(rect, deg(-220), deg(-100), false, arc(_green)) // bottom
      ..drawArc(rect, deg(-320), deg(-40), false, arc(_blue)) // lower right
      // The blue crossbar.
      ..drawRect(
        Rect.fromLTWH(
          size.width / 2,
          size.height / 2 - stroke / 2,
          size.width / 2,
          stroke,
        ),
        Paint()..color = _blue,
      );
  }

  @override
  bool shouldRepaint(_GooglePainter oldDelegate) => false;
}
