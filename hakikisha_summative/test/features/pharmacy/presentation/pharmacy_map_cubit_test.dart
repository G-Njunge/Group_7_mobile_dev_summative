import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/entities/pharmacy_coordinates.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/entities/pharmacy_entity.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/repositories/pharmacy_repository.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/services/pharmacy_location_service.dart';
import 'package:hakikisha_summative/features/pharmacy/presentation/bloc/pharmacy_map_cubit.dart';
import 'package:hakikisha_summative/features/pharmacy/presentation/bloc/pharmacy_map_state.dart';

class FakePharmacyRepository implements PharmacyRepository {
  final controller = StreamController<List<PharmacyEntity>>.broadcast();

  @override
  Stream<List<PharmacyEntity>> watchPharmacies() => controller.stream;
}

class FakePharmacyLocationService implements PharmacyLocationService {
  PharmacyCoordinates location = const PharmacyCoordinates(
    latitude: -1.2864,
    longitude: 36.8172,
  );
  PharmacyLocationFailure? failure;

  @override
  Future<PharmacyCoordinates> getCurrentLocation() async {
    final failure = this.failure;
    if (failure != null) throw failure;
    return location;
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
  const pharmacyFar = PharmacyEntity(
    pharmacyId: 'pharmacy-2',
    name: 'Coast Chemist',
    licenseNo: 'PPB-002',
    address: 'Mombasa',
    latitude: -4.0435,
    longitude: 39.6682,
    phone: '+254700000002',
    verified: false,
  );

  late FakePharmacyRepository repository;
  late FakePharmacyLocationService locationService;
  late PharmacyMapCubit cubit;

  setUp(() {
    repository = FakePharmacyRepository();
    locationService = FakePharmacyLocationService();
    cubit = PharmacyMapCubit(repository, locationService);
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

  test('locate me stores the current position', () async {
    await cubit.start();
    repository.controller.add([pharmacyFar, pharmacy]);
    await Future<void>.delayed(Duration.zero);

    final location = await cubit.locateMe();

    expect(location, locationService.location);
    expect(cubit.state.currentLocation, locationService.location);
    expect(cubit.state.isLocating, isFalse);
    expect(cubit.state.visiblePharmacies, [pharmacy, pharmacyFar]);
  });

  test('location failures are exposed in state', () async {
    locationService.failure = const PharmacyLocationFailure(
      'Location permission is needed to find your position.',
    );

    final location = await cubit.locateMe();

    expect(location, isNull);
    expect(cubit.state.currentLocation, isNull);
    expect(cubit.state.isLocating, isFalse);
    expect(cubit.state.locationError, contains('permission'));
  });

  test('a repository stream error is exposed as an error state', () async {
    await cubit.start();
    repository.controller.addError(Exception('offline'));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.status, PharmacyMapStatus.error);
    expect(cubit.state.errorMessage, isNotNull);
  });
}
