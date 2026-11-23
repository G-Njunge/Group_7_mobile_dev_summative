import '../entities/batch_entity.dart';
import '../entities/medicine_entity.dart';
import '../entities/verification_outcome.dart';

class VerifyMedicineUseCase {
  VerificationResult execute({
    required String queriedCode,
    required BatchEntity? batch,
    required MedicineEntity? medicine,
    DateTime? clock,
  }) {
    if (batch == null || medicine == null) {
      return VerificationResult(
        status: VerificationStatus.notFound,
        queriedCode: queriedCode,
      );
    }

    final now = clock ?? DateTime.now();
    final normalizedStatus = batch.status.trim().toLowerCase();

    if (normalizedStatus == 'recalled') {
      return VerificationResult(
        status: VerificationStatus.flagged,
        flagReason: FlagReason.recalled,
        medicine: medicine,
        batch: batch,
        queriedCode: queriedCode,
      );
    }

    if (normalizedStatus == 'counterfeit') {
      return VerificationResult(
        status: VerificationStatus.flagged,
        flagReason: FlagReason.counterfeit,
        medicine: medicine,
        batch: batch,
        queriedCode: queriedCode,
      );
    }

    // Compare date-only or exact timestamp so packs expiring today remain valid until day end
    final expiryEndOfDay = DateTime(
      batch.expiryDate.year,
      batch.expiryDate.month,
      batch.expiryDate.day,
      23,
      59,
      59,
    );

    if (expiryEndOfDay.isBefore(now)) {
      return VerificationResult(
        status: VerificationStatus.flagged,
        flagReason: FlagReason.expired,
        medicine: medicine,
        batch: batch,
        queriedCode: queriedCode,
      );
    }

    return VerificationResult(
      status: VerificationStatus.genuine,
      medicine: medicine,
      batch: batch,
      queriedCode: queriedCode,
    );
  }
}
