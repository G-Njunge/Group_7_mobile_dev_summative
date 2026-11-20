import 'package:cloud_firestore/cloud_firestore.dart';

class ReportRemoteDataSource {
  ReportRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

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
}
