import 'package:flutter/material.dart';

import 'auth_colors.dart';

/// Neumorphic ("soft UI") helpers. The light source is top-left, so raised
/// shapes get a white highlight above-left and a grey-blue shadow below-right;
/// inset shapes get the opposite, inside their edges.
abstract final class Neu {
  /// Shadows that make a shape look raised off the surface.
  static List<BoxShadow> raised({double distance = 6, double blur = 14}) => [
    BoxShadow(
      color: AuthColors.shadowDark,
      offset: Offset(distance, distance),
      blurRadius: blur,
    ),
    BoxShadow(
      color: AuthColors.shadowLight,
      offset: Offset(-distance, -distance),
      blurRadius: blur,
    ),
  ];

  /// A raised rounded box in the surface colour (cards, dialogs, badges).
  static BoxDecoration raisedBox({
    double radius = 20,
    Color color = AuthColors.surface,
    double distance = 6,
    double blur = 14,
  }) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: raised(distance: distance, blur: blur),
  );

  /// A raised circle in the surface colour.
  static BoxDecoration raisedCircle({
    Color color = AuthColors.surface,
    double distance = 4,
    double blur = 10,
  }) => BoxDecoration(
    color: color,
    shape: BoxShape.circle,
    boxShadow: raised(distance: distance, blur: blur),
  );
}

/// A box that looks pressed into the surface (text fields, disabled
/// buttons). Optionally draws a coloured border, e.g. red for errors.
class NeuInset extends StatelessWidget {
  const NeuInset({
    super.key,
    required this.child,
    this.radius = 14,
    this.color = AuthColors.field,
    this.borderColor,
  });

  final Widget child;
  final double radius;
  final Color color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _InsetPainter(
        radius: radius,
        color: color,
        borderColor: borderColor,
      ),
      child: child,
    );
  }
}

class _InsetPainter extends CustomPainter {
  _InsetPainter({required this.radius, required this.color, this.borderColor});

  final double radius;
  final Color color;
  final Color? borderColor;

  static const _distance = 3.0;
  static const _blur = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    canvas.drawRRect(rrect, Paint()..color = color);

    // Inner shadows: fill everything outside a shifted copy of the shape,
    // blur it, and clip to the shape so only the inner edge shows.
    canvas.save();
    canvas.clipRRect(rrect);
    _innerShadow(canvas, rrect, const Offset(_distance, _distance), true);
    _innerShadow(canvas, rrect, const Offset(-_distance, -_distance), false);
    canvas.restore();

    final border = borderColor;
    if (border != null) {
      canvas.drawRRect(
        rrect.deflate(0.75),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = border,
      );
    }
  }

  void _innerShadow(Canvas canvas, RRect rrect, Offset offset, bool dark) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rrect.outerRect.inflate(_blur * 4))
      ..addRRect(rrect.shift(offset));
    canvas.drawPath(
      path,
      Paint()
        ..color = dark ? AuthColors.shadowDark : AuthColors.shadowLight
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _blur),
    );
  }

  @override
  bool shouldRepaint(_InsetPainter old) =>
      old.radius != radius ||
      old.color != color ||
      old.borderColor != borderColor;
}
