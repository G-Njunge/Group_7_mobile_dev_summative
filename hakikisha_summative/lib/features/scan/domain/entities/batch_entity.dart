import 'package:equatable/equatable.dart';

class BatchEntity extends Equatable {
  final String batchId;
  final String medicineId;
  final String batchNumber;
  final String gtin;
  final DateTime expiryDate;
  final String status; // 'valid', 'recalled', 'counterfeit'

  const BatchEntity({
    required this.batchId,
    required this.medicineId,
    required this.batchNumber,
    required this.gtin,
    required this.expiryDate,
    required this.status,
  });

  @override
  List<Object?> get props => [
    batchId,
    medicineId,
    batchNumber,
    gtin,
    expiryDate,
    status,
  ];
}
