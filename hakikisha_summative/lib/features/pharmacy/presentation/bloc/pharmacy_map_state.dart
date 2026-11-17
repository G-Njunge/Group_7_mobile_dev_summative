import 'package:equatable/equatable.dart';

import '../../domain/entities/pharmacy_entity.dart';
import '../../domain/utils/pharmacy_search.dart';

enum PharmacyMapStatus { loading, loaded, error }

class PharmacyMapState extends Equatable {
  const PharmacyMapState({
    this.status = PharmacyMapStatus.loading,
    this.pharmacies = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  final PharmacyMapStatus status;
  final List<PharmacyEntity> pharmacies;
  final String searchQuery;
  final String? errorMessage;

  List<PharmacyEntity> get visiblePharmacies =>
      PharmacySearch.filter(pharmacies, searchQuery);

  PharmacyMapState copyWith({
    PharmacyMapStatus? status,
    List<PharmacyEntity>? pharmacies,
    String? searchQuery,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return PharmacyMapState(
      status: status ?? this.status,
      pharmacies: pharmacies ?? this.pharmacies,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, pharmacies, searchQuery, errorMessage];
}
