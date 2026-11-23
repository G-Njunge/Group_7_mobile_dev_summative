import 'dart:async';

import 'package:hakikisha_summative/features/pharmacy/domain/entities/pharmacy_entity.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/repositories/pharmacy_repository.dart';
import 'package:hakikisha_summative/features/report/domain/entities/report_entity.dart';
import 'package:hakikisha_summative/features/report/domain/repositories/report_repository.dart';

/// Shared fakes for the report cubit and page tests.
class FakePharmacyRepository implements PharmacyRepository {
  final controller = StreamController<List<PharmacyEntity>>.broadcast();

  @override
  Stream<List<PharmacyEntity>> watchPharmacies() => controller.stream;
}

class FakeReportRepository implements ReportRepository {
  final controller = StreamController<List<ReportEntity>>.broadcast();
  ReportDraft? created;
  ReportDraft? updated;
  String? updatedReportId;
  String? deletedReportId;
  Object? failure;

  @override
  Stream<List<ReportEntity>> watchMyReports(String userId) => controller.stream;

  @override
  Future<void> createReport({
    required String userId,
    required ReportDraft draft,
  }) async {
    if (failure != null) throw failure!;
    created = draft;
  }

  @override
  Future<void> updatePendingReport({
    required String reportId,
    required ReportDraft draft,
  }) async {
    if (failure != null) throw failure!;
    updatedReportId = reportId;
    updated = draft;
  }

  @override
  Future<void> deletePendingReport(String reportId) async {
    if (failure != null) throw failure!;
    deletedReportId = reportId;
  }
}

const testPharmacy = PharmacyEntity(
  pharmacyId: 'ph_kigali_central',
  name: 'Kigali Central Pharmacy',
  licenseNo: 'DEMO-LIC-001',
  address: 'KN 4 Ave, Nyarugenge, Kigali',
  latitude: -1.9499,
  longitude: 30.0588,
  phone: '+250788000001',
  verified: true,
);

const validDraft = ReportDraft(
  medicineName: 'Coartem 80/480',
  batchNumber: 'CT24-0412',
  description: 'The seal was broken.',
);
