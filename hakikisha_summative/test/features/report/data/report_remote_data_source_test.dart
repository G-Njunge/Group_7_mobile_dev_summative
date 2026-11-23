import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/report/data/datasources/report_remote_data_source.dart';
import 'package:hakikisha_summative/features/report/domain/entities/report_entity.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ReportRemoteDataSource dataSource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = ReportRemoteDataSource(firestore);
  });

  test(
    'creates a pending report with the selected pharmacy and reporter',
    () async {
      await dataSource.createCounterfeitReport(
        userId: 'user-1',
        pharmacyId: 'pharmacy-1',
        description: 'The packaging appears tampered with.',
      );

      final reports = await firestore.collection('reports').get();
      expect(reports.docs, hasLength(1));
      final report = reports.docs.single.data();
      expect(report, containsPair('userId', 'user-1'));
      expect(report, containsPair('scanId', null));
      expect(report, containsPair('pharmacyId', 'pharmacy-1'));
      expect(
        report,
        containsPair('description', 'The packaging appears tampered with.'),
      );
      expect(report, containsPair('photoUrls', <String>[]));
      expect(report, containsPair('status', 'pending'));
      expect(report['createdAt'], isA<Timestamp>());
      expect(report['updatedAt'], isA<Timestamp>());
    },
  );

  test('watches only the signed-in user reports', () async {
    final createdAt = Timestamp.fromDate(DateTime(2026, 11, 20));
    await firestore.collection('reports').doc('mine').set({
      'userId': 'user-1',
      'pharmacyId': 'pharmacy-1',
      'description': 'My report',
      'status': 'pending',
      'createdAt': createdAt,
    });
    await firestore.collection('reports').doc('other').set({
      'userId': 'user-2',
      'pharmacyId': 'pharmacy-2',
      'description': 'Someone else report',
      'status': 'pending',
      'createdAt': createdAt,
    });

    final reports = await dataSource.watchMyReports('user-1').first;

    expect(reports, [
      ReportEntity(
        reportId: 'mine',
        pharmacyId: 'pharmacy-1',
        description: 'My report',
        status: 'pending',
        createdAt: createdAt.toDate(),
      ),
    ]);
  });

  test('updates and deletes a report document by id', () async {
    final document = firestore.collection('reports').doc('report-1');
    await document.set({'description': 'Old', 'pharmacyId': 'old-pharmacy'});

    await dataSource.updatePendingReport(
      reportId: document.id,
      pharmacyId: 'new-pharmacy',
      description: 'Updated',
    );
    var report = (await document.get()).data()!;
    expect(report['description'], 'Updated');
    expect(report['pharmacyId'], 'new-pharmacy');
    expect(report['updatedAt'], isA<Timestamp>());

    await dataSource.deletePendingReport(document.id);
    expect((await document.get()).exists, isFalse);
  });
}
