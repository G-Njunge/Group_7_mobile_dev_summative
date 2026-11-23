import '../../domain/entities/scan_summary.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_data_source.dart';
import '../models/scan_model.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  HistoryRepositoryImpl(this._remote);

  final HistoryRemoteDataSource _remote;

  @override
  Stream<List<ScanSummary>> watchScans(String userId) => _remote
      .watchScans(userId)
      .asyncMap((scans) => Future.wait(scans.map(_toSummary)));

  /// Pairs a scan with its medicine name. An empty name means "unknown"
  /// (no batch matched, or the lookup failed) and the screen shows a
  /// translated fallback. One bad lookup never hides the other scans.
  Future<ScanSummary> _toSummary(ScanModel scan) async {
    String? name;
    final batchId = scan.batchId;
    if (batchId != null) {
      try {
        name = await _remote.medicineNameForBatch(batchId);
      } catch (_) {
        name = null;
      }
    }
    return ScanSummary(scan: scan.toEntity(), medicineName: name ?? '');
  }

  @override
  Future<void> deleteScan(String scanId) => _remote.deleteScan(scanId);
}
