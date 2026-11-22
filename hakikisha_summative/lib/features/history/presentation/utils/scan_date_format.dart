const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// Formats a scan time like the Figma: "Today, 09:41",
/// "Yesterday, 17:02" or "11 Sep, 08:15". [now] exists so tests can
/// pin the clock.
String formatScanTime(DateTime scannedAt, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final scanDay = DateTime(scannedAt.year, scannedAt.month, scannedAt.day);
  final thisDay = DateTime(today.year, today.month, today.day);
  final daysAgo = thisDay.difference(scanDay).inDays;
  final time = '${_two(scannedAt.hour)}:${_two(scannedAt.minute)}';

  if (daysAgo == 0) return 'Today, $time';
  if (daysAgo == 1) return 'Yesterday, $time';
  return '${_two(scannedAt.day)} ${_months[scannedAt.month - 1]}, $time';
}
