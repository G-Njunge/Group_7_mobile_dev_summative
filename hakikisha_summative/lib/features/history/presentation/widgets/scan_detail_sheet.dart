import 'package:flutter/material.dart';

import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/theme/app_palette.dart';
import '../../domain/entities/scan_summary.dart';
import '../utils/scan_date_format.dart';
import '../utils/scan_result_labels.dart';

/// Opens a bottom sheet with the full details of one scan.
void showScanDetailSheet(BuildContext context, ScanSummary summary) {
  final l10n = AppLocalizations.of(context);
  final scan = summary.scan;
  final title = summary.medicineName.isEmpty
      ? l10n.historyUnknownMedicine
      : summary.medicineName;

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _DetailRow(
              label: l10n.historyResult,
              value: resultLabel(l10n, scan.result),
            ),
            _DetailRow(
              label: l10n.historyMethod,
              value: methodLabel(l10n, scan.method),
            ),
            _DetailRow(
              label: l10n.historyScanned,
              value: formatScanTime(scan.scannedAt),
            ),
            _DetailRow(
              label: l10n.historyBatch,
              value: scan.batchId ?? l10n.historyNotFound,
            ),
            _DetailRow(label: l10n.historyScanId, value: scan.scanId),
          ],
        ),
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: context.palette.textMuted),
            ),
          ),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}
