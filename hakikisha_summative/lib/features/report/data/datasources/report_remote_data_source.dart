import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/report_entity.dart';

class ReportRemoteDataSource {
  ReportRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<List<ReportEntity>> watchMyReports(String userId) => _firestore
      .collection('reports')
      .where('userId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (document) =>
                  _reportFromJson(document.data(), reportId: document.id),
            )
            .toList(),
      );

  Future<void> createCounterfeitReport({
    required String userId,
    required String pharmacyId,
    required String description,
  }) async {
    await _firestore.collection('reports').add({
      'userId': userId,
      'scanId': null,
      'pharmacyId': pharmacyId,
      'description': description,
      'photoUrls': <String>[],
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updatePendingReport({
    required String reportId,
    required String pharmacyId,
    required String description,
  }) => _firestore.collection('reports').doc(reportId).update({
    'pharmacyId': pharmacyId,
    'description': description,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  Future<void> deletePendingReport(String reportId) =>
      _firestore.collection('reports').doc(reportId).delete();

  ReportEntity _reportFromJson(
    Map<String, dynamic> json, {
    required String reportId,
  }) {
    final pharmacyId = json['pharmacyId'];
    final description = json['description'];
    final status = json['status'];
    final createdAt = json['createdAt'];
    if (pharmacyId is! String ||
        description is! String ||
        status is! String ||
        (createdAt != null && createdAt is! Timestamp)) {
      throw const FormatException('Invalid report document.');
    }

    return ReportEntity(
      reportId: reportId,
      pharmacyId: pharmacyId,
      description: description,
      status: status,
      createdAt: (createdAt as Timestamp?)?.toDate(),
    );
  }
}
