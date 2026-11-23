import '../entities/report_entity.dart';

import 'dart:typed_data';

abstract interface class ReportRepository {
  Stream<List<ReportEntity>> watchMyReports(String userId);

  Future<void> createCounterfeitReport({
    required String userId,
    required String pharmacyId,
    required String description,
    List<Uint8List> photoBytes = const [],
  });

  Future<void> updatePendingReport({
    required String reportId,
    required String pharmacyId,
    required String description,
  });

  Future<void> deletePendingReport(String reportId);
}
