import '../../domain/entities/pharmacy_entity.dart';

class PharmacyModel extends PharmacyEntity {
  const PharmacyModel({
    required super.pharmacyId,
    required super.name,
    required super.licenseNo,
    required super.address,
    required super.latitude,
    required super.longitude,
    required super.phone,
    required super.verified,
  });

  factory PharmacyModel.fromJson(
    Map<String, dynamic> json, {
    required String documentId,
  }) {
    final pharmacyId = json['pharmacyId'];
    final name = json['name'];
    final licenseNo = json['licenseNo'];
    final address = json['address'];
    final latitude = json['lat'];
    final longitude = json['lng'];
    final phone = json['phone'];
    final verified = json['verified'];

    if (name is! String ||
        licenseNo is! String ||
        address is! String ||
        phone is! String ||
        verified is! bool ||
        latitude is! num ||
        longitude is! num) {
      throw const FormatException('Invalid pharmacy document.');
    }
    final latitudeValue = latitude.toDouble();
    final longitudeValue = longitude.toDouble();
    if (!latitudeValue.isFinite ||
        latitudeValue < -90 ||
        latitudeValue > 90 ||
        !longitudeValue.isFinite ||
        longitudeValue < -180 ||
        longitudeValue > 180) {
      throw const FormatException('Pharmacy coordinates are out of range.');
    }

    return PharmacyModel(
      pharmacyId: pharmacyId is String && pharmacyId.isNotEmpty
          ? pharmacyId
          : documentId,
      name: name,
      licenseNo: licenseNo,
      address: address,
      latitude: latitudeValue,
      longitude: longitudeValue,
      phone: phone,
      verified: verified,
    );
  }
}
