import 'dart:async';

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/pharmacy_coordinates.dart';
import '../../domain/services/pharmacy_location_service.dart';

class GeolocatorPharmacyLocationService implements PharmacyLocationService {
  @override
  Future<PharmacyCoordinates> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const PharmacyLocationFailure(
          'Turn on location services to find your position.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw const PharmacyLocationFailure(
          'Allow location access in your device settings to use this feature.',
        );
      }
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw const PharmacyLocationFailure(
          'Location permission is needed to find your position.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return PharmacyCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on TimeoutException {
      throw const PharmacyLocationFailure(
        'Could not get your location in time. Please try again.',
      );
    } on LocationServiceDisabledException {
      throw const PharmacyLocationFailure(
        'Turn on location services to find your position.',
      );
    } on PermissionDefinitionsNotFoundException {
      throw const PharmacyLocationFailure(
        'Location permission is not configured for this platform.',
      );
    } on PermissionRequestInProgressException {
      throw const PharmacyLocationFailure(
        'A location permission request is already in progress.',
      );
    } on PlatformException {
      throw const PharmacyLocationFailure(
        'Could not get your location. Please try again.',
      );
    }
  }
}
