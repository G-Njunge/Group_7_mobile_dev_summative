import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/entities/pharmacy_entity.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/repositories/pharmacy_repository.dart';
import 'package:hakikisha_summative/features/report/domain/repositories/report_repository.dart';
import 'package:hakikisha_summative/features/report/presentation/bloc/report_cubit.dart';

class FakePharmacyRepository implements PharmacyRepository {
  final controller = StreamController<List<PharmacyEntity>>.broadcast();

  @override
  Stream<List<PharmacyEntity>> watchPharmacies() => controller.stream;
}

class FakeReportRepository implements ReportRepository {
  String? userId;
  String? pharmacyId;
  String? description;
  Object? failure;

  @override
  Future<void> createCounterfeitReport({
    required String userId,
    required String pharmacyId,
    required String description,
  }) async {
    if (failure != null) throw failure!;
    this.userId = userId;
    this.pharmacyId = pharmacyId;
    this.description = description;
  }
}

void main() {
  const pharmacy = PharmacyEntity(
    pharmacyId: 'pharmacy-1',
    name: 'Central Pharmacy',
    licenseNo: 'PPB-001',
    address: 'Westlands, Nairobi',
    latitude: -1.267,
    longitude: 36.81,
    phone: '+254700000001',
    verified: true,
  );

  late FakePharmacyRepository pharmacies;
  late FakeReportRepository reports;
  late ReportCubit cubit;

  setUp(() {
    pharmacies = FakePharmacyRepository();
    reports = FakeReportRepository();
    cubit = ReportCubit(reports, pharmacies);
  });

  tearDown(() async {
    await cubit.close();
    await pharmacies.controller.close();
  });

  test(
    'creates a report for the selected pharmacy and signed-in user',
    () async {
      await cubit.start();
      pharmacies.controller.add([pharmacy]);
      await Future<void>.delayed(Duration.zero);
      cubit
        ..setDescription('  Tampered medicine packaging  ')
        ..selectPharmacy(pharmacy.pharmacyId);

      await cubit.submit(userId: 'user-1');

      expect(reports.userId, 'user-1');
      expect(reports.pharmacyId, pharmacy.pharmacyId);
      expect(reports.description, 'Tampered medicine packaging');
      expect(cubit.state.isSubmitted, isTrue);
    },
  );

  test('does not create a report without a description or pharmacy', () async {
    await cubit.submit(userId: 'user-1');

    expect(reports.description, isNull);
    expect(cubit.state.errorMessage, contains('description'));

    cubit.setDescription('Suspicious medicine.');
    await cubit.submit(userId: 'user-1');

    expect(reports.description, isNull);
    expect(cubit.state.errorMessage, 'Select a pharmacy.');
  });

  test('exposes report submission failures', () async {
    await cubit.start();
    pharmacies.controller.add([pharmacy]);
    await Future<void>.delayed(Duration.zero);
    cubit
      ..setDescription('Suspicious medicine.')
      ..selectPharmacy(pharmacy.pharmacyId);
    reports.failure = StateError('offline');

    await cubit.submit(userId: 'user-1');

    expect(cubit.state.isSubmitting, isFalse);
    expect(cubit.state.isSubmitted, isFalse);
    expect(cubit.state.errorMessage, contains('Could not submit'));
  });
}
