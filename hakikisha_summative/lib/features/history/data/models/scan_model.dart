import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_schema.dart';
import '../../domain/entities/scan_entity.dart';

/// A document in the `scans` collection. Field names follow the Firestore
/// contract exactly. The document ID is the scanId.
class ScanModel {
  const ScanModel({
    required this.scanId,
    required this.userId,
    required this.result,
    required this.method,
    required this.scannedAt,
    this.batchId,
  });

  factory ScanModel.fromJson(
    Map<String, dynamic> json, {
    required String documentId,
  }) => ScanModel(
    scanId: documentId,
    userId: json['userId'] as String? ?? '',
    batchId: json['batchId'] as String?,
    result: json['result'] as String? ?? ScanResult.notFound,
    method: json['method'] as String? ?? ScanMethod.manual,
    // Null in the first local snapshot after a write that uses a server
    // timestamp, so fall back to "now" until the server fills it in.
    scannedAt: (json['scannedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  final String scanId;
  final String userId;

  /// `null` when the scanned code matched no batch.
  final String? batchId;
  final String result;
  final String method;
  final DateTime scannedAt;

  ScanEntity toEntity() => ScanEntity(
    scanId: scanId,
    userId: userId,
    batchId: batchId,
    result: result,
    method: method,
    scannedAt: scannedAt,
  );
}
