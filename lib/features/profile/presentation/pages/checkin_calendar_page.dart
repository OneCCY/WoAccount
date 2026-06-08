import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 打卡日历页
class CheckInCalendarPage extends ConsumerStatefulWidget {
  const CheckInCalendarPage({super.key});

  @override
  ConsumerState<CheckInCalendarPage> createState() => _CheckInCalendarPageState();
}

class _CheckInCalendarPageState extends ConsumerState<CheckInCalendarPage> {
  late DateTime _currentMonth;
  Set<int> _checkedDays = {}; // 当月已打卡的 day 集合
  Set<int> _makeupDays = {}; // 当月补签的 day 集合
  int _acBalance = 0;
  bool _todayCheckedIn = false;
  int _consecutiveDays = 0;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _loadData();
  }

  Future<void> _loadData() async {
    final db = ref.read(appDatabaseProvider);

    // 加载 AC 币余额
    final balances = await db.select(db.acCoinBalances).get();
    final balance = balances.isNotEmpty ? balances.first.balance : 0;

    // 加载当月打卡记录
    final start = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final end = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    final allRecords = await db.select(db.checkInRecords).get();
    final records = allRecords.where((r) =>
        !r.checkInDate.isBefore(start) && r.checkInDate.isBefore(end)).toList();

    final checked = <int>{};
    final makeup = <int>{};
    for (final r in records) {
      checked.add(r.checkInDate.day);
      if (r.isMakeup) makeup.add(r.checkInDate.day);
    }

    // 检查今天是否已打卡
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayRecords = allRecords.where((r) {
      final d = r.checkInDate;
      return d.year == today.year && d.month == today.month && d.day == today.day;
    }).toList();

    // 计算连续打卡天数
    int consecutive = 0;
    if (todayRecords.isNotEmpty) {
      consecutive = 1;
      for (int i = 1; i < 365; i++) {
        final day = today.subtract(Duration(days: i));
        final found = allRecords.any((r) {
          final d = r.checkInDate;
          return d.year == day.year && d.month == day.month && d.day == day.day;
        });
        if (found) {
          consecutive++;
        } else {
          break;
        }
      }
    }

    if (mounted) {
      setState(() {
        _checkedDays = checked;
        _makeupDays = makeup;
        _acBalance = balance;
        _todayCheckedIn = todayRecords.isNotEmpty;
        _consecutiveDays = consecutive;
      });
    }
  }

  Future<void> _checkIn() async {
    if (_todayCheckedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('今天已经打过卡了'), behavior: SnackBarBehavior.floating, duration: Duration(milliseconds: 800)),
      );
      return;
    }

    final db = ref.read(appDatabaseProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await db.into(db.checkInRecords).insert(
      CheckInRecordsCompanion.insert(checkInDate: today),
    );

    // 发放每日打卡 AC 币
    await _addAcCoins(db, 10, 'daily_checkin', '每日打卡奖励', today.millisecondsSinceEpoch);

    // 检查连续打卡奖励
    final newConsecutive = _consecutiveDays + 1;
    await _checkStreakRewards(db, newConsecutive, today);

    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('打卡成功！+10 AC币'), behavior: SnackBarBehavior.floating, duration: Duration(milliseconds: 800)),
      );
    }
  }

  Future<void> _checkStreakRewards(AppDatabase db, int consecutive, DateTime today) async {
    // 获取已领取的连续奖励类型
    final allTxns = await db.select(db.acCoinTransactions).get();
    final claimedTypes = allTxns.where((t) => t.type.startsWith('streak_')).map((t) => t.type).toSet();

    if (consecutive >= 365 && !claimedTypes.contains('streak_365d')) {
      await _addAcCoins(db, 2000, 'streak_365d', '连续打卡365天奖励', today.millisecondsSinceEpoch);
      _showRewardSnackBar('连续打卡一年！+2000 AC币');
    } else if (consecutive >= 180 && !claimedTypes.contains('streak_180d')) {
      await _addAcCoins(db, 1000, 'streak_180d', '连续打卡180天奖励', today.millisecondsSinceEpoch);
      _showRewardSnackBar('连续打卡半年！+1000 AC币');
    } else if (consecutive >= 30 && !claimedTypes.contains('streak_30d')) {
      await _addAcCoins(db, 300, 'streak_30d', '连续打卡30天奖励', today.millisecondsSinceEpoch);
      _showRewardSnackBar('连续打卡一个月！+300 AC币');
    } else if (consecutive >= 7 && !claimedTypes.contains('streak_7d')) {
      await _addAcCoins(db, 70, 'streak_7d', '连续打卡7天奖励', today.millisecondsSinceEpoch);
      _showRewardSnackBar('连续打卡7天！+70 AC币');
    }
  }

  Future<void> _addAcCoins(AppDatabase db, int amount, String type, String desc, int? relatedDate) async {
    await db.into(db.acCoinTransactions).insert(AcCoinTransactionsCompanion.insert(
      userId: const Value(1),
      amount: amount,
      type: type,
      description: Value(desc),
      relatedDate: Value(relatedDate),
    ));

    final balances = await db.select(db.acCoinBalances).get();
    if (balances.isNotEmpty) {
      await (db.update(db.acCoinBalances)..where((t) => t.id.equals(balances.first.id)))
          .write(AcCoinBalancesCompanion(balance: Value(balances.first.balance + amount)));
    }
  }

  void _showRewardSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
      );
    }
  }

  Future<void> _makeupCheckIn() async {
    final selected = _selectedDay;
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先选择一个未打卡的日期'), behavior: SnackBarBehavior.floating, duration: Duration(milliseconds: 800)),
      );
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(selected.year, selected.month, selected.day);

    if (!selectedDate.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('只能补签过去的日期'), behavior: SnackBarBehavior.floating, duration: Duration(milliseconds: 800)),
      );
      return;
    }

    if (_checkedDays.contains(selected.day)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('该日期已打卡'), behavior: SnackBarBehavior.floating, duration: Duration(milliseconds: 800)),
      );
      return;
    }

    if (_acBalance < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AC币不足，补签需要100 AC币'), behavior: SnackBarBehavior.floating, duration: Duration(milliseconds: 800)),
      );
      return;
    }

    // 二次确认
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('补签确认'),
        content: Text('确定要补签 ${DateFormat('M月d日').format(selectedDate)} 吗？\n将消耗 100 AC币（当前余额: $_acBalance）'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('确认补签', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final db = ref.read(appDatabaseProvider);

    // 插入补签记录
    await db.into(db.checkInRecords).insert(
      CheckInRecordsCompanion.insert(
        checkInDate: selectedDate,
        isMakeup: const Value(true),
      ),
    );

    // 扣除 AC 币
    await db.into(db.acCoinTransactions).insert(AcCoinTransactionsCompanion.insert(
      userId: const Value(1),
      amount: -100,
      type: 'makeup_cost',
      description: Value('补签 ${DateFormat('M月d日').format(selectedDate)}'),
      relatedDate: Value(selectedDate.millisecondsSinceEpoch),
    ));

    final balances = await db.select(db.acCoinBalances).get();
    if (balances.isNotEmpty) {
      await (db.update(db.acCoinBalances)..where((t) => t.id.equals(balances.first.id)))
          .write(AcCoinBalancesCompanion(balance: Value(balances.first.balance - 100)));
    }

    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('补签成功！'), behavior: SnackBarBehavior.floating, duration: Duration(milliseconds: 800)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('打卡日历'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                ),
                child: Text('🪙 $_acBalance', style: AppTextStyles.footnote.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                )),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 统计信息
          _buildStatsCard(),
          const SizedBox(height: 12),
          // 日历
          Expanded(child: _buildCalendar(today)),
          // 底部操作
          _buildBottomBar(today),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.md),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          _statItem('$_consecutiveDays', '连续打卡'),
          _statDivider(),
          _statItem('$_acBalance', 'AC币余额'),
          _statDivider(),
          _statItem(_todayCheckedIn ? '✓' : '—', '今日状态'),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(height: 30, width: 1, color: AppColors.separatorOpaque);

  Widget _buildCalendar(DateTime today) {
    final year = _currentMonth.year;
    final month = _currentMonth.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final startWeekday = firstDay.weekday % 7;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Column(
        children: [
          // 月份导航
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() {
                  _currentMonth = DateTime(year, month - 1);
                  _selectedDay = null;
                  _loadData();
                }),
              ),
              Text(DateFormat('yyyy年M月').format(_currentMonth), style: AppTextStyles.h3),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() {
                  _currentMonth = DateTime(year, month + 1);
                  _selectedDay = null;
                  _loadData();
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 星期头
          Row(
            children: ['一', '二', '三', '四', '五', '六', '日']
                .map((d) => Expanded(
                      child: Center(child: Text(d, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500))),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // 日历网格
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: startWeekday + lastDay.day,
              itemBuilder: (context, index) {
                if (index < startWeekday) return const SizedBox.shrink();
                final day = index - startWeekday + 1;
                final date = DateTime(year, month, day);
                final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
                final isChecked = _checkedDays.contains(day);
                final isMakeup = _makeupDays.contains(day);
                final isSelected = _selectedDay != null &&
                    _selectedDay!.year == year &&
                    _selectedDay!.month == month &&
                    _selectedDay!.day == day;
                final isFuture = date.isAfter(today);

                return GestureDetector(
                  onTap: isFuture ? null : () => setState(() => _selectedDay = date),
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isChecked
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : (isSelected ? AppColors.primarySurface : null),
                      borderRadius: BorderRadius.circular(8),
                      border: isToday
                          ? Border.all(color: AppColors.primary, width: 1.5)
                          : (isSelected ? Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 1) : null),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isFuture
                                ? AppColors.textHint
                                : (isChecked ? AppColors.primary : AppColors.textPrimary),
                          ),
                        ),
                        if (isChecked)
                          Icon(
                            isMakeup ? Icons.edit_calendar : Icons.check_circle,
                            size: 12,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(DateTime today) {
    final selected = _selectedDay;
    final canMakeup = selected != null &&
        selected.isBefore(today) &&
        !_checkedDays.contains(selected.day);

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.md,
        12,
        AppDimensions.md,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.separatorOpaque, width: 0.5)),
      ),
      child: Row(
        children: [
          // 补签按钮
          Expanded(
            child: OutlinedButton.icon(
              onPressed: canMakeup ? _makeupCheckIn : null,
              icon: const Icon(Icons.edit_calendar, size: 18),
              label: Text(canMakeup ? '补签 (-100 AC币)' : '选择日期后补签'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 今日打卡按钮
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _todayCheckedIn ? null : _checkIn,
              icon: Icon(_todayCheckedIn ? Icons.check_circle : Icons.card_giftcard, size: 18, color: Colors.white),
              label: Text(_todayCheckedIn ? '已打卡' : '今日打卡 +10', style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _todayCheckedIn ? AppColors.textHint : AppColors.primary,
                disabledBackgroundColor: AppColors.textHint,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
