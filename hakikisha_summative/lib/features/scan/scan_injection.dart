import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'data/datasources/scan_remote_datasource.dart';
import 'data/repositories/scan_repository_impl.dart';
import 'domain/repositories/scan_repository.dart';
import 'domain/usecases/verify_medicine_usecase.dart';
import 'presentation/bloc/scan_bloc.dart';

/// Registers the scan feature's dependencies, in the same pattern as the
/// other features: data source and repository as lazy singletons, the bloc
/// as a factory.
void registerScanDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<ScanRemoteDataSource>(
      () => ScanRemoteDataSource(firestore: sl<FirebaseFirestore>()),
    )
    ..registerLazySingleton<ScanRepository>(
      () => ScanRepositoryImpl(remoteDataSource: sl<ScanRemoteDataSource>()),
    )
    ..registerLazySingleton<VerifyMedicineUseCase>(VerifyMedicineUseCase.new)
    ..registerFactory<ScanBloc>(
      () => ScanBloc(
        repository: sl<ScanRepository>(),
        verifyMedicineUseCase: sl<VerifyMedicineUseCase>(),
        getCurrentUserId: () => sl<FirebaseAuth>().currentUser?.uid ?? '',
      ),
    );
}
