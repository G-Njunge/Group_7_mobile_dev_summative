import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import 'data/datasources/history_remote_data_source.dart';
import 'data/repositories/history_repository_impl.dart';
import 'domain/repositories/history_repository.dart';
import 'presentation/bloc/history_cubit.dart';

/// Registers the history feature's dependencies in get_it, in the same
/// pattern as auth, pharmacy and profile.
void registerHistoryDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<HistoryRemoteDataSource>(
      () => HistoryRemoteDataSource(sl<FirebaseFirestore>()),
    )
    ..registerLazySingleton<HistoryRepository>(
      () => HistoryRepositoryImpl(sl<HistoryRemoteDataSource>()),
    )
    ..registerFactory<HistoryCubit>(
      () => HistoryCubit(sl<HistoryRepository>()),
    );
}
