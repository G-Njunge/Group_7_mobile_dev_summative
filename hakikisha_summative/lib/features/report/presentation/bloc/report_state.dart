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
    this.draft = const ReportDraft(),
    this.isSubmitting = false,
    this.isSubmitted = false,
    this.actionReportId,
    this.actionErrorMessage,
    this.errorMessage,
  });

  final ReportPharmacyStatus pharmacyStatus;
  final List<PharmacyEntity> pharmacies;
  final MyReportsStatus reportsStatus;
  final List<ReportEntity> reports;

  /// What the user has typed on the report form so far.
  final ReportDraft draft;
  final bool isSubmitting;
  final bool isSubmitted;

  /// The report being edited or withdrawn on My reports, if any.
  final String? actionReportId;
  final String? actionErrorMessage;
  final String? errorMessage;

  /// Name of the pharmacy with [pharmacyId], or `null` if it isn't listed.
  String? pharmacyName(String? pharmacyId) {
    for (final pharmacy in pharmacies) {
      if (pharmacy.pharmacyId == pharmacyId) return pharmacy.name;
    }
    return null;
  }

  ReportState copyWith({
    ReportPharmacyStatus? pharmacyStatus,
    List<PharmacyEntity>? pharmacies,
    MyReportsStatus? reportsStatus,
    List<ReportEntity>? reports,
    ReportDraft? draft,
    bool? isSubmitting,
    bool? isSubmitted,
    String? actionReportId,
    bool clearActionReportId = false,
    String? actionErrorMessage,
    bool clearActionErrorMessage = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) => ReportState(
    pharmacyStatus: pharmacyStatus ?? this.pharmacyStatus,
    pharmacies: pharmacies ?? this.pharmacies,
    reportsStatus: reportsStatus ?? this.reportsStatus,
    reports: reports ?? this.reports,
    draft: draft ?? this.draft,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isSubmitted: isSubmitted ?? this.isSubmitted,
    actionReportId: clearActionReportId
        ? null
        : actionReportId ?? this.actionReportId,
    actionErrorMessage: clearActionErrorMessage
        ? null
        : actionErrorMessage ?? this.actionErrorMessage,
    errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    pharmacyStatus,
    pharmacies,
    reportsStatus,
    reports,
    draft,
    isSubmitting,
    isSubmitted,
    actionReportId,
    actionErrorMessage,
    errorMessage,
  ];
}
