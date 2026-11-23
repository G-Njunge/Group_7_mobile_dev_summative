import 'package:flutter_test/flutter_test.dart';
import 'package:hakikisha_summative/features/pharmacy/data/models/pharmacy_model.dart';

void main() {
  test('maps the pharmacy Firestore contract fields', () {
    final pharmacy = PharmacyModel.fromJson({
      'pharmacyId': 'pharmacy-1',
      'name': 'Central Pharmacy',
      'licenseNo': 'PPB-001',
      'address': 'Nyarugenge, Kigali',
      'lat': -1.267,
      'lng': 36.81,
      'phone': '+250788000001',
      'verified': true,
    }, documentId: 'document-1');

    expect(pharmacy.pharmacyId, 'pharmacy-1');
    expect(pharmacy.name, 'Central Pharmacy');
    expect(pharmacy.licenseNo, 'PPB-001');
    expect(pharmacy.address, 'Nyarugenge, Kigali');
    expect(pharmacy.latitude, -1.267);
    expect(pharmacy.longitude, 36.81);
    expect(pharmacy.phone, '+250788000001');
    expect(pharmacy.verified, isTrue);
  });

  test('uses the Firestore document ID when pharmacyId is absent', () {
    final pharmacy = PharmacyModel.fromJson({
      'name': 'Central Pharmacy',
      'licenseNo': 'PPB-001',
      'address': 'Nyarugenge, Kigali',
      'lat': -1.267,
      'lng': 36.81,
      'phone': '+250788000001',
      'verified': true,
    }, documentId: 'pharmacy-document');

    expect(pharmacy.pharmacyId, 'pharmacy-document');
  });

  test('rejects documents that do not match the Firestore contract', () {
    expect(
      () => PharmacyModel.fromJson({
        'name': 'Incomplete pharmacy',
      }, documentId: 'pharmacy-document'),
      throwsFormatException,
    );
  });

  test('rejects coordinates outside valid latitude and longitude ranges', () {
    expect(
      () => PharmacyModel.fromJson({
        'name': 'Central Pharmacy',
        'licenseNo': 'PPB-001',
        'address': 'Nyarugenge, Kigali',
        'lat': 91,
        'lng': 36.81,
        'phone': '+250788000001',
        'verified': true,
      }, documentId: 'pharmacy-document'),
      throwsFormatException,
    );
  });
}
