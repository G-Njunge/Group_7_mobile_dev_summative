import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/report_entity.dart';

/// Reads and writes the `reports` collection. Field names follow the ERD in
/// docs/database.md and are enforced by firestore.rules.
///
/// The app doesn't use Cloud Storage, so reports are saved without photos and
/// `photoUrls` stays an empty list.
class ReportRemoteDataSource {
  ReportRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reports =>
      _firestore.collection('reports');

  Stream<List<ReportEntity>> watchMyReports(String userId) => _reports
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => [
          for (final doc in snapshot.docs) _fromJson(doc.data(), doc.id),
        ],
      );

  Future<void> createReport({
    required String userId,
    required ReportDraft draft,
  }) => _reports.doc().set({
    'userId': userId,
    'scanId': null,
    ..._draftFields(draft),
    'photoUrls': const <String>[],
    'status': 'pending',
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  Future<void> updatePendingReport({
    required String reportId,
    required ReportDraft draft,
  }) => _reports.doc(reportId).update({
    ..._draftFields(draft),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  Future<void> deletePendingReport(String reportId) =>
      _reports.doc(reportId).delete();

  /// The user-editable fields. Optional ones are written as `null` when empty
  /// so an edit can also clear them.
  Map<String, Object?> _draftFields(ReportDraft draft) => {
    'medicineName': draft.medicineName,
    'batchNumber': draft.batchNumber,
    'purchaseLocation': draft.purchaseLocation,
    'pharmacyId': draft.pharmacyId,
    'description': draft.description,
  };

  /// Tolerates older reports that have no medicine fields.
  ReportEntity _fromJson(Map<String, dynamic> json, String reportId) {
    String? text(String key) =>
        json[key] is String ? json[key] as String : null;
    final photoUrls = json['photoUrls'];
    final createdAt = json['createdAt'];
    return ReportEntity(
      reportId: reportId,
      medicineName: text('medicineName') ?? '',
      batchNumber: text('batchNumber'),
      purchaseLocation: text('purchaseLocation'),
      pharmacyId: text('pharmacyId'),
      description: text('description') ?? '',
      status: text('status') ?? 'pending',
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      photoUrls: photoUrls is List
          ? photoUrls.whereType<String>().toList()
          : const [],
    );
  }
}
