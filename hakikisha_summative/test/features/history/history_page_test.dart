import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hakikisha_summative/core/l10n/generated/app_localizations.dart';
import 'package:hakikisha_summative/features/history/domain/entities/scan_entity.dart';
import 'package:hakikisha_summative/features/history/domain/entities/scan_summary.dart';
import 'package:hakikisha_summative/features/history/domain/repositories/history_repository.dart';
import 'package:hakikisha_summative/features/history/presentation/bloc/history_cubit.dart';
import 'package:hakikisha_summative/features/history/presentation/pages/history_page.dart';

import '../../helpers/pump_app.dart';

/// A stand-in repository: the test decides when and what it "sends".
class _FakeRepo implements HistoryRepository {
  final controller = StreamController<List<ScanSummary>>();

  @override
  Stream<List<ScanSummary>> watchScans(String userId) => controller.stream;

  @override
  Future<void> deleteScan(String scanId) async {}
}

ScanSummary _scan(String id, String name, String result) => ScanSummary(
  medicineName: name,
  scan: ScanEntity(
    scanId: id,
    userId: 'u1',
    batchId: 'b$id',
    result: result,
    method: 'camera',
    scannedAt: DateTime(2026, 11, 17, 9, 41),
  ),
);

Future<_FakeRepo> _pumpPage(WidgetTester tester) async {
  final repo = _FakeRepo();
  addTearDown(repo.controller.close);

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => BlocProvider(
          create: (_) => HistoryCubit(repo)..start('u1'),
          child: const HistoryPage(),
        ),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
  return repo;
}

/// Lets the stream event reach the cubit, then rebuilds the page.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

void main() {
  testWidgets('shows a spinner while scans are loading', (tester) async {
    await _pumpPage(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the empty message when there are no scans', (
    tester,
  ) async {
    final repo = await _pumpPage(tester);

    repo.controller.add([]);
    await _settle(tester);

    expect(find.text('No scans to show yet.'), findsOneWidget);
  });

  testWidgets('shows each medicine name and the total count', (tester) async {
    final repo = await _pumpPage(tester);

    repo.controller.add([
      _scan('1', 'Panadol Advance 500mg', 'genuine'),
      _scan('2', 'Coartem 80/480', 'flagged'),
    ]);
    await _settle(tester);

    expect(find.text('Panadol Advance 500mg'), findsOneWidget);
    expect(find.text('Coartem 80/480'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('tapping the Flagged card hides genuine scans', (tester) async {
    final repo = await _pumpPage(tester);

    repo.controller.add([
      _scan('1', 'Panadol Advance 500mg', 'genuine'),
      _scan('2', 'Coartem 80/480', 'flagged'),
    ]);
    await _settle(tester);

    await tester.tap(find.text('Flagged'));
    await tester.pump();

    expect(find.text('Panadol Advance 500mg'), findsNothing);
    expect(find.text('Coartem 80/480'), findsOneWidget);
  });
}
