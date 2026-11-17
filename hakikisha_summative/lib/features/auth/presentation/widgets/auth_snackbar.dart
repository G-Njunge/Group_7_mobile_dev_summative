import 'package:flutter/material.dart';

import 'auth_colors.dart';

enum AuthSnackType { error, success, info }

/// Shows the floating snackbar from design A5: 16dp side margin, 24dp from the
/// bottom, radius 14, hides after 4 seconds. Errors get a DISMISS action.
void showAuthSnackBar(
  BuildContext context,
  String message, {
  AuthSnackType type = AuthSnackType.error,
}) {
  final (color, icon) = switch (type) {
    AuthSnackType.error => (AuthColors.error, Icons.error_outline),
    AuthSnackType.success => (AuthColors.success, Icons.check_circle_outline),
    AuthSnackType.info => (AuthColors.info, Icons.info_outline),
  };

  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
        // Keep the 4s auto-hide even though errors have an action.
        persist: false,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        action: type == AuthSnackType.error
            ? SnackBarAction(
                label: 'DISMISS',
                textColor: Colors.white,
                onPressed: messenger.hideCurrentSnackBar,
              )
            : null,
      ),
    );
}
