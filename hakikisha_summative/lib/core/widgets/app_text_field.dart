import 'package:material_ui/material_ui.dart';

import '../theme/app_palette.dart';
import 'neumorphic.dart';

/// Inset text field with an uppercase label above it, as on the Register and
/// Report screens.
///
/// Works two ways:
/// - inside a [Form] with a [validator], so `formKey.currentState!.validate()`
///   shows the errors;
/// - with an [errorText] supplied by a bloc state.
///
/// The error message sits below the inset box rather than inside it.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.obscure = false,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;

  /// Overrides the [validator] message, e.g. an error from the bloc.
  final String? errorText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;

  /// Hides the text and adds a show/hide toggle.
  final bool obscure;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  // Local UI objects only; listenables avoid any setState rebuilds.
  final _focusNode = FocusNode();
  late final ValueNotifier<bool> _hidden = ValueNotifier(widget.obscure);
  TextEditingController? _ownController;

  TextEditingController get _controller =>
      widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void dispose() {
    _focusNode.dispose();
    _hidden.dispose();
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final errorColor = Theme.of(context).colorScheme.error;

    return FormField<String>(
      // Validate the controller's text so programmatic changes count too.
      validator: (_) => widget.validator?.call(_controller.text),
      builder: (field) {
        final error = widget.errorText ?? field.errorText;
        final hasError = error != null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: hasError ? errorColor : palette.heading,
              ),
            ),
            const SizedBox(height: 8),
            ListenableBuilder(
              listenable: Listenable.merge([_focusNode, _hidden]),
              builder: (context, _) => NeuInset(
                borderColor: hasError
                    ? errorColor
                    : _focusNode.hasFocus
                    ? palette.heading.withValues(alpha: 0.5)
                    : null,
                child: TextField(
                  focusNode: _focusNode,
                  controller: _controller,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  textCapitalization: widget.textCapitalization,
                  autofillHints: widget.autofillHints,
                  obscureText: _hidden.value,
                  maxLines: widget.obscure ? 1 : widget.maxLines,
                  enabled: widget.enabled,
                  onSubmitted: widget.onSubmitted,
                  onChanged: (value) {
                    field.didChange(value);
                    widget.onChanged?.call(value);
                  },
                  style: TextStyle(fontSize: 16, color: palette.text),
                  cursorColor: palette.heading,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(color: palette.textMuted),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                    suffixIcon: _suffix(hasError, errorColor, palette),
                  ),
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  error,
                  style: TextStyle(color: errorColor, fontSize: 13),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget? _suffix(bool hasError, Color errorColor, AppPalette palette) {
    if (widget.obscure) {
      final hidden = _hidden.value;
      return IconButton(
        tooltip: hidden ? 'Show password' : 'Hide password',
        color: hasError ? errorColor : palette.textMuted,
        icon: Icon(hidden ? Icons.visibility_outlined : Icons.visibility_off),
        onPressed: () => _hidden.value = !hidden,
      );
    }
    return hasError ? Icon(Icons.error_outline, color: errorColor) : null;
  }
}
