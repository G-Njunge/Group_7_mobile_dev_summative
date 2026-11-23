import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/scan/data/datasources/scan_remote_datasource.dart';
import 'package:hakikisha_summative/features/scan/data/models/scan_record_model.dart';
import 'package:hakikisha_summative/features/scan/domain/entities/scan_record_entity.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late ScanRemoteDataSource dataSource;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    dataSource = ScanRemoteDataSource(firestore: fakeFirestore);

    await fakeFirestore.collection('medicines').doc('med_1').set({
      'medicineId': 'med_1',
      'name': 'Coartem 80/480',
      'manufacturer': 'Novartis',
      'ppbRegNo': 'RWANDA-FDA24/HM/0042',
      'dosageForm': 'Tablet',
      'strength': '80/480mg',
    });

    await fakeFirestore.collection('batches').doc('batch_1').set({
      'batchId': 'batch_1',
      'medicineId': 'med_1',
      'batchNumber': 'RW24-0871',
      'gtin': '6161100001234',
      'expiryDate': Timestamp.fromDate(DateTime(2027, 8, 1)),
      'status': 'valid',
    });
  });

  test('finds batch by batchNumber or GTIN and hydrates medicine', () async {
    final byBatch = await dataSource.findBatchByCode('rw24-0871');
    expect(byBatch, isNotNull);
    expect(byBatch!.batchId, 'batch_1');

    final byGtin = await dataSource.findBatchByCode('6161100001234');
    expect(byGtin, isNotNull);

    final med = await dataSource.getMedicineById(byBatch.medicineId);
    expect(med?.rfdaRegNo, 'RWANDA-FDA24/HM/0042');
  });

  test('saves scan record and streams latest scan update', () async {
    final record = ScanRecordModel(
      scanId: '',
      userId: 'user_eric',
      batchId: 'batch_1',
      result: 'genuine',
      method: ScanMethod.manual,
      scannedAt: DateTime(2026, 11, 23, 12, 0),
    );

    await dataSource.saveScanRecord(record);

    final latest = await dataSource.watchLatestScan('user_eric').first;
    expect(latest, isNotNull);
    expect(latest!.medicineName, 'Coartem 80/480');
    expect(latest.batchNumber, 'RW24-0871');
  });
}
