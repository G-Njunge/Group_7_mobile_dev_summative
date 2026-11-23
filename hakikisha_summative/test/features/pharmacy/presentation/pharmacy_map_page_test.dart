import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/entities/pharmacy_coordinates.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/entities/pharmacy_entity.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/repositories/pharmacy_repository.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/services/pharmacy_location_service.dart';
import 'package:hakikisha_summative/features/pharmacy/presentation/bloc/pharmacy_map_cubit.dart';
import 'package:hakikisha_summative/features/pharmacy/presentation/pages/pharmacy_map_page.dart';

import '../../../helpers/pump_app.dart';

class _FakePharmacyRepository implements PharmacyRepository {
  final controller = StreamController<List<PharmacyEntity>>.broadcast();

  @override
  Stream<List<PharmacyEntity>> watchPharmacies() => controller.stream;
}

class _FakeLocationService implements PharmacyLocationService {
  @override
  Future<PharmacyCoordinates> getCurrentLocation() async =>
      const PharmacyCoordinates(latitude: -1.2864, longitude: 36.8172);
}

void main() {
  const central = PharmacyEntity(
    pharmacyId: 'pharmacy-1',
    name: 'Central Pharmacy',
    licenseNo: 'PPB-001',
    address: 'Westlands, Nairobi',
    latitude: -1.267,
    longitude: 36.81,
    phone: '+254700000001',
    verified: true,
  );
  const coast = PharmacyEntity(
    pharmacyId: 'pharmacy-2',
    name: 'Coast Chemist',
    licenseNo: 'PPB-002',
    address: 'Mombasa',
    latitude: -4.0435,
    longitude: 39.6682,
    phone: '+254700000002',
    verified: false,
  );

  late _FakePharmacyRepository repository;
  late PharmacyMapCubit cubit;

  setUp(() {
    repository = _FakePharmacyRepository();
    cubit = PharmacyMapCubit(repository, _FakeLocationService());
  });

  tearDown(() async {
    await cubit.close();
    await repository.controller.close();
  });

  testWidgets('loads, searches, and opens pharmacy details', (tester) async {
    await tester.pumpPage(PharmacyMapPage(cubit: cubit), settle: false);

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('Loading pharmacies…'), findsOneWidget);

    repository.controller.add([coast, central]);
    await tester.pumpAndSettle();

    expect(find.text('Pharmacy map'), findsOneWidget);
    expect(find.text('Nearby pharmacies'), findsOneWidget);
    expect(find.text('Central Pharmacy'), findsOneWidget);
    expect(find.text('Coast Chemist'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Central');
    await tester.pumpAndSettle();

    expect(find.text('Matching pharmacies'), findsOneWidget);
    expect(find.text('Central Pharmacy'), findsWidgets);
    expect(find.text('Coast Chemist'), findsNothing);

    await tester.tap(find.text('Central Pharmacy').last);
    await tester.pumpAndSettle();

    expect(find.text('Westlands, Nairobi'), findsWidgets);
    expect(find.text('License: PPB-001'), findsOneWidget);
    expect(find.text('Verified pharmacy'), findsOneWidget);
  });

  testWidgets('locate me adds the current location', (tester) async {
    await tester.pumpPage(PharmacyMapPage(cubit: cubit), settle: false);

    repository.controller.add([central]);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Locate me'));
    await tester.pumpAndSettle();

    expect(cubit.state.currentLocation, isNotNull);
    expect(find.textContaining('km away'), findsWidgets);
  });
}
