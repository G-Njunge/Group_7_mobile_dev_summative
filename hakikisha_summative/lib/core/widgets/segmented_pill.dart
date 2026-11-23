import 'package:material_ui/material_ui.dart';

import '../theme/app_palette.dart';
import 'neumorphic.dart';

/// One option in a [SegmentedPill].
class PillOption<T> {
  const PillOption(this.value, this.label);

  final T value;
  final String label;
}

/// Inset track with a raised green pill on the selected option, like the
/// Genuine / Flagged toggle in the Figma file. Also suits filter tabs
/// (All / Genuine / Flagged) and the theme and language settings.
class SegmentedPill<T> extends StatelessWidget {
  const SegmentedPill({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<PillOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return NeuInset(
      radius: 999,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (final option in options)
              Expanded(
                child: _Segment(
                  label: option.label,
                  selected: option.value == selected,
                  palette: palette,
                  onTap: () => onChanged(option.value),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final AppPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: ShapeDecoration(
          shape: const StadiumBorder(),
          color: selected ? palette.brand : Colors.transparent,
        ),
        // Transparent Material so the ripple paints above the pill colour.
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: selected ? palette.onBrand : palette.text,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
