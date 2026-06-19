import '../../../../config/database/app_database.dart';

/// 用户资料 Repository 接口（Domain 层）
abstract class UserProfileRepository {
  /// 获取用户资料（单例模式，始终返回第一条）
  Future<UserProfile?> getProfile();

  /// 更新用户资料
  Future<bool> updateProfile(UserProfilesCompanion companion);
}
