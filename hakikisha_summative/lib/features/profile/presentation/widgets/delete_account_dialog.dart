import 'package:flutter/material.dart';

import '../../../auth/presentation/widgets/auth_buttons.dart';
import '../../../auth/presentation/widgets/auth_colors.dart';
import '../../../auth/presentation/widgets/neumorphic.dart';

/// Asks the user to confirm. Returns true only if they chose to delete.
Future<bool> showDeleteAccountDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => const DeleteAccountDialog(),
  );
  return result ?? false;
}

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: Neu.raisedBox(radius: 24, distance: 8, blur: 20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: AuthColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Delete your account?',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AuthColors.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This permanently deletes your account and cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AuthColors.textMuted),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Delete account',
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Keep my account',
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
