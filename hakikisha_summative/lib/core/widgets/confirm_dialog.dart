import 'package:material_ui/material_ui.dart';

import '../constants/app_assets.dart';
import '../theme/app_palette.dart';
import 'app_buttons.dart';
import 'neumorphic.dart';

/// Shows a neumorphic yes/no dialog in the style of the Log out screen and
/// returns `true` only if the user tapped [confirmLabel].
///
/// Shared by log out, delete scan, withdraw report and delete account.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool showLogo = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => ConfirmDialog(
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      showLogo: showLogo,
    ),
  );
  return confirmed ?? false;
}

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.cancelLabel,
    this.showLogo = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final navigator = Navigator.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: Neu.raised(palette, distance: 8, blur: 20),
        ),
        // Scrolls in landscape, where the dialog can be taller than the screen.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showLogo) ...[
                Image.asset(
                  AppAssets.logo,
                  height: 56,
                  excludeFromSemantics: true,
                ),
                const SizedBox(height: 16),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.textMuted),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: confirmLabel,
                onPressed: () => navigator.pop(true),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: cancelLabel,
                onPressed: () => navigator.pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
