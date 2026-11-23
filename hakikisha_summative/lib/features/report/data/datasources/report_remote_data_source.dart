import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'dart:typed_data';

import '../../domain/entities/report_entity.dart';

class ReportRemoteDataSource {
  ReportRemoteDataSource(this._firestore, [this._storage]);

  final FirebaseFirestore _firestore;
  final FirebaseStorage? _storage;

  Stream<List<ReportEntity>> watchMyReports(String userId) => _firestore
      .collection('reports')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) {
        final reports = snapshot.docs
            .map(
              (document) =>
                  _reportFromJson(document.data(), reportId: document.id),
            )
            .toList();
        reports.sort((a, b) {
          final aCreatedAt = a.createdAt;
          final bCreatedAt = b.createdAt;
          if (aCreatedAt == null) return bCreatedAt == null ? 0 : 1;
          if (bCreatedAt == null) return -1;
          return bCreatedAt.compareTo(aCreatedAt);
        });
        return reports;
      });

  Future<void> createCounterfeitReport({
    required String userId,
    required String pharmacyId,
    required String description,
    List<Uint8List> photoBytes = const [],
  }) async {
    final report = _firestore.collection('reports').doc();
    final photoUrls = <String>[];

    try {
      for (var index = 0; index < photoBytes.length && index < 3; index++) {
        if (_storage == null) break;
        final reference = _storage.ref(
          'reports/$userId/${report.id}/photo_${index + 1}.jpg',
        );
        await reference.putData(
          photoBytes[index],
          SettableMetadata(contentType: 'image/jpeg'),
        );
        photoUrls.add(await reference.getDownloadURL());
      }

      await report.set({
        'userId': userId,
        'scanId': null,
        'pharmacyId': pharmacyId,
        'description': description,
        'photoUrls': photoUrls,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      if (_storage != null) {
        try {
          final folder = await _storage
              .ref('reports/$userId/${report.id}')
              .listAll();
          await Future.wait(folder.items.map((item) => item.delete()));
        } on Object {
          // Upload or cleanup failure should not mask the original submission error.
        }
      }
      rethrow;
    }
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

  Future<void> deletePendingReport(String reportId) async {
    final document = _firestore.collection('reports').doc(reportId);
    final snapshot = await document.get();
    final userId = snapshot.data()?['userId'];

    await document.delete();

    if (_storage != null && userId is String) {
      try {
        final folder = await _storage
            .ref('reports/$userId/$reportId')
            .listAll();
        await Future.wait(folder.items.map((item) => item.delete()));
      } on Object {
        // The report document is already deleted; orphaned photos are best-effort.
      }
    }
  }

  ReportEntity _reportFromJson(
    Map<String, dynamic> json, {
    required String reportId,
  }) {
    final pharmacyId = json['pharmacyId'];
    final description = json['description'];
    final status = json['status'];
    final createdAt = json['createdAt'];
    final photoUrls = json['photoUrls'];
    if (pharmacyId is! String ||
        description is! String ||
        status is! String ||
        (photoUrls != null &&
            (photoUrls is! List ||
                photoUrls.any((photoUrl) => photoUrl is! String))) ||
        (createdAt != null && createdAt is! Timestamp)) {
      throw const FormatException('Invalid report document.');
    }

    return ReportEntity(
      reportId: reportId,
      pharmacyId: pharmacyId,
      description: description,
      status: status,
      createdAt: (createdAt as Timestamp?)?.toDate(),
      photoUrls: photoUrls is List
          ? photoUrls.cast<String>()
          : const <String>[],
    );
  }
}
