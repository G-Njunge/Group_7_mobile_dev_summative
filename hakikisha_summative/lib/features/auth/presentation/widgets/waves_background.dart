import 'package:material_ui/material_ui.dart';

/// Full-screen wavy white background used on the Landing screen.
/// Put the screen content in [child].
class WavesBackground extends StatelessWidget {
  const WavesBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFE9EBF0),
        image: DecorationImage(
          image: AssetImage('assets/images/bg-waves.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
