import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/history/presentation/utils/scan_date_format.dart';

void main() {
  final now = DateTime(2026, 11, 17, 12);

  test('says Today for scans on the same day', () {
    expect(
      formatScanTime(DateTime(2026, 11, 17, 9, 41), now: now),
      'Today, 09:41',
    );
  });

  test('says Yesterday for scans the day before', () {
    expect(
      formatScanTime(DateTime(2026, 11, 16, 17, 2), now: now),
      'Yesterday, 17:02',
    );
  });

  test('uses day and month for older scans', () {
    expect(
      formatScanTime(DateTime(2026, 9, 11, 8, 15), now: now),
      '11 Sep, 08:15',
    );
  });
}
