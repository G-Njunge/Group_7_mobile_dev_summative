import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/pharmacy_coordinates.dart';
import '../../domain/entities/pharmacy_entity.dart';
import '../../domain/repositories/pharmacy_repository.dart';
import '../../domain/services/pharmacy_location_service.dart';
import 'pharmacy_map_state.dart';

class PharmacyMapCubit extends Cubit<PharmacyMapState> {
  PharmacyMapCubit(this._repository, this._locationService)
    : super(const PharmacyMapState());

  final PharmacyRepository _repository;
  final PharmacyLocationService _locationService;
  StreamSubscription<List<PharmacyEntity>>? _subscription;

  Future<void> start() async {
    await _subscription?.cancel();
    emit(
      state.copyWith(
        status: PharmacyMapStatus.loading,
        clearErrorMessage: true,
      ),
    );
    _subscription = _repository.watchPharmacies().listen(
      (pharmacies) => emit(
        state.copyWith(
          status: PharmacyMapStatus.loaded,
          pharmacies: pharmacies,
          clearErrorMessage: true,
        ),
      ),
      onError: (Object _) => emit(
        state.copyWith(
          status: PharmacyMapStatus.error,
          errorMessage: 'Could not load pharmacies. Please try again.',
        ),
      ),
    );
  }

  void setSearchQuery(String query) => emit(state.copyWith(searchQuery: query));

  Future<PharmacyCoordinates?> locateMe() async {
    emit(state.copyWith(isLocating: true, clearLocationError: true));
    try {
      final location = await _locationService.getCurrentLocation();
      emit(state.copyWith(currentLocation: location, isLocating: false));
      return location;
    } on PharmacyLocationFailure catch (failure) {
      emit(state.copyWith(isLocating: false, locationError: failure.message));
      return null;
    }
  }

  void clearLocationError() => emit(state.copyWith(clearLocationError: true));

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
