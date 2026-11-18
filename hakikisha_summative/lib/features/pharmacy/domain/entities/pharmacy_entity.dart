import 'package:equatable/equatable.dart';

import 'pharmacy_coordinates.dart';

class PharmacyEntity extends Equatable {
  const PharmacyEntity({
    required this.pharmacyId,
    required this.name,
    required this.licenseNo,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.verified,
  });

  final String pharmacyId;
  final String name;
  final String licenseNo;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final bool verified;

  PharmacyCoordinates get coordinates => PharmacyCoordinates(
    latitude: latitude,
    longitude: longitude,
  );

  @override
  List<Object> get props => [
    pharmacyId,
    name,
    licenseNo,
    address,
    latitude,
    longitude,
    phone,
    verified,
  ];
}
