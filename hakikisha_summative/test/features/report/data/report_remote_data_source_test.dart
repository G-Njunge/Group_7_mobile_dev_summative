import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/report/data/datasources/report_remote_data_source.dart';
import 'package:hakikisha_summative/features/report/data/repositories/report_repository_impl.dart';
import 'package:hakikisha_summative/features/report/domain/entities/report_entity.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ReportRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = ReportRepositoryImpl(ReportRemoteDataSource(firestore));
  });

  test(
    'creates a pending report with the medicine details and no photos',
    () async {
      await repository.createReport(
        userId: 'user-1',
        draft: const ReportDraft(
          medicineName: '  Coartem 80/480 ',
          batchNumber: 'ct24-0412',
          purchaseLocation: '   ',
          description: ' Seal was broken. ',
        ),
      );

      final docs = (await firestore.collection('reports').get()).docs;
      expect(docs, hasLength(1));
      final data = docs.single.data();
      expect(data['userId'], 'user-1');
      expect(data['medicineName'], 'Coartem 80/480');
      expect(data['batchNumber'], 'CT24-0412', reason: 'batch is uppercased');
      expect(data['purchaseLocation'], isNull, reason: 'blank becomes null');
      expect(data['pharmacyId'], isNull);
      expect(data['description'], 'Seal was broken.');
      expect(data['photoUrls'], isEmpty);
      expect(data['status'], 'pending');
    },
  );

  test('watches only the signed-in user reports, newest first', () async {
    final reports = firestore.collection('reports');
    await reports.doc('old').set({
      'userId': 'user-1',
      'description': 'Older',
      'status': 'pending',
      'createdAt': Timestamp.fromDate(DateTime(2026, 11, 1)),
    });
    await reports.doc('new').set({
      'userId': 'user-1',
      'medicineName': 'Amoxil 250mg',
      'description': 'Newer',
      'status': 'reviewed',
      'createdAt': Timestamp.fromDate(DateTime(2026, 11, 20)),
    });
    await reports.doc('other').set({
      'userId': 'user-2',
      'description': 'Not mine',
      'status': 'pending',
      'createdAt': Timestamp.fromDate(DateTime(2026, 11, 21)),
    });

    final mine = await repository.watchMyReports('user-1').first;

    expect(mine.map((r) => r.reportId), ['new', 'old']);
    expect(mine.first.medicineName, 'Amoxil 250mg');
    expect(mine.first.isPending, isFalse);
    // A report filed before medicineName existed still loads.
    expect(mine.last.medicineName, isEmpty);
    expect(mine.last.pharmacyId, isNull);
  });

  test('updates every form field and then withdraws the report', () async {
    final doc = firestore.collection('reports').doc('r1');
    await doc.set({
      'userId': 'user-1',
      'medicineName': 'Old name',
      'batchNumber': 'OLD-1',
      'description': 'Old',
      'status': 'pending',
    });

    await repository.updatePendingReport(
      reportId: 'r1',
      draft: const ReportDraft(
        medicineName: 'Panadol Advance 500mg',
        pharmacyId: 'ph_kigali_central',
        description: 'Tablets crumble.',
      ),
    );
    final updated = (await doc.get()).data()!;
    expect(updated['medicineName'], 'Panadol Advance 500mg');
    expect(updated['batchNumber'], isNull, reason: 'cleared by the edit');
    expect(updated['pharmacyId'], 'ph_kigali_central');
    expect(updated['description'], 'Tablets crumble.');

    await repository.deletePendingReport('r1');
    expect((await doc.get()).exists, isFalse);
  });
}
