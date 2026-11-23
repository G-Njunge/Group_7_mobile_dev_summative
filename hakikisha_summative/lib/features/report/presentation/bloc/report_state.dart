import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../pharmacy/domain/entities/pharmacy_entity.dart';
import '../../domain/entities/report_entity.dart';

enum ReportPharmacyStatus { loading, loaded, error }

enum MyReportsStatus { loading, loaded, error }

class ReportState extends Equatable {
  const ReportState({
    this.pharmacyStatus = ReportPharmacyStatus.loading,
    this.pharmacies = const [],
    this.reportsStatus = MyReportsStatus.loading,
    this.reports = const [],
    this.description = '',
    this.selectedPharmacyId,
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.actionReportId,
    this.actionErrorMessage,
    this.errorMessage,
    this.photoBytes = const [],
  });

  final ReportPharmacyStatus pharmacyStatus;
  final List<PharmacyEntity> pharmacies;
  final MyReportsStatus reportsStatus;
  final List<ReportEntity> reports;
  final String description;
  final String? selectedPharmacyId;
  final bool isSubmitting;
  final bool isSubmitted;
  final String? actionReportId;
  final String? actionErrorMessage;
  final String? errorMessage;
  final List<Uint8List> photoBytes;

  ReportState copyWith({
    ReportPharmacyStatus? pharmacyStatus,
    List<PharmacyEntity>? pharmacies,
    MyReportsStatus? reportsStatus,
    List<ReportEntity>? reports,
    String? description,
    String? selectedPharmacyId,
    bool clearSelectedPharmacyId = false,
    bool? isSubmitting,
    bool? isSubmitted,
    String? actionReportId,
    bool clearActionReportId = false,
    String? actionErrorMessage,
    bool clearActionErrorMessage = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    List<Uint8List>? photoBytes,
  }) => ReportState(
    pharmacyStatus: pharmacyStatus ?? this.pharmacyStatus,
    pharmacies: pharmacies ?? this.pharmacies,
    reportsStatus: reportsStatus ?? this.reportsStatus,
    reports: reports ?? this.reports,
    description: description ?? this.description,
    selectedPharmacyId: clearSelectedPharmacyId
        ? null
        : selectedPharmacyId ?? this.selectedPharmacyId,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isSubmitted: isSubmitted ?? this.isSubmitted,
    actionReportId: clearActionReportId
        ? null
        : actionReportId ?? this.actionReportId,
    actionErrorMessage: clearActionErrorMessage
        ? null
        : actionErrorMessage ?? this.actionErrorMessage,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    photoBytes: photoBytes ?? this.photoBytes,
  );

  @override
  List<Object?> get props => [
    pharmacyStatus,
    pharmacies,
    reportsStatus,
    reports,
    description,
    selectedPharmacyId,
    isSubmitting,
    isSubmitted,
    actionReportId,
    actionErrorMessage,
    errorMessage,
    photoBytes,
  ];
}
