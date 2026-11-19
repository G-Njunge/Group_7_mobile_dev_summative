import 'package:equatable/equatable.dart';

class PharmacyCoordinates extends Equatable {
  const PharmacyCoordinates({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  List<Object> get props => [latitude, longitude];
}
