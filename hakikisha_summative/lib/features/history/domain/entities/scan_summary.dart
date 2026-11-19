import 'package:equatable/equatable.dart';

import 'scan_entity.dart';

/// A scan plus the medicine name to show on the card.
/// The name lives in `medicines`, not in `scans`, so we keep it out of
/// ScanEntity and avoid duplicating data (the ERD forbids it).
class ScanSummary extends Equatable {
  final ScanEntity scan;
  final String medicineName;

  const ScanSummary({required this.scan, required this.medicineName});

  @override
  List<Object?> get props => [scan, medicineName];
}
