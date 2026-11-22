import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import 'data/datasources/profile_remote_data_source.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'domain/repositories/profile_repository.dart';
import 'presentation/bloc/profile_cubit.dart';

/// Registers the profile feature's dependencies in get_it, in the same
/// pattern as the auth and pharmacy features. Data classes are lazy
/// singletons, and the cubit is a factory so each visit starts fresh.
void registerProfileDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSource(sl<FirebaseFirestore>()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
    )
    ..registerFactory<ProfileCubit>(
      () => ProfileCubit(sl<ProfileRepository>()),
    );
}
