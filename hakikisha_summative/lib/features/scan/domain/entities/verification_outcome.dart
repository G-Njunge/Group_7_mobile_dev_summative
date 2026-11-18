enum VerificationStatus { genuine, flagged, notFound }

enum FlagReason { none, recalled, counterfeit, expired }

class VerificationResult {
  final VerificationStatus status;
  final FlagReason flagReason;
  final MedicineEntity? medicine;
  final BatchEntity? batch;

  const VerificationResult({
    required this.status,
    this.flagReason = FlagReason.none,
    this.medicine,
    this.batch,
  });
}