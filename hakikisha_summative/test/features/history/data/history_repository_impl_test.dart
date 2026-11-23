import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/history/data/datasources/history_remote_data_source.dart';
import 'package:hakikisha_summative/features/history/data/repositories/history_repository_impl.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late HistoryRepositoryImpl repository;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repository = HistoryRepositoryImpl(HistoryRemoteDataSource(firestore));

    await firestore.collection('medicines').doc('med1').set({
      'medicineId': 'med1',
      'name': 'Panadol Advance 500mg',
    });
    await firestore.collection('batches').doc('bat1').set({
      'batchId': 'bat1',
      'medicineId': 'med1',
      'batchNumber': 'PA24-1150',
    });

    await firestore.collection('scans').doc('s1').set({
      'userId': 'u1',
      'batchId': 'bat1',
      'result': 'genuine',
      'method': 'camera',
      'scannedAt': Timestamp.fromDate(DateTime(2026, 11, 17, 9, 41)),
    });
    await firestore.collection('scans').doc('s2').set({
      'userId': 'u1',
      'result': 'notFound',
      'method': 'manual',
      'scannedAt': Timestamp.fromDate(DateTime(2026, 11, 10, 8, 0)),
    });
    await firestore.collection('scans').doc('s3').set({
      'userId': 'u2',
      'batchId': 'bat1',
      'result': 'genuine',
      'method': 'camera',
      'scannedAt': Timestamp.fromDate(DateTime(2026, 11, 12, 8, 0)),
    });
  });

  test('returns only this user\'s scans, newest first', () async {
    final scans = await repository.watchScans('u1').first;

    expect(scans.map((s) => s.scan.scanId), ['s1', 's2']);
  });

  test('adds the medicine name from the batch and the medicine', () async {
    final scans = await repository.watchScans('u1').first;

    expect(scans.first.medicineName, 'Panadol Advance 500mg');
  });

  test('a scan with no batch gets an empty medicine name', () async {
    final scans = await repository.watchScans('u1').first;

    expect(scans.last.scan.batchId, isNull);
    expect(scans.last.medicineName, isEmpty);
  });

  test('a batch that does not exist does not break the list', () async {
    await firestore.collection('scans').doc('s4').set({
      'userId': 'u1',
      'batchId': 'missing',
      'result': 'flagged',
      'method': 'upload',
      'scannedAt': Timestamp.fromDate(DateTime(2026, 11, 18)),
    });

    final scans = await repository.watchScans('u1').first;

    expect(scans.length, 3);
    expect(scans.first.scan.scanId, 's4');
    expect(scans.first.medicineName, isEmpty);
  });

  test('deleteScan removes the document', () async {
    await repository.deleteScan('s1');

    final deleted = await firestore.collection('scans').doc('s1').get();
    expect(deleted.exists, isFalse);
  });
}
