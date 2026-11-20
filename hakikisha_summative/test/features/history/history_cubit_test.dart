import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/history/domain/entities/scan_entity.dart';
import 'package:hakikisha_summative/features/history/domain/entities/scan_summary.dart';
import 'package:hakikisha_summative/features/history/domain/repositories/history_repository.dart';
import 'package:hakikisha_summative/features/history/presentation/bloc/history_cubit.dart';
import 'package:hakikisha_summative/features/history/presentation/bloc/history_state.dart';

/// A stand-in repository. The test decides what it "sends", so no
/// Firebase is needed.
class FakeHistoryRepository implements HistoryRepository {
  final controller = StreamController<List<ScanSummary>>();

  @override
  Stream<List<ScanSummary>> watchScans(String userId) => controller.stream;

  @override
  Future<void> deleteScan(String scanId) async {}
}

void main() {
  final genuineScan = ScanSummary(
    medicineName: 'Panadol Advance 500mg',
    scan: ScanEntity(
      scanId: '1',
      userId: 'u1',
      batchId: 'b1',
      result: 'genuine',
      method: 'camera',
      scannedAt: DateTime(2026, 11, 17),
    ),
  );

  final flaggedScan = ScanSummary(
    medicineName: 'Coartem 80/480',
    scan: ScanEntity(
      scanId: '2',
      userId: 'u1',
      batchId: 'b2',
      result: 'flagged',
      method: 'manual',
      scannedAt: DateTime(2026, 11, 16),
    ),
  );

  late FakeHistoryRepository repo;
  late HistoryCubit cubit;

  setUp(() {
    repo = FakeHistoryRepository();
    cubit = HistoryCubit(repo)..start('u1');
  });

  tearDown(() async {
    await cubit.close();
    await repo.controller.close();
  });

  test('loads scans from the repository', () async {
    repo.controller.add([genuineScan, flaggedScan]);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.status, HistoryStatus.loaded);
    expect(cubit.state.visibleScans.length, 2);
  });

  test('genuine filter shows only genuine scans', () async {
    repo.controller.add([genuineScan, flaggedScan]);
    await Future<void>.delayed(Duration.zero);

    cubit.setFilter(HistoryFilter.genuine);

    expect(cubit.state.visibleScans, [genuineScan]);
  });

  test('flagged filter shows only flagged scans', () async {
    repo.controller.add([genuineScan, flaggedScan]);
    await Future<void>.delayed(Duration.zero);

    cubit.setFilter(HistoryFilter.flagged);

    expect(cubit.state.visibleScans, [flaggedScan]);
  });

  test('a stream error puts the cubit in the error state', () async {
    repo.controller.addError(Exception('boom'));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.status, HistoryStatus.error);
    expect(cubit.state.errorMessage, isNotNull);
  });
}
