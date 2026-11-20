import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../pharmacy/domain/entities/pharmacy_entity.dart';
import '../../../pharmacy/domain/repositories/pharmacy_repository.dart';
import '../../domain/repositories/report_repository.dart';
import 'report_state.dart';

class ReportCubit extends Cubit<ReportState> {
  ReportCubit(this._reportRepository, this._pharmacyRepository)
    : super(const ReportState());

  final ReportRepository _reportRepository;
  final PharmacyRepository _pharmacyRepository;
  StreamSubscription<List<PharmacyEntity>>? _pharmacySubscription;

  Future<void> start() async {
    await _pharmacySubscription?.cancel();
    emit(
      state.copyWith(
        pharmacyStatus: ReportPharmacyStatus.loading,
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
  }

  void setDescription(String description) => emit(
    state.copyWith(description: description, clearErrorMessage: true),
  );

  void selectPharmacy(String? pharmacyId) => emit(
    state.copyWith(
      selectedPharmacyId: pharmacyId,
      clearSelectedPharmacyId: pharmacyId == null,
      clearErrorMessage: true,
    ),
  );

  Future<void> submit({required String userId}) async {
    if (state.isSubmitting || state.isSubmitted) return;

    final description = state.description.trim();
    final pharmacyId = state.selectedPharmacyId;
    if (description.isEmpty) {
      emit(
        state.copyWith(
          errorMessage: 'Enter a description of the suspected counterfeit.',
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

  @override
  Future<void> close() async {
    await _pharmacySubscription?.cancel();
    return super.close();
  }
}
