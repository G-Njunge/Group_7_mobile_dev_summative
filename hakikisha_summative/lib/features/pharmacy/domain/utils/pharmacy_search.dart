import 'dart:math' as math;

import '../entities/pharmacy_coordinates.dart';
import '../entities/pharmacy_entity.dart';

abstract final class PharmacySearch {
  static const double _earthRadiusKm = 6371;

  static List<PharmacyEntity> filter(
    List<PharmacyEntity> pharmacies,
    String query, {
    PharmacyCoordinates? from,
  }) {
    final normalizedQuery = query.trim().toLowerCase();
    final results = pharmacies.where((pharmacy) {
      if (normalizedQuery.isEmpty) return true;

      return pharmacy.name.toLowerCase().contains(normalizedQuery) ||
          pharmacy.address.toLowerCase().contains(normalizedQuery) ||
          pharmacy.licenseNo.toLowerCase().contains(normalizedQuery) ||
          pharmacy.phone.toLowerCase().contains(normalizedQuery);
    }).toList();

    if (from != null) {
      results.sort(
        (a, b) => distanceKm(
          from,
          a.coordinates,
        ).compareTo(distanceKm(from, b.coordinates)),
      );
    }

    return results;
  }

  static double distanceKm(PharmacyCoordinates from, PharmacyCoordinates to) {
    final latitudeDelta = _toRadians(to.latitude - from.latitude);
    final longitudeDelta = _toRadians(to.longitude - from.longitude);
    final fromLatitude = _toRadians(from.latitude);
    final toLatitude = _toRadians(to.latitude);
    final sinLatitudeDelta = math.sin(latitudeDelta / 2);
    final sinLongitudeDelta = math.sin(longitudeDelta / 2);
    final haversine =
        sinLatitudeDelta * sinLatitudeDelta +
        math.cos(fromLatitude) *
            math.cos(toLatitude) *
            sinLongitudeDelta *
            sinLongitudeDelta;
    final boundedHaversine = haversine.clamp(0.0, 1.0).toDouble();

    return 2 * _earthRadiusKm * math.asin(math.sqrt(boundedHaversine));
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}
