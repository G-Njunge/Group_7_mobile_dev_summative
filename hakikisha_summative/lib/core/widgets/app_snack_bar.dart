import 'package:material_ui/material_ui.dart';

import '../theme/app_palette.dart';

enum SnackType { error, success, info }

/// Shows the app's floating snackbar, replacing any that's already visible.
///
/// Use it for every CRUD success or failure so feedback looks the same across
/// features: `showAppSnackBar(context, 'Report sent', type: SnackType.success)`.
void showAppSnackBar(
  BuildContext context,
  String message, {
  SnackType type = SnackType.error,
  SnackBarAction? action,
}) {
  final palette = context.palette;
  final (color, icon) = switch (type) {
    SnackType.error => (palette.danger, Icons.error_outline),
    SnackType.success => (palette.success, Icons.check_circle_outline),
    SnackType.info => (palette.text, Icons.info_outline),
  };
  // Info uses the body text colour as its fill, so its text flips to the
  // background colour to stay readable in both themes.
  final onColor = type == SnackType.info ? palette.background : palette.onBrand;

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        // Keep the auto-hide even when an action (e.g. Undo) is attached.
        persist: false,
        action: action,
        content: Row(
          children: [
            Icon(icon, color: onColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: onColor)),
            ),
          ],
        ),
      ),
    );
}
