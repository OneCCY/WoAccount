import '../../../../config/database/app_database.dart';

/// 签到 Repository 接口（Domain 层）
abstract class CheckInRepository {
  /// 获取所有签到记录
  Future<List<CheckInRecord>> getAll();

  /// 获取指定月份的签到记录
  Future<List<CheckInRecord>> getByMonth(int year, int month);

  /// 获取签到记录总数
  Future<int> getCount();

  /// 检查今天是否已签到
  Future<bool> isCheckedToday();

  /// 执行签到，返回是否成功
  Future<bool> checkIn();

  /// 计算连续签到天数
  Future<int> getConsecutiveDays();

  /// 补签（扣除 AC 币）
  Future<bool> makeupCheckIn(DateTime date);
}
