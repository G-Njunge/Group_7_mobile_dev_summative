import '../entities/batch_entity.dart';
import '../entities/medicine_entity.dart';
import '../entities/scan_record_entity.dart';

abstract class ScanRepository {
  Future<BatchEntity?> findBatchByCode(String code);
  Future<MedicineEntity?> getMedicineById(String medicineId);
  Future<void> saveScanRecord(ScanRecordEntity record);
  Stream<ScanRecordEntity?> watchLatestScan(String userId);
}
