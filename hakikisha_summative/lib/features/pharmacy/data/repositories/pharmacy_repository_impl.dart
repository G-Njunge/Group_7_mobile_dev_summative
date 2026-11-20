import '../../domain/entities/pharmacy_entity.dart';
import '../../domain/repositories/pharmacy_repository.dart';
import '../datasources/pharmacy_remote_data_source.dart';

class PharmacyRepositoryImpl implements PharmacyRepository {
  PharmacyRepositoryImpl(this._remoteDataSource);

  final PharmacyRemoteDataSource _remoteDataSource;

  @override
  Stream<List<PharmacyEntity>> watchPharmacies() =>
      _remoteDataSource.watchPharmacies().map(
        (pharmacies) => pharmacies.map<PharmacyEntity>((item) => item).toList(),
      );
}
