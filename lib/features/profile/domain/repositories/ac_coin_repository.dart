import '../../../../config/database/app_database.dart';

/// AC 币 Repository 接口（Domain 层）
abstract class AcCoinRepository {
  /// 获取当前余额
  Future<int> getBalance();

  /// 获取所有 AC 币交易记录（按时间倒序）
  Future<List<AcCoinTransaction>> getAllTransactions();

  /// 增加 AC 币（签到奖励、连续打卡奖励等）
  Future<void> addCoins(int amount, String type, int? relatedDate);

  /// 扣除 AC 币（补签等）
  Future<void> deductCoins(int amount, String type, int? relatedDate);

  /// 获取已领取的连续打卡奖励类型集合
  Future<Set<String>> getClaimedStreakTypes();
}
