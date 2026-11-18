import '../entities/scan_summary.dart';

abstract class HistoryRepository {
  Stream<List<ScanSummary>> watchScans(String userId);

  Future<void> deleteScan(String scanId);
}
