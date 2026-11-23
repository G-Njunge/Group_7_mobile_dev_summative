import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/neumorphic.dart';
import '../../domain/entities/scan_summary.dart';
import '../utils/scan_date_format.dart';
import '../utils/scan_result_labels.dart';

/// One row in the history list: a coloured dot, the medicine name, the
/// result and time, and a delete button.
class ScanTile extends StatelessWidget {
  const ScanTile({
    super.key,
    required this.summary,
    required this.onTap,
    required this.onDelete,
  });

  final ScanSummary summary;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scan = summary.scan;
    final title = summary.medicineName.isEmpty
        ? l10n.historyUnknownMedicine
        : summary.medicineName;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeuCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: resultColor(context, scan.result),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${resultLabel(l10n, scan.result)} · '
                    '${formatScanTime(scan.scannedAt)}',
                    style: TextStyle(color: context.palette.textMuted),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.historyDeleteTooltip,
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
