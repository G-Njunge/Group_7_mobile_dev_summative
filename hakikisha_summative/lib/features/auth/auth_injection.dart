import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';

/// Registers the auth feature's dependencies in get_it.
///
/// M5's app-wide DI setup in `lib/core/di/` calls this once at start-up.
/// Repositories are lazy singletons (one shared instance). The AuthBloc is
/// added here as a factory in Phase 2b.
void registerAuthDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(
        auth: FirebaseAuth.instance,
        firestore: FirebaseFirestore.instance,
      ),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
    );
}
