import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/scan/domain/entities/batch_entity.dart';
import 'package:hakikisha_summative/features/scan/domain/entities/medicine_entity.dart';
import 'package:hakikisha_summative/features/scan/domain/entities/verification_outcome.dart';
import 'package:hakikisha_summative/features/scan/presentation/pages/scan_result_page.dart';

void main() {
  const sampleMed = MedicineEntity(
    medicineId: 'med_1',
    name: 'Panadol Advance',
    manufacturer: 'GSK',
    rfdaRegNo: 'RWANDA-FDA24/HM/1029',
    dosageForm: 'Tablet',
    strength: '500mg',
  );

  testWidgets('renders VERIFIED GENUINE banner and details for valid batch', (
    tester,
  ) async {
    final genuineResult = VerificationResult(
      status: VerificationStatus.genuine,
      queriedCode: 'RW24-0871',
      medicine: sampleMed,
      batch: BatchEntity(
        batchId: 'b_1',
        medicineId: 'med_1',
        batchNumber: 'RW24-0871',
        gtin: '6161100001234',
        expiryDate: DateTime(2027, 8, 1),
        status: 'valid',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ScanResultPage(
          result: genuineResult,
          onOpenReport: () {},
          onOpenPharmacyMap: () {},
        ),
      ),
    );

    expect(find.text('VERIFIED GENUINE'), findsOneWidget);
    expect(find.text('Registered & genuine'), findsOneWidget);
    expect(find.text('RWANDA-FDA24/HM/1029'), findsOneWidget);
    expect(find.text('CHECK IT YOURSELF'), findsOneWidget);
  });

  testWidgets('renders DO NOT USE banner and Report CTA for recalled batch', (
    tester,
  ) async {
    var reportTapped = false;
    final flaggedResult = VerificationResult(
      status: VerificationStatus.flagged,
      flagReason: FlagReason.recalled,
      queriedCode: 'RW24-0999',
      medicine: sampleMed,
      batch: BatchEntity(
        batchId: 'b_2',
        medicineId: 'med_1',
        batchNumber: 'RW24-0999',
        gtin: '6161100009999',
        expiryDate: DateTime(2027, 8, 1),
        status: 'recalled',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ScanResultPage(
          result: flaggedResult,
          onOpenReport: () => reportTapped = true,
          onOpenPharmacyMap: () {},
        ),
      ),
    );

    expect(find.text('DO NOT USE — FLAGGED'), findsOneWidget);
    expect(find.text('This batch was recalled'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Report to Rwanda FDA'), 100);
    await tester.tap(find.text('Report to Rwanda FDA'));
    expect(reportTapped, isTrue);
  });
}
