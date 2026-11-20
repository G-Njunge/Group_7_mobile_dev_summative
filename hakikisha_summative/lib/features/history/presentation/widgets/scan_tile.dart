// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../../domain/entities/scan_summary.dart';
import '../utils/scan_date_format.dart';

/// One row in the history list, laid out like the Figma card.
class ScanTile extends StatelessWidget {
  final ScanSummary summary;
  final VoidCallback onTap;

  const ScanTile({super.key, required this.summary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scan = summary.scan;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        minVerticalPadding: 12,
        onTap: onTap,
        leading: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: resultColor(scan.result),
            shape: BoxShape.circle,
          ),
        ),
        title: Text(summary.medicineName),
        subtitle: Text(
          '${formatResult(scan.result)} · ${formatScanTime(scan.scannedAt)}',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

String formatResult(String result) =>
    result.isEmpty ? result : result[0].toUpperCase() + result.substring(1);

/// Green for genuine, red for flagged, grey for anything else.
Color resultColor(String result) {
  switch (result.toLowerCase()) {
    case 'genuine':
      return Colors.green.shade800;
    case 'flagged':
      return Colors.red.shade800;
    default:
      return Colors.grey.shade700;
  }
}
