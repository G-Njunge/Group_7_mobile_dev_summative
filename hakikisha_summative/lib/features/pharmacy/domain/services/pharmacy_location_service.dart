import '../entities/pharmacy_coordinates.dart';

abstract interface class PharmacyLocationService {
  Future<PharmacyCoordinates> getCurrentLocation();
}

class PharmacyLocationFailure implements Exception {
  const PharmacyLocationFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
