import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/report/domain/entities/report_entity.dart';
import 'package:hakikisha_summative/features/report/presentation/bloc/report_cubit.dart';
import 'package:hakikisha_summative/features/report/presentation/bloc/report_state.dart';

import 'report_fakes.dart';

void main() {
  late FakePharmacyRepository pharmacies;
  late FakeReportRepository reports;
  late ReportCubit cubit;

  const pending = ReportEntity(
    reportId: 'r1',
    medicineName: 'Coartem 80/480',
    description: 'Seal broken.',
    status: 'pending',
  );
  const reviewed = ReportEntity(
    reportId: 'r2',
    medicineName: 'Amoxil 250mg',
    description: 'Wrong colour.',
    status: 'reviewed',
  );

  setUp(() async {
    pharmacies = FakePharmacyRepository();
    reports = FakeReportRepository();
    cubit = ReportCubit(reports, pharmacies);
    await cubit.start(userId: 'user-1');
  });

  tearDown(() => cubit.close());

  test('prefill from a scan is applied straight away', () async {
    final fresh = ReportCubit(reports, pharmacies);
    // Not awaited: the prefill must already be there synchronously.
    fresh.start(
      userId: 'user-1',
      prefill: const ReportDraft(
        medicineName: 'Panadol',
        batchNumber: 'PA23-0871',
      ),
    );
    expect(fresh.state.draft.medicineName, 'Panadol');
    expect(fresh.state.draft.batchNumber, 'PA23-0871');
    await fresh.close();
  });

  test('submits a valid report without needing a pharmacy', () async {
    cubit.updateDraft(validDraft);
    await cubit.submit(userId: 'user-1');

    expect(cubit.state.isSubmitted, isTrue);
    expect(reports.created, validDraft);
  });

  test('an empty pharmacy list never blocks a report', () async {
    pharmacies.controller.add(const []);
    await pumpEventQueue();
    cubit.updateDraft(validDraft);
    await cubit.submit(userId: 'user-1');

    expect(cubit.state.isSubmitted, isTrue);
  });

  test('refuses a report without a medicine name or description', () async {
    cubit.updateDraft(const ReportDraft(description: 'Looks fake.'));
    await cubit.submit(userId: 'user-1');
    expect(cubit.state.errorMessage, 'Enter the name of the medicine.');

    cubit.updateDraft(const ReportDraft(medicineName: 'Coartem'));
    await cubit.submit(userId: 'user-1');
    expect(cubit.state.errorMessage, 'Tell us what looked wrong.');

    expect(reports.created, isNull);
  });

  test('shows a polite error when sending fails, and allows a retry', () async {
    reports.failure = Exception('offline');
    cubit.updateDraft(validDraft);
    await cubit.submit(userId: 'user-1');

    expect(cubit.state.isSubmitted, isFalse);
    expect(cubit.state.isSubmitting, isFalse);
    expect(cubit.state.errorMessage, contains("couldn't send your report"));

    reports.failure = null;
    await cubit.submit(userId: 'user-1');
    expect(cubit.state.isSubmitted, isTrue);
  });

  test('drops a selected pharmacy that disappears from the list', () async {
    pharmacies.controller.add(const [testPharmacy]);
    await pumpEventQueue();
    cubit.updateDraft(validDraft.copyWith(pharmacyId: testPharmacy.pharmacyId));
    expect(
      cubit.state.pharmacyName(cubit.state.draft.pharmacyId),
      testPharmacy.name,
    );

    pharmacies.controller.add(const []);
    await pumpEventQueue();
    expect(cubit.state.draft.pharmacyId, isNull);
  });

  group('My reports', () {
    setUp(() async {
      reports.controller.add(const [pending, reviewed]);
      await pumpEventQueue();
    });

    test('lists the user reports', () {
      expect(cubit.state.reportsStatus, MyReportsStatus.loaded);
      expect(cubit.state.reports, [pending, reviewed]);
    });

    test('edits a pending report', () async {
      final ok = await cubit.updateReport(
        report: pending,
        draft: pending.draft.copyWith(
          description: 'Seal broken and tablets crumble.',
        ),
      );
      expect(ok, isTrue);
      expect(reports.updatedReportId, 'r1');
      expect(reports.updated!.description, 'Seal broken and tablets crumble.');
    });

    test('rejects an edit that empties the medicine name', () async {
      final ok = await cubit.updateReport(
        report: pending,
        draft: pending.draft.copyWith(medicineName: ' '),
      );
      expect(ok, isFalse);
      expect(cubit.state.actionErrorMessage, 'Enter the name of the medicine.');
      expect(reports.updated, isNull);
    });

    test('withdraws a pending report but never a reviewed one', () async {
      expect(await cubit.deleteReport(reviewed), isFalse);
      expect(reports.deletedReportId, isNull);

      expect(await cubit.deleteReport(pending), isTrue);
      expect(reports.deletedReportId, 'r1');
    });

    test('reports a failed withdraw', () async {
      reports.failure = Exception('offline');
      expect(await cubit.deleteReport(pending), isFalse);
      expect(cubit.state.actionErrorMessage, contains("couldn't withdraw"));
      expect(cubit.state.actionReportId, isNull);
    });
  });

  test('ReportDraft.normalized trims and clears blank optional fields', () {
    const draft = ReportDraft(
      medicineName: ' Coartem ',
      batchNumber: ' ct24-0412 ',
      purchaseLocation: '  ',
      pharmacyId: '',
      description: ' Broken seal ',
    );
    expect(
      draft.normalized,
      const ReportDraft(
        medicineName: 'Coartem',
        batchNumber: 'CT24-0412',
        description: 'Broken seal',
      ),
    );
  });
}
