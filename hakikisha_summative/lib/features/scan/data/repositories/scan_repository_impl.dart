import '../../domain/entities/batch_entity.dart';
import '../../domain/entities/medicine_entity.dart';
import '../../domain/entities/scan_record_entity.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/scan_remote_datasource.dart';
import '../models/scan_record_model.dart';

class ScanRepositoryImpl implements ScanRepository {
  final ScanRemoteDataSource remoteDataSource;

  ScanRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BatchEntity?> findBatchByCode(String code) {
    return remoteDataSource.findBatchByCode(code);
  }

  @override
  Future<MedicineEntity?> getMedicineById(String medicineId) {
    return remoteDataSource.getMedicineById(medicineId);
  }

  @override
  Future<void> saveScanRecord(ScanRecordEntity record) {
    final model = ScanRecordModel(
      scanId: record.scanId,
      userId: record.userId,
      batchId: record.batchId,
      result: record.result,
      method: record.method,
      scannedAt: record.scannedAt,
    );
    return remoteDataSource.saveScanRecord(model);
  }

  @override
  Stream<ScanRecordEntity?> watchLatestScan(String userId) {
    return remoteDataSource.watchLatestScan(userId);
  }
}
