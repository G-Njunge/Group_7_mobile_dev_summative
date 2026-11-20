import 'dart:async';

// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/entities/pharmacy_entity.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/repositories/pharmacy_repository.dart';
import 'package:hakikisha_summative/features/report/domain/entities/report_entity.dart';
import 'package:hakikisha_summative/features/report/domain/repositories/report_repository.dart';
import 'package:hakikisha_summative/features/report/presentation/bloc/report_cubit.dart';
import 'package:hakikisha_summative/features/report/presentation/pages/counterfeit_report_page.dart';

class _FakePharmacyRepository implements PharmacyRepository {
  final controller = StreamController<List<PharmacyEntity>>.broadcast();

  @override
  Stream<List<PharmacyEntity>> watchPharmacies() => controller.stream;
}

class _FakeReportRepository implements ReportRepository {
  final controller = StreamController<List<ReportEntity>>.broadcast();
  int creates = 0;

  @override
  Stream<List<ReportEntity>> watchMyReports(String userId) => controller.stream;

  @override
  Future<void> createCounterfeitReport({
    required String userId,
    required String pharmacyId,
    required String description,
  }) async {
    creates++;
  }

  @override
  Future<void> updatePendingReport({
    required String reportId,
    required String pharmacyId,
    required String description,
  }) async {}

  @override
  Future<void> deletePendingReport(String reportId) async {}
}

void main() {
  const pharmacy = PharmacyEntity(
    pharmacyId: 'pharmacy-1',
    name: 'Central Pharmacy',
    licenseNo: 'PPB-001',
    address: 'Westlands, Nairobi',
    latitude: -1.267,
    longitude: 36.81,
    phone: '+254700000001',
    verified: true,
  );

  late _FakePharmacyRepository pharmacies;
  late _FakeReportRepository reports;
  final getIt = GetIt.instance;

  setUp(() async {
    await getIt.reset();
    pharmacies = _FakePharmacyRepository();
    reports = _FakeReportRepository();
    getIt.registerFactory<ReportCubit>(() => ReportCubit(reports, pharmacies));
  });

  tearDown(() async {
    await getIt.reset();
    await pharmacies.controller.close();
    await reports.controller.close();
  });

  testWidgets('shows Report sent after a valid report is submitted', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CounterfeitReportPage(userId: 'user-1')),
    );
    pharmacies.controller.add([pharmacy]);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField),
      'The packaging appears tampered with.',
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Central Pharmacy').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit report'));
    await tester.pumpAndSettle();

    expect(find.text('Report sent'), findsOneWidget);
  });

  testWidgets('requires a description and pharmacy before submission', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: CounterfeitReportPage(userId: 'user-1')),
    );
    pharmacies.controller.add([pharmacy]);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit report'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a description.'), findsOneWidget);
    expect(find.text('Select a pharmacy.'), findsOneWidget);
    expect(reports.creates, 0);
  });
}
