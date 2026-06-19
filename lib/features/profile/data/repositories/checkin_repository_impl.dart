import 'package:drift/drift.dart';
import '../../../../config/database/app_database.dart';
import '../../domain/repositories/checkin_repository.dart';
import '../../domain/repositories/ac_coin_repository.dart';

/// 签到 Repository 实现（Data 层）
class CheckInRepositoryImpl implements CheckInRepository {
  final AppDatabase _db;
  final AcCoinRepository _acCoinRepo;

  CheckInRepositoryImpl(this._db, this._acCoinRepo);

  @override
  Future<List<CheckInRecord>> getAll() async {
    return _db.select(_db.checkInRecords).get();
  }

  @override
  Future<List<CheckInRecord>> getByMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final all = await _db.select(_db.checkInRecords).get();
    return all.where((r) =>
        !r.checkInDate.isBefore(start) && r.checkInDate.isBefore(end)).toList();
  }

  @override
  Future<int> getCount() async {
    final all = await _db.select(_db.checkInRecords).get();
    return all.length;
  }

  @override
  Future<bool> isCheckedToday() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final all = await _db.select(_db.checkInRecords).get();
    return all.any((r) {
      final d = r.checkInDate;
      return d.year == today.year && d.month == today.month && d.day == today.day;
    });
  }

  @override
  Future<bool> checkIn() async {
    if (await isCheckedToday()) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await _db.into(_db.checkInRecords).insert(
      CheckInRecordsCompanion.insert(checkInDate: today),
    );

    // 发放每日打卡 AC 币
    await _acCoinRepo.addCoins(10, 'daily_checkin', today.millisecondsSinceEpoch);

    // 检查连续打卡奖励
    final consecutive = await getConsecutiveDays();
    await _checkStreakRewards(consecutive, today);

    return true;
  }

  @override
  Future<int> getConsecutiveDays() async {
    final all = await _db.select(_db.checkInRecords).get();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final checkedToday = all.any((r) {
      final d = r.checkInDate;
      return d.year == today.year && d.month == today.month && d.day == today.day;
    });

    int consecutive = 0;
    final startOffset = checkedToday ? 0 : 1;

    for (int i = startOffset; i < 365 + startOffset; i++) {
      final day = today.subtract(Duration(days: i));
      final found = all.any((r) {
        final d = r.checkInDate;
        return d.year == day.year && d.month == day.month && d.day == day.day;
      });
      if (found) {
        consecutive++;
      } else {
        break;
      }
    }

    return consecutive;
  }

  @override
  Future<bool> makeupCheckIn(DateTime date) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    // 校验：不能是今天或未来
    if (!selectedDate.isBefore(today)) return false;

    // 校验：不能重复签到
    final all = await _db.select(_db.checkInRecords).get();
    final alreadyChecked = all.any((r) {
      final d = r.checkInDate;
      return d.year == selectedDate.year &&
          d.month == selectedDate.month &&
          d.day == selectedDate.day;
    });
    if (alreadyChecked) return false;

    // 校验：余额 >= 100
    final balance = await _acCoinRepo.getBalance();
    if (balance < 100) return false;

    // 插入补签记录
    await _db.into(_db.checkInRecords).insert(
      CheckInRecordsCompanion.insert(
        checkInDate: selectedDate,
        isMakeup: const Value(true),
      ),
    );

    // 扣除 AC 币
    await _acCoinRepo.deductCoins(100, 'makeup_cost', selectedDate.millisecondsSinceEpoch);

    return true;
  }

  /// 检查并发放连续打卡奖励
  Future<void> _checkStreakRewards(int consecutive, DateTime today) async {
    final claimedTypes = await _acCoinRepo.getClaimedStreakTypes();

    if (consecutive >= 365 && !claimedTypes.contains('streak_365d')) {
      await _acCoinRepo.addCoins(2000, 'streak_365d', today.millisecondsSinceEpoch);
    } else if (consecutive >= 180 && !claimedTypes.contains('streak_180d')) {
      await _acCoinRepo.addCoins(1000, 'streak_180d', today.millisecondsSinceEpoch);
    } else if (consecutive >= 30 && !claimedTypes.contains('streak_30d')) {
      await _acCoinRepo.addCoins(300, 'streak_30d', today.millisecondsSinceEpoch);
    } else if (consecutive >= 7 && !claimedTypes.contains('streak_7d')) {
      await _acCoinRepo.addCoins(70, 'streak_7d', today.millisecondsSinceEpoch);
    }
  }

  /// 获取本次签到触发的连续打卡奖励信息（用于 UI 展示）
  /// 返回 null 表示无奖励，否则返回奖励描述 key
  Future<String?> getLastStreakRewardType() async {
    final txns = await _db.select(_db.acCoinTransactions).get();
    if (txns.isEmpty) return null;
    // 按时间倒序，找最近一条 streak_ 类型
    txns.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    for (final t in txns) {
      if (t.type.startsWith('streak_')) return t.type;
    }
    return null;
  }
}
