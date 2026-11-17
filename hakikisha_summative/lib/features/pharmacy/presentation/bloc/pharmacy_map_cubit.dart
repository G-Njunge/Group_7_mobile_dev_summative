import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/pharmacy_entity.dart';
import '../../domain/repositories/pharmacy_repository.dart';
import 'pharmacy_map_state.dart';

class PharmacyMapCubit extends Cubit<PharmacyMapState> {
  PharmacyMapCubit(this._repository) : super(const PharmacyMapState());

  final PharmacyRepository _repository;
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

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
