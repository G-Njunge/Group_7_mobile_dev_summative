import 'package:material_ui/material_ui.dart';

import 'auth_colors.dart';
import 'neumorphic.dart';

/// Dark green button for the main action on a screen.
///
/// While [loading] is true the button dims, shows a spinner with
/// [loadingLabel] and ignores taps (design A4).
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.loadingLabel,
    this.expand = true,
    this.radius,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final String? loadingLabel;

  /// Stretch to the full available width.
  final bool expand;

  /// Corner radius. `null` gives a full pill shape.
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AuthColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AuthColors.primary.withValues(
          alpha: loading ? 0.75 : 0.4,
        ),
        disabledForegroundColor: Colors.white,
        minimumSize: const Size(48, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: _shape(radius),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
      child: loading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(loadingLabel ?? label),
              ],
            )
          : Text(label),
    );

    // Soft green glow below-right and a white highlight above-left.
    final raised = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 999),
        boxShadow: loading || onPressed == null
            ? const []
            : [
                BoxShadow(
                  color: AuthColors.primary.withValues(alpha: 0.35),
                  offset: const Offset(4, 6),
                  blurRadius: 14,
                ),
                const BoxShadow(
                  color: AuthColors.shadowLight,
                  offset: Offset(-4, -4),
                  blurRadius: 10,
                ),
              ],
      ),
      child: button,
    );

    return expand ? SizedBox(width: double.infinity, child: raised) : raised;
  }
}

/// Light neumorphic button for the secondary action ("Resend email",
/// "Stay logged in"). Raised when enabled, pressed-in when disabled.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;

  /// `null` disables the button (e.g. resend on cooldown).
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final button = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AuthColors.surface,
        foregroundColor: AuthColors.primary,
        disabledBackgroundColor: Colors.transparent,
        disabledForegroundColor: AuthColors.textMuted,
        minimumSize: const Size(48, 52),
        shape: _shape(null),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
      child: Text(label),
    );

    return SizedBox(
      width: double.infinity,
      child: enabled
          ? DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                boxShadow: Neu.raised(distance: 5, blur: 12),
              ),
              child: button,
            )
          : NeuInset(radius: 26, child: button),
    );
  }
}

/// Underlined green text link with a 48dp tap target.
class AuthLinkButton extends StatelessWidget {
  const AuthLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AuthColors.primary,
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
      ),
      child: Text(label),
    );
  }
}

/// "No account? Register" style row: plain prompt followed by a link.
class AuthLinkRow extends StatelessWidget {
  const AuthLinkRow({
    super.key,
    required this.prompt,
    required this.linkLabel,
    required this.onPressed,
  });

  final String prompt;
  final String linkLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(prompt, style: const TextStyle(color: AuthColors.text)),
        AuthLinkButton(label: linkLabel, onPressed: onPressed),
      ],
    );
  }
}

OutlinedBorder _shape(double? radius) => radius == null
    ? const StadiumBorder()
    : RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
