// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import 'neumorphic.dart';

/// The Hakikisha logo inside a raised neumorphic circle, used in the corner
/// of the auth screens.
class LogoBadge extends StatelessWidget {
  const LogoBadge({super.key, this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.1),
      decoration: Neu.raisedCircle(color: Colors.white),
      child: ClipOval(
        child: Image.asset(
          'assets/images/hakikisha-logo.png',
          fit: BoxFit.contain,
          semanticLabel: 'Hakikisha logo',
        ),
      ),
    );
  }
}
