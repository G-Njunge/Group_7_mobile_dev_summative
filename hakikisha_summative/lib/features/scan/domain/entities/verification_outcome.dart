import 'package:equatable/equatable.dart';

import 'batch_entity.dart';
import 'medicine_entity.dart';

enum VerificationStatus { genuine, flagged, notFound }

enum FlagReason { none, recalled, counterfeit, expired }

class VerificationResult extends Equatable {
  final VerificationStatus status;
  final FlagReason flagReason;
  final MedicineEntity? medicine;
  final BatchEntity? batch;
  final String queriedCode;

  const VerificationResult({
    required this.status,
    this.flagReason = FlagReason.none,
    this.medicine,
    this.batch,
    required this.queriedCode,
  });

  String get firestoreResultValue {
    switch (status) {
      case VerificationStatus.genuine:
        return 'genuine';
      case VerificationStatus.flagged:
        return 'flagged';
      case VerificationStatus.notFound:
        return 'notFound';
    }
  }

  @override
  List<Object?> get props => [status, flagReason, medicine, batch, queriedCode];
}
