import '../entities/report_entity.dart';

abstract interface class ReportRepository {
  /// The signed-in user's reports, newest first.
  Stream<List<ReportEntity>> watchMyReports(String userId);

  Future<void> createReport({
    required String userId,
    required ReportDraft draft,
  });

  /// Only works while the report is pending (enforced by firestore.rules).
  Future<void> updatePendingReport({
    required String reportId,
    required ReportDraft draft,
  });

  /// Withdraws a pending report.
  Future<void> deletePendingReport(String reportId);
}
