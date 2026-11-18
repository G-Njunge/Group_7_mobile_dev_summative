import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/entities/pharmacy_coordinates.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/entities/pharmacy_entity.dart';
import 'package:hakikisha_summative/features/pharmacy/domain/utils/pharmacy_search.dart';

void main() {
  const pharmacyNear = PharmacyEntity(
    pharmacyId: 'near',
    name: 'Central Pharmacy',
    licenseNo: 'PPB-001',
    address: 'Westlands, Nairobi',
    latitude: -1.267,
    longitude: 36.81,
    phone: '+254700000001',
    verified: true,
  );
  const pharmacyFar = PharmacyEntity(
    pharmacyId: 'far',
    name: 'Coast Chemist',
    licenseNo: 'PPB-002',
    address: 'Mombasa',
    latitude: -4.0435,
    longitude: 39.6682,
    phone: '+254700000002',
    verified: false,
  );

  test(
    'search matches names, addresses, license numbers, and phone numbers',
    () {
      final pharmacies = [pharmacyNear, pharmacyFar];

      expect(
        PharmacySearch.filter(pharmacies, '  CENTRAL ').single,
        pharmacyNear,
      );
      expect(PharmacySearch.filter(pharmacies, 'mombasa').single, pharmacyFar);
      expect(PharmacySearch.filter(pharmacies, 'ppb-002').single, pharmacyFar);
      expect(
        PharmacySearch.filter(pharmacies, '+254700000002').single,
        pharmacyFar,
      );
    },
  );

  test('search sorts matches nearest-first when a location is available', () {
    final results = PharmacySearch.filter(
      [pharmacyFar, pharmacyNear],
      '',
      from: const PharmacyCoordinates(latitude: -1.2864, longitude: 36.8172),
    );

    expect(results, [pharmacyNear, pharmacyFar]);
  });

  test('distance is zero for matching coordinates', () {
    const position = PharmacyCoordinates(latitude: -1.2864, longitude: 36.8172);

    expect(PharmacySearch.distanceKm(position, position), 0);
  });

  test('distance uses the geographic distance between two positions', () {
    const userPosition = PharmacyCoordinates(
      latitude: -1.2864,
      longitude: 36.8172,
    );

    expect(
      PharmacySearch.distanceKm(userPosition, pharmacyNear.coordinates),
      closeTo(2.3, 0.2),
    );
  });
}
