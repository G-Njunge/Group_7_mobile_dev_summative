import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Neumorphic ("soft UI") shadows. The light source is top-left: raised shapes
/// get a highlight above-left and a shadow below-right.
abstract final class Neu {
  static List<BoxShadow> raised(
    AppPalette palette, {
    double distance = 6,
    double blur = 14,
  }) => [
    BoxShadow(
      color: palette.shadowDark,
      offset: Offset(distance, distance),
      blurRadius: blur,
    ),
    BoxShadow(
      color: palette.shadowLight,
      offset: Offset(-distance, -distance),
      blurRadius: blur,
    ),
  ];
}

/// A raised rounded card in the surface colour, the main container in the
/// Figma screens (scan details, history rows, pharmacy cards, stat tiles).
///
/// Pass [onTap] to make the whole card tappable with an ink ripple.
class NeuCard extends StatelessWidget {
  const NeuCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 20,
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// Defaults to the palette's surface colour.
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final shape = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? palette.surface,
        borderRadius: shape,
        boxShadow: Neu.raised(palette),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: shape,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// A box that looks pressed into the surface: text fields, empty photo slots
/// and disabled buttons. [borderColor] draws an outline, e.g. red on error.
class NeuInset extends StatelessWidget {
  const NeuInset({
    super.key,
    required this.child,
    this.radius = 14,
    this.borderColor,
  });

  final Widget child;
  final double radius;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _InsetPainter(
      palette: context.palette,
      radius: radius,
      borderColor: borderColor,
    ),
    child: child,
  );
}

class _InsetPainter extends CustomPainter {
  const _InsetPainter({
    required this.palette,
    required this.radius,
    this.borderColor,
  });

  final AppPalette palette;
  final double radius;
  final Color? borderColor;

  static const _offset = 3.0;
  static const _blur = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final shape = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    canvas
      ..drawRRect(shape, Paint()..color = palette.field)
      ..save()
      ..clipRRect(shape);
    _innerShadow(
      canvas,
      shape,
      const Offset(_offset, _offset),
      palette.shadowDark,
    );
    _innerShadow(
      canvas,
      shape,
      const Offset(-_offset, -_offset),
      palette.shadowLight,
    );
    canvas.restore();

    if (borderColor case final color?) {
      canvas.drawRRect(
        shape.deflate(0.75),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = color,
      );
    }
  }

  /// Fills everything outside a shifted copy of [shape] and blurs it. Clipped
  /// to [shape], only the blurred inner edge stays visible.
  void _innerShadow(Canvas canvas, RRect shape, Offset offset, Color color) {
    final ring = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(shape.outerRect.inflate(_blur * 4))
      ..addRRect(shape.shift(offset));
    canvas.drawPath(
      ring,
      Paint()
        ..color = color
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _blur),
    );
  }

  @override
  bool shouldRepaint(_InsetPainter old) =>
      old.palette != palette ||
      old.radius != radius ||
      old.borderColor != borderColor;
}
