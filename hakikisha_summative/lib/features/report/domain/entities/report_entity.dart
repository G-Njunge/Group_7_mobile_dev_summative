import 'package:equatable/equatable.dart';

class ReportEntity extends Equatable {
  const ReportEntity({
    required this.reportId,
    required this.pharmacyId,
    required this.description,
    required this.status,
    this.createdAt,
  });

  final String reportId;
  final String pharmacyId;
  final String description;
  final String status;
  final DateTime? createdAt;

  bool get isPending => status == 'pending';

  @override
  List<Object?> get props => [
    reportId,
    pharmacyId,
    description,
    status,
    createdAt,
  ];
}
