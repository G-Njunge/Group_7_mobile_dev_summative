import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/batch_model.dart';
import '../models/medicine_model.dart';
import '../models/scan_record_model.dart';

class ScanRemoteDataSource {
  final FirebaseFirestore firestore;

  ScanRemoteDataSource({required this.firestore});

  Future<BatchModel?> findBatchByCode(String rawCode) async {
    final code = rawCode.trim();
    if (code.isEmpty) return null;

    // 1. Check exact batchNumber match (case-normalized uppercase first, then raw)
    var query = await firestore
        .collection('batches')
        .where('batchNumber', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty && code != code.toUpperCase()) {
      query = await firestore
          .collection('batches')
          .where('batchNumber', isEqualTo: code)
          .limit(1)
          .get();
    }

    // 2. Fallback to GTIN barcode lookup
    if (query.docs.isEmpty) {
      query = await firestore
          .collection('batches')
          .where('gtin', isEqualTo: code)
          .limit(1)
          .get();
    }

    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    return BatchModel.fromFirestore(doc.id, doc.data());
  }

  Future<MedicineModel?> getMedicineById(String medicineId) async {
    if (medicineId.isEmpty) return null;
    final doc = await firestore.collection('medicines').doc(medicineId).get();
    if (!doc.exists || doc.data() == null) return null;
    return MedicineModel.fromFirestore(doc.id, doc.data()!);
  }

  Future<void> saveScanRecord(ScanRecordModel record) async {
    final docRef = record.scanId.isEmpty
        ? firestore.collection('scans').doc()
        : firestore.collection('scans').doc(record.scanId);

    final payload = record.toFirestore()..['scanId'] = docRef.id;
    await docRef.set(payload);
  }

  /// Uses composite index: scans (userId, scannedAt desc)[cite: 21]
  Stream<ScanRecordModel?> watchLatestScan(String userId) {
    return firestore
        .collection('scans')
        .where('userId', isEqualTo: userId)
        .orderBy('scannedAt', descending: true)
        .limit(1)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.docs.isEmpty) return null;

      final doc = snapshot.docs.first;
      final data = doc.data();
      final batchId = data['batchId'] as String? ?? '';

      String? medicineName;
      String? batchNumber;

      if (batchId.isNotEmpty) {
        final batchDoc =
            await firestore.collection('batches').doc(batchId).get();
        if (batchDoc.exists && batchDoc.data() != null) {
          final batchData = batchDoc.data()!;
          batchNumber = batchData['batchNumber'] as String?;
          final medId = batchData['medicineId'] as String? ?? '';
          if (medId.isNotEmpty) {
            final medDoc =
                await firestore.collection('medicines').doc(medId).get();
            medicineName = medDoc.data()?['name'] as String?;
          }
        }
      }

      return ScanRecordModel.fromFirestore(
        doc.id,
        data,
        medicineName: medicineName,
        batchNumber: batchNumber,
      );
    });
  }
}
