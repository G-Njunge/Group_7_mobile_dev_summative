import 'package:equatable/equatable.dart';

class MedicineEntity extends Equatable {
  final String medicineId;
  final String name;
  final String manufacturer;
  final String rfdaRegNo; // Maps to Firestore 'ppbRegNo' per ERD contract
  final String dosageForm;
  final String strength;

  const MedicineEntity({
    required this.medicineId,
    required this.name,
    required this.manufacturer,
    required this.rfdaRegNo,
    required this.dosageForm,
    required this.strength,
  });

  @override
  List<Object?> get props => [
        medicineId,
        name,
        manufacturer,
        rfdaRegNo,
        dosageForm,
        strength,
      ];
}
