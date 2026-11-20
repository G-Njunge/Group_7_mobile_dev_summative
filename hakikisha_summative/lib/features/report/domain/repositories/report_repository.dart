import '../entities/report_entity.dart';

abstract interface class ReportRepository {
  Stream<List<ReportEntity>> watchMyReports(String userId);

  Future<void> createCounterfeitReport({
    required String userId,
    required String pharmacyId,
    required String description,
  });

  Future<void> updatePendingReport({
    required String reportId,
    required String pharmacyId,
    required String description,
  });

  Future<void> deletePendingReport(String reportId);
}
