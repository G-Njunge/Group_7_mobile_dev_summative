import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._remoteDataSource);

  final ReportRemoteDataSource _remoteDataSource;

  @override
  Future<void> createCounterfeitReport({
    required String userId,
    required String pharmacyId,
    required String description,
  }) => _remoteDataSource.createCounterfeitReport(
    userId: userId,
    pharmacyId: pharmacyId,
    description: description,
  );
}
