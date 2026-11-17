import 'package:equatable/equatable.dart';

import '../../domain/entities/pharmacy_coordinates.dart';
import '../../domain/entities/pharmacy_entity.dart';
import '../../domain/utils/pharmacy_search.dart';

enum PharmacyMapStatus { loading, loaded, error }

class PharmacyMapState extends Equatable {
  const PharmacyMapState({
    this.status = PharmacyMapStatus.loading,
    this.pharmacies = const [],
    this.searchQuery = '',
    this.currentLocation,
    this.isLocating = false,
    this.errorMessage,
    this.locationError,
  });

  final PharmacyMapStatus status;
  final List<PharmacyEntity> pharmacies;
  final String searchQuery;
  final PharmacyCoordinates? currentLocation;
  final bool isLocating;
  final String? errorMessage;
  final String? locationError;

  List<PharmacyEntity> get visiblePharmacies =>
      PharmacySearch.filter(pharmacies, searchQuery, from: currentLocation);

  PharmacyMapState copyWith({
    PharmacyMapStatus? status,
    List<PharmacyEntity>? pharmacies,
    String? searchQuery,
    PharmacyCoordinates? currentLocation,
    bool? isLocating,
    String? errorMessage,
    String? locationError,
    bool clearErrorMessage = false,
    bool clearLocationError = false,
  }) {
    return PharmacyMapState(
      status: status ?? this.status,
      pharmacies: pharmacies ?? this.pharmacies,
      searchQuery: searchQuery ?? this.searchQuery,
      currentLocation: currentLocation ?? this.currentLocation,
      isLocating: isLocating ?? this.isLocating,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      locationError: clearLocationError
          ? null
          : locationError ?? this.locationError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    pharmacies,
    searchQuery,
    currentLocation,
    isLocating,
    errorMessage,
    locationError,
  ];
}
