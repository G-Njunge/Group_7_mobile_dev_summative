import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Stream<ProfileEntity?> watchProfile(String uid) =>
      _remote.watchUser(uid).map((data) {
        if (data == null) return null;
        return _toEntity(UserModel.fromJson(data));
      });

  /// Sends only the three fields the rules let a user change. Email,
  /// sign-in method and createdAt are never sent, so they can't be altered.
  @override
  Future<void> updateProfile({
    required String uid,
    required String fullName,
    String? phone,
    String? photoUrl,
  }) => _remote.updateUser(uid, {
    'fullName': fullName,
    'phone': phone,
    'photoUrl': photoUrl,
  });

  @override
  Future<void> deleteAccount(String uid) => _remote.deleteUser(uid);

  ProfileEntity _toEntity(UserModel user) => ProfileEntity(
    uid: user.uid,
    fullName: user.fullName,
    email: user.email,
    phone: user.phone,
    authProvider: user.authProvider,
    photoUrl: user.photoUrl,
    createdAt: user.createdAt,
  );
}
