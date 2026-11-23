import 'package:equatable/equatable.dart';

enum ScanMethod { camera, manual, upload }

class ScanRecordEntity extends Equatable {
  final String scanId;
  final String userId;
  final String batchId;
  final String result; // 'genuine', 'flagged', 'not_found'
  final ScanMethod method;
  final DateTime scannedAt;

  // Optional hydrated fields for Home's recent-scan card UI
  final String? medicineName;
  final String? batchNumber;

  const ScanRecordEntity({
    required this.scanId,
    required this.userId,
    required this.batchId,
    required this.result,
    required this.method,
    required this.scannedAt,
    this.medicineName,
    this.batchNumber,
  });

  @override
  List<Object?> get props => [
        scanId,
        userId,
        batchId,
        result,
        method,
        scannedAt,
        medicineName,
        batchNumber,
      ];
}
