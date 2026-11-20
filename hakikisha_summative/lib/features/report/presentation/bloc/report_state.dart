import 'package:equatable/equatable.dart';

import '../../../pharmacy/domain/entities/pharmacy_entity.dart';

enum ReportPharmacyStatus { loading, loaded, error }

class ReportState extends Equatable {
  const ReportState({
    this.pharmacyStatus = ReportPharmacyStatus.loading,
    this.pharmacies = const [],
    this.description = '',
    this.selectedPharmacyId,
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.errorMessage,
  });

  final ReportPharmacyStatus pharmacyStatus;
  final List<PharmacyEntity> pharmacies;
  final String description;
  final String? selectedPharmacyId;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? errorMessage;

  ReportState copyWith({
    ReportPharmacyStatus? pharmacyStatus,
    List<PharmacyEntity>? pharmacies,
    String? description,
    String? selectedPharmacyId,
    bool clearSelectedPharmacyId = false,
    bool? isSubmitting,
    bool? isSubmitted,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) => ReportState(
    pharmacyStatus: pharmacyStatus ?? this.pharmacyStatus,
    pharmacies: pharmacies ?? this.pharmacies,
    description: description ?? this.description,
    selectedPharmacyId: clearSelectedPharmacyId
        ? null
        : selectedPharmacyId ?? this.selectedPharmacyId,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isSubmitted: isSubmitted ?? this.isSubmitted,
    errorMessage: clearErrorMessage
        ? null
        : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    pharmacyStatus,
    pharmacies,
    description,
    selectedPharmacyId,
    isSubmitting,
    isSubmitted,
    errorMessage,
  ];
}
