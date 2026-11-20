import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import 'data/datasources/geolocator_pharmacy_location_service.dart';
import 'data/datasources/pharmacy_remote_data_source.dart';
import 'data/repositories/pharmacy_repository_impl.dart';
import 'domain/repositories/pharmacy_repository.dart';
import 'domain/services/pharmacy_location_service.dart';
import 'presentation/bloc/pharmacy_map_cubit.dart';

/// Registers the pharmacy feature's dependencies in get_it.
///
/// Same pattern as `auth_injection.dart`: data classes are lazy singletons,
/// the cubit is a factory so every visit to the map starts fresh. M5's
/// app-wide DI in `lib/core/di/` can call this once it exists.
void registerPharmacyDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<PharmacyRemoteDataSource>(
      () => PharmacyRemoteDataSource(FirebaseFirestore.instance),
    )
    ..registerLazySingleton<PharmacyRepository>(
      () => PharmacyRepositoryImpl(sl<PharmacyRemoteDataSource>()),
    )
    ..registerLazySingleton<PharmacyLocationService>(
      GeolocatorPharmacyLocationService.new,
    )
    ..registerFactory<PharmacyMapCubit>(
      () => PharmacyMapCubit(
        sl<PharmacyRepository>(),
        sl<PharmacyLocationService>(),
      ),
    );
}
