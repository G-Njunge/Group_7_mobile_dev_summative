import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_schema.dart';
import '../models/scan_model.dart';

/// The only class in the history feature that talks to Firestore.
class HistoryRemoteDataSource {
  HistoryRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  /// batchId -> medicine name. Names rarely change, so each batch and
  /// medicine is read once instead of on every list update.
  final Map<String, String> _medicineNames = {};

  /// A live feed of this user's scans, newest first. Needs the composite
  /// index (userId, scannedAt desc) from firestore.indexes.json.
  Stream<List<ScanModel>> watchScans(String userId) => _firestore
      .collection(FirestoreCollections.scans)
      .where('userId', isEqualTo: userId)
      .orderBy('scannedAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (document) =>
                  ScanModel.fromJson(document.data(), documentId: document.id),
            )
            .toList(),
      );

  /// The medicine name for [batchId], or null if the batch or its medicine
  /// can't be found.
  Future<String?> medicineNameForBatch(String batchId) async {
    final cached = _medicineNames[batchId];
    if (cached != null) return cached;

    final batch = await _firestore
        .collection(FirestoreCollections.batches)
        .doc(batchId)
        .get();
    final medicineId = batch.data()?['medicineId'] as String?;
    if (medicineId == null) return null;

    final medicine = await _firestore
        .collection(FirestoreCollections.medicines)
        .doc(medicineId)
        .get();
    final name = medicine.data()?['name'] as String?;
    if (name != null) _medicineNames[batchId] = name;
    return name;
  }

  Future<void> deleteScan(String scanId) =>
      _firestore.collection(FirestoreCollections.scans).doc(scanId).delete();
}
