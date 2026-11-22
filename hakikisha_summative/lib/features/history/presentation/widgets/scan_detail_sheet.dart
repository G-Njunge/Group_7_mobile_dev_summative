import 'package:flutter/material.dart';

import '../../domain/entities/scan_summary.dart';
import '../utils/scan_date_format.dart';
import 'scan_tile.dart';

/// Opens a bottom sheet with the full details of one scan.
void showScanDetailSheet(BuildContext context, ScanSummary summary) {
  final scan = summary.scan;

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
            Text(
              summary.medicineName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _DetailRow(label: 'Result', value: formatResult(scan.result)),
            _DetailRow(label: 'Method', value: scan.method),
            _DetailRow(label: 'Scanned', value: formatScanTime(scan.scannedAt)),
            _DetailRow(label: 'Batch', value: scan.batchId ?? 'Not found'),
            _DetailRow(label: 'Scan ID', value: scan.scanId),
          ],
        ),
      ),
    ),
  );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: Text(label)),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}
