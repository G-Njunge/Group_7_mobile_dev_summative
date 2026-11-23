import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../pharmacy/domain/entities/pharmacy_entity.dart';
import '../../../pharmacy/domain/repositories/pharmacy_repository.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  ReportCubit(this._reportRepository, this._pharmacyRepository)
    : super(const ReportState());

  final ReportRepository _reportRepository;
  final PharmacyRepository _pharmacyRepository;
  StreamSubscription<List<PharmacyEntity>>? _pharmacySubscription;
  StreamSubscription<List<ReportEntity>>? _reportsSubscription;

  Future<void> start({required String userId}) async {
    await Future.wait([
      _pharmacySubscription?.cancel() ?? Future<void>.value(),
      _reportsSubscription?.cancel() ?? Future<void>.value(),
    ]);
    emit(
      state.copyWith(
        pharmacyStatus: ReportPharmacyStatus.loading,
        reportsStatus: MyReportsStatus.loading,
        clearErrorMessage: true,
      ),
    );
    _pharmacySubscription = _pharmacyRepository.watchPharmacies().listen(
      (pharmacies) {
        final selectedPharmacyExists = pharmacies.any(
          (pharmacy) => pharmacy.pharmacyId == state.selectedPharmacyId,
        );
        emit(
          state.copyWith(
            pharmacyStatus: ReportPharmacyStatus.loaded,
            pharmacies: pharmacies,
            clearSelectedPharmacyId: !selectedPharmacyExists,
            clearErrorMessage: true,
          ),
        );
      },
      onError: (Object _) => emit(
        state.copyWith(
          pharmacyStatus: ReportPharmacyStatus.error,
          errorMessage: 'Could not load pharmacies. Please try again.',
        ),
      ),
    );
    _reportsSubscription = _reportRepository
        .watchMyReports(userId)
        .listen(
          (reports) => emit(
            state.copyWith(
              reportsStatus: MyReportsStatus.loaded,
              reports: reports,
              clearErrorMessage: true,
            ),
          ),
          onError: (Object _) => emit(
            state.copyWith(
              reportsStatus: MyReportsStatus.error,
              errorMessage: 'Could not load your reports. Please try again.',
            ),
          ),
        );
  }

  void setDescription(String description) =>
      emit(state.copyWith(description: description, clearErrorMessage: true));

  void selectPharmacy(String? pharmacyId) => emit(
    state.copyWith(
      selectedPharmacyId: pharmacyId,
      clearSelectedPharmacyId: pharmacyId == null,
      clearErrorMessage: true,
    ),
  );

  void setPhotos(List<Uint8List> photoBytes) {
    if (photoBytes.length > 3) {
      photoBytes = photoBytes.take(3).toList();
    }
    emit(state.copyWith(photoBytes: photoBytes, clearErrorMessage: true));
  }

  void removePhoto(int index) {
    if (index < 0 || index >= state.photoBytes.length) return;
    emit(
      state.copyWith(
        photoBytes: List<Uint8List>.of(state.photoBytes)..removeAt(index),
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> submit({required String userId}) async {
    if (state.isSubmitting || state.isSubmitted) return;

    final description = state.description.trim();
    final pharmacyId = state.selectedPharmacyId;
    if (description.isEmpty || description.length > 2000) {
      emit(
        state.copyWith(
          errorMessage: description.isEmpty
              ? 'Enter a description of the suspected counterfeit.'
              : 'Description must be 2000 characters or fewer.',
        ),
      );
      return;
    }
    if (pharmacyId == null ||
        !state.pharmacies.any(
          (pharmacy) => pharmacy.pharmacyId == pharmacyId,
        )) {
      emit(state.copyWith(errorMessage: 'Select a pharmacy.'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));
    try {
      await _reportRepository.createCounterfeitReport(
        userId: userId,
        pharmacyId: pharmacyId,
        description: description,
        photoBytes: state.photoBytes,
      );
      emit(state.copyWith(isSubmitting: false, isSubmitted: true));
    } on Object {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Could not submit the report. Please try again.',
        ),
      );
    }
  }

  Future<bool> updateReport({
    required ReportEntity report,
    required String description,
    required String pharmacyId,
  }) async {
    if (!_canEdit(report) || state.actionReportId != null) return false;
    final trimmedDescription = description.trim();
    if (trimmedDescription.isEmpty || trimmedDescription.length > 2000) {
      emit(
        state.copyWith(
          actionErrorMessage: trimmedDescription.isEmpty
              ? 'Enter a description.'
              : 'Description must be 2000 characters or fewer.',
          clearErrorMessage: true,
        ),
      );
      return false;
    }
    if (!state.pharmacies.any(
      (pharmacy) => pharmacy.pharmacyId == pharmacyId,
    )) {
      emit(
        state.copyWith(
          actionErrorMessage: 'Select a pharmacy.',
          clearErrorMessage: true,
        ),
      );
      return false;
    }

    emit(
      state.copyWith(
        actionReportId: report.reportId,
        clearActionErrorMessage: true,
      ),
    );
    try {
      await _reportRepository.updatePendingReport(
        reportId: report.reportId,
        pharmacyId: pharmacyId,
        description: trimmedDescription,
      );
      emit(state.copyWith(clearActionReportId: true));
      return true;
    } on Object {
      emit(
        state.copyWith(
          clearActionReportId: true,
          actionErrorMessage: 'Could not update the report. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<bool> deleteReport(ReportEntity report) async {
    if (!_canEdit(report) || state.actionReportId != null) return false;
    emit(
      state.copyWith(
        actionReportId: report.reportId,
        clearActionErrorMessage: true,
      ),
    );
    try {
      await _reportRepository.deletePendingReport(report.reportId);
      emit(state.copyWith(clearActionReportId: true));
      return true;
    } on Object {
      emit(
        state.copyWith(
          clearActionReportId: true,
          actionErrorMessage:
              'Could not withdraw the report. Please try again.',
        ),
      );
      return false;
    }
  }

  bool _canEdit(ReportEntity report) =>
      report.isPending &&
      state.reports.any(
        (ownedReport) =>
            ownedReport.reportId == report.reportId && ownedReport.isPending,
      );

  @override
  Future<void> close() async {
    await Future.wait([
      _pharmacySubscription?.cancel() ?? Future<void>.value(),
      _reportsSubscription?.cancel() ?? Future<void>.value(),
    ]);
    return super.close();
  }
}
