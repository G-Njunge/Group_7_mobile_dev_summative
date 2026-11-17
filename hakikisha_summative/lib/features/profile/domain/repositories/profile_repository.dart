import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Stream<ProfileEntity?> watchProfile(String uid);

  Future<void> updateProfile({
    required String uid,
    required String fullName,
    String? phone,
    String? photoUrl,
  });

  Future<void> deleteAccount(String uid);
}
