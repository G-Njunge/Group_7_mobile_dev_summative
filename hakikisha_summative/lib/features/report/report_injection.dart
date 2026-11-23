import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

import '../pharmacy/domain/repositories/pharmacy_repository.dart';
import 'data/datasources/report_remote_data_source.dart';
import 'data/repositories/report_repository_impl.dart';
import 'domain/repositories/report_repository.dart';
import 'presentation/bloc/report_cubit.dart';

void registerReportDependencies(GetIt sl) {
  sl
    ..registerLazySingleton<ReportRemoteDataSource>(
      () => ReportRemoteDataSource(sl<FirebaseFirestore>()),
    )
    ..registerLazySingleton<ReportRepository>(
      () => ReportRepositoryImpl(sl<ReportRemoteDataSource>()),
    )
    ..registerFactory<ReportCubit>(
      () => ReportCubit(sl<ReportRepository>(), sl<PharmacyRepository>()),
    );
}
