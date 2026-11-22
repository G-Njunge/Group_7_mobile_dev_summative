import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import 'neumorphic.dart';

/// Dark green pill for the main action on a screen ("Log in", "Submit report").
///
/// While [loading] is true it shows a spinner and ignores taps, so a slow
/// network call can't be submitted twice.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.expand = true,
  });

  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  /// Stretch to the full available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final enabled = onPressed != null && !loading;
    return _RaisedPill(
      expand: expand,
      shadows: enabled
          ? [
              BoxShadow(
                color: palette.brand.withValues(alpha: 0.35),
                offset: const Offset(4, 6),
                blurRadius: 14,
              ),
              BoxShadow(
                color: palette.shadowLight,
                offset: const Offset(-4, -4),
                blurRadius: 10,
              ),
            ]
          : const [],
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          disabledBackgroundColor: palette.brand.withValues(
            alpha: loading ? 0.75 : 0.4,
          ),
          disabledForegroundColor: palette.onBrand,
        ),
        child: _ButtonContent(
          label: label,
          icon: icon,
          loading: loading,
          color: palette.onBrand,
        ),
      ),
    );
  }
}

/// Light raised pill for the secondary action ("Stay logged in", "Cancel").
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return _RaisedPill(
      expand: expand,
      shadows: onPressed == null
          ? const []
          : Neu.raised(palette, distance: 5, blur: 12),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: palette.surface,
          foregroundColor: palette.heading,
          disabledBackgroundColor: palette.field,
          disabledForegroundColor: palette.textMuted,
        ),
        child: _ButtonContent(label: label, icon: icon),
      ),
    );
  }
}

/// Pill-shaped shadow wrapper shared by both buttons.
class _RaisedPill extends StatelessWidget {
  const _RaisedPill({
    required this.child,
    required this.shadows,
    required this.expand,
  });

  final Widget child;
  final List<BoxShadow> shadows;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final pill = DecoratedBox(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        shadows: shadows,
      ),
      child: child,
    );
    return expand ? SizedBox(width: double.infinity, child: pill) : pill;
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    this.icon,
    this.loading = false,
    this.color,
  });

  final String label;
  final IconData? icon;
  final bool loading;

  /// Spinner colour. Only needed when [loading] can be true.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Widget? leading = loading
        ? SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: color),
          )
        : icon == null
        ? null
        : Icon(icon, size: 20);
    if (leading == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        leading,
        const SizedBox(width: 10),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
