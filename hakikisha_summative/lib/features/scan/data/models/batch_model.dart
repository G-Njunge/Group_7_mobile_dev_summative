import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/batch_entity.dart';

class BatchModel extends BatchEntity {
  const BatchModel({
    required super.batchId,
    required super.medicineId,
    required super.batchNumber,
    required super.gtin,
    required super.expiryDate,
    required super.status,
  });

  factory BatchModel.fromFirestore(String id, Map<String, dynamic> json) {
    final rawExpiry = json['expiryDate'];
    DateTime parsedExpiry;

    if (rawExpiry is Timestamp) {
      parsedExpiry = rawExpiry.toDate();
    } else if (rawExpiry is String) {
      parsedExpiry = DateTime.tryParse(rawExpiry) ?? DateTime(2000);
    } else {
      parsedExpiry = DateTime(2000);
    }

    return BatchModel(
      batchId: id,
      medicineId: json['medicineId'] as String? ?? '',
      batchNumber: json['batchNumber'] as String? ?? '',
      gtin: json['gtin'] as String? ?? '',
      expiryDate: parsedExpiry,
      status: json['status'] as String? ?? 'valid',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'batchId': batchId,
      'medicineId': medicineId,
      'batchNumber': batchNumber,
      'gtin': gtin,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'status': status,
    };
  }
}
