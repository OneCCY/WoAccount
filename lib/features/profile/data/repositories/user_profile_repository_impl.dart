import '../../../../config/database/app_database.dart';
import '../../domain/repositories/user_profile_repository.dart';

/// 用户资料 Repository 实现（Data 层）
class UserProfileRepositoryImpl implements UserProfileRepository {
  final AppDatabase _db;

  UserProfileRepositoryImpl(this._db);

  @override
  Future<UserProfile?> getProfile() async {
    final profiles = await _db.select(_db.userProfiles).get();
    return profiles.isNotEmpty ? profiles.first : null;
  }

  @override
  Future<bool> updateProfile(UserProfilesCompanion companion) async {
    final profile = await getProfile();
    if (profile == null) return false;
    final count = await (_db.update(_db.userProfiles)..where((t) => t.id.equals(profile.id)))
        .write(companion);
    return count > 0;
  }
}
