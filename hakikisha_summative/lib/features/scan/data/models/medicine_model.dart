import '../../domain/entities/medicine_entity.dart';

class MedicineModel extends MedicineEntity {
  const MedicineModel({
    required super.medicineId,
    required super.name,
    required super.manufacturer,
    required super.rfdaRegNo,
    required super.dosageForm,
    required super.strength,
  });

  factory MedicineModel.fromFirestore(String id, Map<String, dynamic> json) {
    return MedicineModel(
      medicineId: id,
      name: json['name'] as String? ?? 'Unknown Medicine',
      manufacturer: json['manufacturer'] as String? ?? 'Unknown Manufacturer',
      rfdaRegNo: json['registrationNo'] as String? ?? 'N/A', // ERD key
      dosageForm: json['dosageForm'] as String? ?? '',
      strength: json['strength'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
      'name': name,
      'manufacturer': manufacturer,
      'registrationNo': rfdaRegNo,
      'dosageForm': dosageForm,
      'strength': strength,
    };
  }
}
