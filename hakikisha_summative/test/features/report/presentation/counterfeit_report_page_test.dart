import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hakikisha_summative/core/widgets/app_text_field.dart';
import 'package:hakikisha_summative/features/report/domain/entities/report_entity.dart';
import 'package:hakikisha_summative/features/report/presentation/bloc/report_cubit.dart';
import 'package:hakikisha_summative/features/report/presentation/pages/counterfeit_report_page.dart';
import 'package:hakikisha_summative/features/report/presentation/pages/my_reports_page.dart';
import 'package:material_ui/material_ui.dart';

import '../../../helpers/pump_app.dart';
import 'report_fakes.dart';

void main() {
  late FakePharmacyRepository pharmacies;
  late FakeReportRepository reports;
  final getIt = GetIt.instance;

  setUp(() async {
    await getIt.reset();
    pharmacies = FakePharmacyRepository();
    reports = FakeReportRepository();
    getIt.registerFactory<ReportCubit>(() => ReportCubit(reports, pharmacies));
  });

  tearDown(() async {
    await getIt.reset();
    await pharmacies.controller.close();
    await reports.controller.close();
  });

  /// Pumps the page on a 360x800 phone, the Figma frame size.
  Future<void> pumpReport(
    WidgetTester tester, {
    ReportDraft prefill = const ReportDraft(),
  }) async {
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpPage(
      CounterfeitReportPage(userId: 'user-1', prefill: prefill),
    );
  }

  Finder field(String label) => find.ancestor(
    of: find.text(label.toUpperCase()),
    matching: find.byType(AppTextField),
  );

  Future<void> tapSubmit(WidgetTester tester) async {
    final submit = find.text('Submit report');
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    await tester.tap(submit);
    await tester.pumpAndSettle();
  }

  testWidgets('a medicine can be reported with no pharmacies listed', (
    tester,
  ) async {
    await pumpReport(tester);
    pharmacies.controller.add(const []);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.descendant(
        of: field('Medicine name'),
        matching: find.byType(TextField),
      ),
      'Coartem 80/480',
    );
    await tester.enterText(
      find.descendant(
        of: field('What looked wrong?'),
        matching: find.byType(TextField),
      ),
      'The seal was broken.',
    );
    await tapSubmit(tester);

    expect(find.text('Report sent'), findsOneWidget);
    expect(reports.created!.medicineName, 'Coartem 80/480');
    expect(reports.created!.pharmacyId, isNull);
  });

  testWidgets('shows polite messages for missing fields and sends nothing', (
    tester,
  ) async {
    await pumpReport(tester);
    await tapSubmit(tester);

    expect(find.text('Enter the name of the medicine.'), findsOneWidget);
    expect(find.text('Tell us what looked wrong.'), findsOneWidget);
    expect(reports.created, isNull);
  });

  testWidgets('arriving from a scan prefills the medicine and batch', (
    tester,
  ) async {
    await pumpReport(
      tester,
      prefill: const ReportDraft(
        medicineName: 'Panadol Advance 500mg',
        batchNumber: 'PA23-0871',
      ),
    );

    expect(find.text('Panadol Advance 500mg'), findsOneWidget);
    expect(find.text('PA23-0871'), findsOneWidget);
  });

  testWidgets('a listed pharmacy can be picked', (tester) async {
    await pumpReport(tester);
    pharmacies.controller.add(const [testPharmacy]);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Not listed / not sure'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Kigali Central Pharmacy').last);
    await tester.pumpAndSettle();

    final cubit = BlocProvider.of<ReportCubit>(
      tester.element(find.byType(Form)),
    );
    expect(cubit.state.draft.pharmacyId, testPharmacy.pharmacyId);
  });

  testWidgets('My reports lists a report and withdraws it after confirming', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    // The page spins until the reports stream emits, so don't settle yet.
    await tester.pumpPage(const MyReportsPage(userId: 'user-1'), settle: false);
    reports.controller.add(const [
      ReportEntity(
        reportId: 'r1',
        medicineName: 'Coartem 80/480',
        batchNumber: 'CT24-0412',
        description: 'Seal broken.',
        status: 'pending',
      ),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('Coartem 80/480'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);

    await tester.tap(find.text('Withdraw'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Withdraw'));
    await tester.pumpAndSettle();

    expect(reports.deletedReportId, 'r1');
    expect(find.text('Report withdrawn.'), findsOneWidget);
  });
}
