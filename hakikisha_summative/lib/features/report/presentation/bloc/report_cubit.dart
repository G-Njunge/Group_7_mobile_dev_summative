import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../pharmacy/domain/entities/pharmacy_entity.dart';
import '../../../pharmacy/domain/repositories/pharmacy_repository.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import 'report_state.dart';

/// Report a medicine (create) and My reports (read, edit, withdraw).
class ReportCubit extends Cubit<ReportState> {
  ReportCubit(this._reportRepository, this._pharmacyRepository)
    : super(const ReportState());

  final ReportRepository _reportRepository;
  final PharmacyRepository _pharmacyRepository;
  StreamSubscription<List<PharmacyEntity>>? _pharmacySubscription;
  StreamSubscription<List<ReportEntity>>? _reportsSubscription;

  /// Starts listening to pharmacies and the user's reports. [prefill] fills
  /// the form, e.g. with the medicine and batch from a scan result.
  Future<void> start({required String userId, ReportDraft? prefill}) async {
    // Applied before the first await, so the form's first frame already shows
    // the prefilled medicine and batch.
    emit(
      state.copyWith(
        pharmacyStatus: ReportPharmacyStatus.loading,
        reportsStatus: MyReportsStatus.loading,
        draft: prefill ?? state.draft,
        clearErrorMessage: true,
      ),
    );
    await _cancelSubscriptions();
    _pharmacySubscription = _pharmacyRepository.watchPharmacies().listen(
      (pharmacies) {
        // Drop a selected pharmacy that no longer exists.
        final selected = state.draft.pharmacyId;
        final stillListed = pharmacies.any((p) => p.pharmacyId == selected);
        emit(
          state.copyWith(
            pharmacyStatus: ReportPharmacyStatus.loaded,
            pharmacies: pharmacies,
            draft: stillListed
                ? null
                : state.draft.copyWith(clearPharmacyId: true),
          ),
        );
      },
      // A missing pharmacy list never blocks a report: the user can type
      // where they bought the medicine instead.
      onError: (Object _) =>
          emit(state.copyWith(pharmacyStatus: ReportPharmacyStatus.error)),
    );
    _reportsSubscription = _reportRepository
        .watchMyReports(userId)
        .listen(
          (reports) => emit(
            state.copyWith(
              reportsStatus: MyReportsStatus.loaded,
              reports: reports,
            ),
          ),
          onError: (Object _) => emit(
            state.copyWith(
              reportsStatus: MyReportsStatus.error,
              errorMessage: "We couldn't load your reports. Please try again.",
            ),
          ),
        );
  }

  /// Updates the form as the user types.
  void updateDraft(ReportDraft draft) =>
      emit(state.copyWith(draft: draft, clearErrorMessage: true));

  Future<void> submit({required String userId}) async {
    if (state.isSubmitting || state.isSubmitted) return;
    final error = state.draft.validationError;
    if (error != null) {
      emit(state.copyWith(errorMessage: error));
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearErrorMessage: true));
    try {
      await _reportRepository.createReport(userId: userId, draft: state.draft);
      emit(state.copyWith(isSubmitting: false, isSubmitted: true));
    } on Object {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: "We couldn't send your report. Check your connection and try again.",
        ),
      );
    }
  }

  /// Saves an edit to a pending report. Returns `true` when it was saved.
  Future<bool> updateReport({
    required ReportEntity report,
    required ReportDraft draft,
  }) async {
    if (!_canChange(report)) return false;
    final error = draft.validationError;
    if (error != null) {
      emit(state.copyWith(actionErrorMessage: error));
      return false;
    }
    return _runAction(
      report,
      () => _reportRepository.updatePendingReport(
        reportId: report.reportId,
        draft: draft,
      ),
      failure: "We couldn't update the report. Please try again.",
    );
  }

  /// Withdraws (deletes) a pending report. Returns `true` when it was deleted.
  Future<bool> deleteReport(ReportEntity report) async {
    if (!_canChange(report)) return false;
    return _runAction(
      report,
      () => _reportRepository.deletePendingReport(report.reportId),
      failure: "We couldn't withdraw the report. Please try again.",
    );
  }

  Future<bool> _runAction(
    ReportEntity report,
    Future<void> Function() action, {
    required String failure,
  }) async {
    emit(
      state.copyWith(
        actionReportId: report.reportId,
        clearActionErrorMessage: true,
      ),
    );
    try {
      await action();
      emit(state.copyWith(clearActionReportId: true));
      return true;
    } on Object {
      emit(
        state.copyWith(clearActionReportId: true, actionErrorMessage: failure),
      );
      return false;
    }
  }

  /// Only the user's own pending reports can change, and one at a time.
  bool _canChange(ReportEntity report) =>
      state.actionReportId == null &&
      state.reports.any((r) => r.reportId == report.reportId && r.isPending);

  Future<void> _cancelSubscriptions() async {
    await _pharmacySubscription?.cancel();
    await _reportsSubscription?.cancel();
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    return super.close();
  }
}
