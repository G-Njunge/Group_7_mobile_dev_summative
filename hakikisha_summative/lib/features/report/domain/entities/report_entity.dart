import 'package:equatable/equatable.dart';

/// A counterfeit report as stored in the `reports` collection.
class ReportEntity extends Equatable {
  const ReportEntity({
    required this.reportId,
    required this.description,
    required this.status,
    this.medicineName = '',
    this.batchNumber,
    this.purchaseLocation,
    this.pharmacyId,
    this.createdAt,
    this.photoUrls = const [],
  });

  final String reportId;

  /// Empty for reports filed before the field existed.
  final String medicineName;
  final String? batchNumber;

  /// Free-text place of purchase, used when the shop isn't in [pharmacyId].
  final String? purchaseLocation;
  final String? pharmacyId;

  /// "What looked wrong?"
  final String description;
  final String status;
  final DateTime? createdAt;

  /// Always empty while the app doesn't use Cloud Storage; kept so photos can
  /// be added later without changing the data model.
  final List<String> photoUrls;

  bool get isPending => status == 'pending';

  /// The form fields, for editing this report.
  ReportDraft get draft => ReportDraft(
    medicineName: medicineName,
    batchNumber: batchNumber,
    purchaseLocation: purchaseLocation,
    pharmacyId: pharmacyId,
    description: description,
  );

  @override
  List<Object?> get props => [
    reportId,
    medicineName,
    batchNumber,
    purchaseLocation,
    pharmacyId,
    description,
    status,
    createdAt,
    photoUrls,
  ];
}

/// What the user fills in on the report form, for creating or editing.
class ReportDraft extends Equatable {
  const ReportDraft({
    this.medicineName = '',
    this.batchNumber,
    this.purchaseLocation,
    this.pharmacyId,
    this.description = '',
  });

  final String medicineName;
  final String? batchNumber;
  final String? purchaseLocation;
  final String? pharmacyId;
  final String description;

  static const maxMedicineName = 120;
  static const maxBatchNumber = 64;
  static const maxPurchaseLocation = 200;
  static const maxDescription = 2000;

  /// Trimmed copy with blank optional fields turned into `null`.
  ReportDraft get normalized {
    String? orNull(String? value) =>
        value == null || value.trim().isEmpty ? null : value.trim();
    return ReportDraft(
      medicineName: medicineName.trim(),
      batchNumber: orNull(batchNumber)?.toUpperCase(),
      purchaseLocation: orNull(purchaseLocation),
      pharmacyId: orNull(pharmacyId),
      description: description.trim(),
    );
  }

  /// A polite message for the first problem, or `null` when it can be sent.
  /// Mirrors the limits in firestore.rules.
  String? get validationError {
    final d = normalized;
    if (d.medicineName.isEmpty) return 'Enter the name of the medicine.';
    if (d.medicineName.length > maxMedicineName) {
      return 'Keep the medicine name under $maxMedicineName characters.';
    }
    if ((d.batchNumber?.length ?? 0) > maxBatchNumber) {
      return 'Keep the batch number under $maxBatchNumber characters.';
    }
    if ((d.purchaseLocation?.length ?? 0) > maxPurchaseLocation) {
      return 'Keep the place of purchase under $maxPurchaseLocation characters.';
    }
    if (d.description.isEmpty) return 'Tell us what looked wrong.';
    if (d.description.length > maxDescription) {
      return 'Keep the description under $maxDescription characters.';
    }
    return null;
  }

  ReportDraft copyWith({
    String? medicineName,
    String? batchNumber,
    String? purchaseLocation,
    String? pharmacyId,
    bool clearPharmacyId = false,
    String? description,
  }) => ReportDraft(
    medicineName: medicineName ?? this.medicineName,
    batchNumber: batchNumber ?? this.batchNumber,
    purchaseLocation: purchaseLocation ?? this.purchaseLocation,
    pharmacyId: clearPharmacyId ? null : pharmacyId ?? this.pharmacyId,
    description: description ?? this.description,
  );

  @override
  List<Object?> get props => [
    medicineName,
    batchNumber,
    purchaseLocation,
    pharmacyId,
    description,
  ];
}
