import 'package:material_ui/material_ui.dart';

import 'auth_colors.dart';
import 'neumorphic.dart';

/// Neumorphic inset text field with an uppercase label above it.
///
/// - [errorText] shows the red error state (red border, error icon, red
///   message below), as in design A4. The AuthBloc / validators supply it.
/// - [successText] shows a green tick message below, e.g. "Strong password".
/// - [obscure] hides the text and adds a show/hide toggle.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.obscure = false,
    this.errorText,
    this.successText,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final bool obscure;
  final String? errorText;
  final String? successText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  // Local UI state only: password visibility and focus highlight.
  late bool _hidden = widget.obscure;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.errorText;
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
            color: hasError ? AuthColors.error : AuthColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        NeuInset(
          borderColor: hasError
              ? AuthColors.error
              : _focusNode.hasFocus
              ? AuthColors.primary.withValues(alpha: 0.5)
              : null,
          child: TextField(
            focusNode: _focusNode,
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            autofillHints: widget.autofillHints,
            obscureText: _hidden,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            enabled: widget.enabled,
            style: const TextStyle(fontSize: 16, color: AuthColors.text),
            cursorColor: AuthColors.primary,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: AuthColors.textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
              suffixIcon: _suffixIcon(hasError),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              error,
              style: const TextStyle(color: AuthColors.error, fontSize: 13),
            ),
          )
        else if (widget.successText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Row(
              children: [
                const Icon(Icons.check, size: 16, color: AuthColors.success),
                const SizedBox(width: 4),
                Text(
                  widget.successText!,
                  style: const TextStyle(
                    color: AuthColors.success,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget? _suffixIcon(bool hasError) {
    if (widget.obscure) {
      return IconButton(
        tooltip: _hidden ? 'Show password' : 'Hide password',
        color: hasError ? AuthColors.error : AuthColors.textMuted,
        icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off),
        onPressed: () => setState(() => _hidden = !_hidden),
      );
    }
    if (hasError) {
      return const Icon(Icons.error_outline, color: AuthColors.error);
    }
    return null;
  }
}
