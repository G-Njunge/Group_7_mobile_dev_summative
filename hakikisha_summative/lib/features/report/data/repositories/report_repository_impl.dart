import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_data_source.dart';

import 'dart:typed_data';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._remoteDataSource);

  final ReportRemoteDataSource _remoteDataSource;

  @override
  Stream<List<ReportEntity>> watchMyReports(String userId) =>
      _remoteDataSource.watchMyReports(userId);

  @override
  Future<void> createCounterfeitReport({
    required String userId,
    required String pharmacyId,
    required String description,
    List<Uint8List> photoBytes = const [],
  }) => _remoteDataSource.createCounterfeitReport(
    userId: userId,
    pharmacyId: pharmacyId,
    description: description,
    photoBytes: photoBytes,
  );

  @override
  Future<void> updatePendingReport({
    required String reportId,
    required String pharmacyId,
    required String description,
  }) => _remoteDataSource.updatePendingReport(
    reportId: reportId,
    pharmacyId: pharmacyId,
    description: description,
  );

  @override
  Future<void> deletePendingReport(String reportId) =>
      _remoteDataSource.deletePendingReport(reportId);
}
