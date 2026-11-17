import '../entities/pharmacy_entity.dart';

abstract interface class PharmacyRepository {
  Stream<List<PharmacyEntity>> watchPharmacies();
}
