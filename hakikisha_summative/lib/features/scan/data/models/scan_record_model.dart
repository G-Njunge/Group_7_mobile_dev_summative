import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/scan_record_entity.dart';

class ScanRecordModel extends ScanRecordEntity {
  const ScanRecordModel({
    required super.scanId,
    required super.userId,
    required super.batchId,
    required super.result,
    required super.method,
    required super.scannedAt,
    super.medicineName,
    super.batchNumber,
  });

  factory ScanRecordModel.fromFirestore(
    String id,
    Map<String, dynamic> json, {
    String? medicineName,
    String? batchNumber,
  }) {
    final rawTimestamp = json['scannedAt'];
    final parsedDate = rawTimestamp is Timestamp
        ? rawTimestamp.toDate()
        : DateTime.tryParse(rawTimestamp?.toString() ?? '') ?? DateTime.now();

    return ScanRecordModel(
      scanId: id,
      userId: json['userId'] as String? ?? '',
      batchId: json['batchId'] as String? ?? '',
      result: json['result'] as String? ?? 'not_found',
      method: _parseMethod(json['method'] as String?),
      scannedAt: parsedDate,
      medicineName: medicineName,
      batchNumber: batchNumber,
    );
  }

  // Strictly matches ERD contract: no duplicated medicine fields in scans[cite: 21]
  Map<String, dynamic> toFirestore() {
    return {
      'scanId': scanId,
      'userId': userId,
      'batchId': batchId,
      'result': result,
      'method': method.name, // 'camera', 'manual', or 'upload'[cite: 21]
      'scannedAt': Timestamp.fromDate(scannedAt),
    };
  }

  static ScanMethod _parseMethod(String? value) {
    switch (value) {
      case 'manual':
        return ScanMethod.manual;
      case 'upload':
        return ScanMethod.upload;
      default:
        return ScanMethod.camera;
    }
  }
}
