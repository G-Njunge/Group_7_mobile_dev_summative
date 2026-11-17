import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/entities/pharmacy_entity.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/repositories/pharmacy_repository.dart';
import 'package:hakikisha_summative/features/pharmacy/presentation/bloc/pharmacy_map_cubit.dart';
import 'package:hakikisha_summative/features/pharmacy/presentation/bloc/pharmacy_map_state.dart';

class FakePharmacyRepository implements PharmacyRepository {
  final controller = StreamController<List<PharmacyEntity>>();

  @override
  Stream<List<PharmacyEntity>> watchPharmacies() => controller.stream;
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

  late FakePharmacyRepository repository;
  late PharmacyMapCubit cubit;

  setUp(() {
    repository = FakePharmacyRepository();
    cubit = PharmacyMapCubit(repository);
  });

  tearDown(() async {
    await cubit.close();
    await repository.controller.close();
  });

  test('loads pharmacies from the repository stream', () async {
    await cubit.start();
    repository.controller.add([pharmacy]);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.status, PharmacyMapStatus.loaded);
    expect(cubit.state.pharmacies, [pharmacy]);
  });

  test('search query filters the visible pharmacies', () async {
    await cubit.start();
    repository.controller.add([pharmacy]);
    await Future<void>.delayed(Duration.zero);

    cubit.setSearchQuery('pharmacy that is not here');

    expect(cubit.state.visiblePharmacies, isEmpty);
  });

  test('a repository stream error is exposed as an error state', () async {
    await cubit.start();
    repository.controller.addError(Exception('offline'));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.status, PharmacyMapStatus.error);
    expect(cubit.state.errorMessage, isNotNull);
  });
}
