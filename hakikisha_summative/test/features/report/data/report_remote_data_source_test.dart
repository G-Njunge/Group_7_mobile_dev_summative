import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/report/data/datasources/report_remote_data_source.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late ReportRemoteDataSource dataSource;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = ReportRemoteDataSource(firestore);
  });

  test('creates a pending report with the selected pharmacy and reporter', () async {
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
  });
}
