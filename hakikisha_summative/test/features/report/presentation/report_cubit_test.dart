import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/entities/pharmacy_entity.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/repositories/pharmacy_repository.dart';
import 'package:hakikisha_summative/features/report/domain/entities/report_entity.dart';
import 'package:hakikisha_summative/features/report/domain/repositories/report_repository.dart';
import 'package:hakikisha_summative/features/report/presentation/bloc/report_cubit.dart';

class FakePharmacyRepository implements PharmacyRepository {
  final controller = StreamController<List<PharmacyEntity>>.broadcast();

  @override
  Stream<List<PharmacyEntity>> watchPharmacies() => controller.stream;
}

class FakeReportsStream {
  final controller = StreamController<List<ReportEntity>>.broadcast();
}

class FakeReportRepository implements ReportRepository {
  final reports = FakeReportsStream();
  String? userId;
  String? pharmacyId;
  String? description;
  String? updatedReportId;
  String? deletedReportId;
  Object? failure;

  @override
  Stream<List<ReportEntity>> watchMyReports(String userId) =>
      reports.controller.stream;

  @override
  Future<void> createCounterfeitReport({
    required String userId,
    required String pharmacyId,
    required String description,
  }) async {
    if (failure != null) throw failure!;
    this.userId = userId;
    this.pharmacyId = pharmacyId;
    this.description = description;
  }

  @override
  Future<void> updatePendingReport({
    required String reportId,
    required String pharmacyId,
    required String description,
  }) async {
    if (failure != null) throw failure!;
    updatedReportId = reportId;
    this.pharmacyId = pharmacyId;
    this.description = description;
  }

  @override
  Future<void> deletePendingReport(String reportId) async {
    if (failure != null) throw failure!;
    deletedReportId = reportId;
  }
}

void main() {
  const pharmacy = PharmacyEntity(
    pharmacyId: 'pharmacy-1',
    name: 'Central Pharmacy',
    licenseNo: 'PPB-001',
    address: 'Nyarugenge, Kigali',
    latitude: -1.267,
    longitude: 36.81,
    phone: '+250788000001',
    verified: true,
  );
  const pendingReport = ReportEntity(
    reportId: 'report-1',
    pharmacyId: 'pharmacy-1',
    description: 'Suspected counterfeit.',
    status: 'pending',
  );

  late FakePharmacyRepository pharmacies;
  late FakeReportRepository reports;
  late ReportCubit cubit;

  setUp(() {
    pharmacies = FakePharmacyRepository();
    reports = FakeReportRepository();
    cubit = ReportCubit(reports, pharmacies);
  });

  tearDown(() async {
    await cubit.close();
    await pharmacies.controller.close();
    await reports.reports.controller.close();
  });

  test(
    'creates a report for the selected pharmacy and signed-in user',
    () async {
      await cubit.start(userId: 'user-1');
      pharmacies.controller.add([pharmacy]);
      await Future<void>.delayed(Duration.zero);
      cubit
        ..setDescription('  Tampered medicine packaging  ')
        ..selectPharmacy(pharmacy.pharmacyId);

      await cubit.submit(userId: 'user-1');

      expect(reports.userId, 'user-1');
      expect(reports.pharmacyId, pharmacy.pharmacyId);
      expect(reports.description, 'Tampered medicine packaging');
      expect(cubit.state.isSubmitted, isTrue);
    },
  );

  test('does not create a report without a description or pharmacy', () async {
    await cubit.submit(userId: 'user-1');

    expect(reports.description, isNull);
    expect(cubit.state.errorMessage, contains('description'));

    cubit.setDescription('Suspicious medicine.');
    await cubit.submit(userId: 'user-1');

    expect(reports.description, isNull);
    expect(cubit.state.errorMessage, 'Select a pharmacy.');
  });

  test('exposes report submission failures', () async {
    await cubit.start(userId: 'user-1');
    pharmacies.controller.add([pharmacy]);
    await Future<void>.delayed(Duration.zero);
    cubit
      ..setDescription('Suspicious medicine.')
      ..selectPharmacy(pharmacy.pharmacyId);
    reports.failure = StateError('offline');

    await cubit.submit(userId: 'user-1');

    expect(cubit.state.isSubmitting, isFalse);
    expect(cubit.state.isSubmitted, isFalse);
    expect(cubit.state.errorMessage, contains('Could not submit'));
  });

  test('updates only a pending report from the user report stream', () async {
    await cubit.start(userId: 'user-1');
    pharmacies.controller.add([pharmacy]);
    reports.reports.controller.add([pendingReport]);
    await Future<void>.delayed(Duration.zero);

    final updated = await cubit.updateReport(
      report: pendingReport,
      description: '  Updated description  ',
      pharmacyId: pharmacy.pharmacyId,
    );

    expect(updated, isTrue);
    expect(reports.updatedReportId, pendingReport.reportId);
    expect(reports.description, 'Updated description');
  });

  test('does not update or delete a reviewed report', () async {
    final reviewed = ReportEntity(
      reportId: pendingReport.reportId,
      pharmacyId: pendingReport.pharmacyId,
      description: pendingReport.description,
      status: 'reviewed',
    );
    await cubit.start(userId: 'user-1');
    reports.reports.controller.add([reviewed]);
    await Future<void>.delayed(Duration.zero);

    expect(
      await cubit.updateReport(
        report: reviewed,
        description: 'Changed',
        pharmacyId: pharmacy.pharmacyId,
      ),
      isFalse,
    );
    expect(await cubit.deleteReport(reviewed), isFalse);
    expect(reports.updatedReportId, isNull);
    expect(reports.deletedReportId, isNull);
  });

  test(
    'deletes a pending report after checking it belongs to the list',
    () async {
      await cubit.start(userId: 'user-1');
      reports.reports.controller.add([pendingReport]);
      await Future<void>.delayed(Duration.zero);

      expect(await cubit.deleteReport(pendingReport), isTrue);
      expect(reports.deletedReportId, pendingReport.reportId);
    },
  );
}
