import '../../domain/entities/report_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._remoteDataSource);

  final ReportRemoteDataSource _remoteDataSource;

  @override
  Stream<List<ReportEntity>> watchMyReports(String userId) =>
      _remoteDataSource.watchMyReports(userId);

  @override
  Future<void> createReport({
    required String userId,
    required ReportDraft draft,
  }) => _remoteDataSource.createReport(userId: userId, draft: draft.normalized);

  @override
  Future<void> updatePendingReport({
    required String reportId,
    required ReportDraft draft,
  }) => _remoteDataSource.updatePendingReport(
    reportId: reportId,
    draft: draft.normalized,
  );

  @override
  Future<void> deletePendingReport(String reportId) =>
      _remoteDataSource.deletePendingReport(reportId);
}
