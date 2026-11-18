import '../entities/scan_entity.dart';

abstract class HistoryRepository {
  Stream<List<ScanEntity>> watchScans(String userId);

  Future<void> deleteScan(String scanId);
}
