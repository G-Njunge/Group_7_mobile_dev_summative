import '../entities/batch_entity.dart';
import '../entities/medicine_entity.dart';
import '../entities/verification_outcome.dart';

class VerifyMedicineUseCase {
  VerificationResult evaluate({
    required BatchEntity? batch,
    required MedicineEntity? medicine,
    DateTime? currentDate,
  }) {
    if (batch == null || medicine == null) {
      return const VerificationResult(status: VerificationStatus.notFound);
    }

    final now = currentDate ?? DateTime.now();
    final normalizedStatus = batch.status.toLowerCase().trim();

    if (normalizedStatus == 'recalled') {
      return VerificationResult(
        status: VerificationStatus.flagged,
        flagReason: FlagReason.recalled,
        medicine: medicine,
        batch: batch,
      );
    }

    if (normalizedStatus == 'counterfeit') {
      return VerificationResult(
        status: VerificationStatus.flagged,
        flagReason: FlagReason.counterfeit,
        medicine: medicine,
        batch: batch,
      );
    }

    if (batch.expiryDate.isBefore(now)) {
      return VerificationResult(
        status: VerificationStatus.flagged,
        flagReason: FlagReason.expired,
        medicine: medicine,
        batch: batch,
      );
    }

    return VerificationResult(
      status: VerificationStatus.genuine,
      medicine: medicine,
      batch: batch,
    );
  }
}