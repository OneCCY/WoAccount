import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import 'package:wo_account/l10n/app_localizations.dart';
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
      // 今天已打卡：从今天开始往前数
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
    } else {
      // 今天未打卡：从昨天开始往前数（显示截至昨天的连续记录）
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
        SnackBar(content: Text(AppLocalizations.of(context)!.checkinAlreadyCheckedIn), behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 800)),
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
    await _addAcCoins(db, 10, 'daily_checkin', AppLocalizations.of(context)!.checkinRewardDaily, today.millisecondsSinceEpoch);

    // 检查连续打卡奖励
    final newConsecutive = _consecutiveDays + 1;
    await _checkStreakRewards(db, newConsecutive, today);

    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.checkinCheckInSuccess), behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 800)),
      );
    }
  }

  Future<void> _checkStreakRewards(AppDatabase db, int consecutive, DateTime today) async {
    final l10n = AppLocalizations.of(context)!;
    // 获取已领取的连续奖励类型
    final allTxns = await db.select(db.acCoinTransactions).get();
    final claimedTypes = allTxns.where((t) => t.type.startsWith('streak_')).map((t) => t.type).toSet();

    if (consecutive >= 365 && !claimedTypes.contains('streak_365d')) {
      await _addAcCoins(db, 2000, 'streak_365d', l10n.checkinReward365, today.millisecondsSinceEpoch);
      _showRewardSnackBar(l10n.checkinStreak365);
    } else if (consecutive >= 180 && !claimedTypes.contains('streak_180d')) {
      await _addAcCoins(db, 1000, 'streak_180d', l10n.checkinReward180, today.millisecondsSinceEpoch);
      _showRewardSnackBar(l10n.checkinStreak180);
    } else if (consecutive >= 30 && !claimedTypes.contains('streak_30d')) {
      await _addAcCoins(db, 300, 'streak_30d', l10n.checkinReward30, today.millisecondsSinceEpoch);
      _showRewardSnackBar(l10n.checkinStreak30);
    } else if (consecutive >= 7 && !claimedTypes.contains('streak_7d')) {
      await _addAcCoins(db, 70, 'streak_7d', l10n.checkinReward7, today.millisecondsSinceEpoch);
      _showRewardSnackBar(l10n.checkinStreak7);
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
    final l10n = AppLocalizations.of(context)!;
    final selected = _selectedDay;
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.checkinMakeupSelectHint), behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 800)),
      );
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(selected.year, selected.month, selected.day);

    if (!selectedDate.isBefore(today)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.checkinMakeupFutureError), behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 800)),
      );
      return;
    }

    if (_checkedDays.contains(selected.day)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.checkinMakeupAlreadyChecked), behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 800)),
      );
      return;
    }

    if (_acBalance < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.checkinMakeupInsufficient), behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 800)),
      );
      return;
    }

    // 二次确认
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.checkinMakeupConfirmTitle),
        content: Text(l10n.checkinMakeupConfirmContent(DateFormat(l10n.txnDayFormat).format(selectedDate), '$_acBalance')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.checkinMakeupConfirm, style: TextStyle(color: context.colors.primary)),
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
      description: Value(l10n.checkinMakeupCost(DateFormat(l10n.txnDayFormat).format(selectedDate))),
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
        SnackBar(content: Text(l10n.checkinMakeupSuccess), behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 800)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(l10n.checkinTitle),
      ),
      body: Column(
        children: [
          // 统计信息
          _buildStatsCard(l10n),
          const SizedBox(height: 12),
          // 日历
          Expanded(child: _buildCalendar(today, l10n)),
          // 底部操作
          _buildBottomBar(today, l10n),
        ],
      ),
    );
  }

  Widget _buildStatsCard(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.md),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          _statItem('$_consecutiveDays', l10n.checkinConsecutiveDays),
          _statDivider(),
          _statItem('$_acBalance', l10n.checkinAcBalance),
          _statDivider(),
          _statItem(_todayCheckedIn ? '✓' : '—', l10n.checkinTodayStatus),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: context.textStyles.h2.copyWith(color: context.colors.primary)),
          const SizedBox(height: 4),
          Text(label, style: context.textStyles.caption),
        ],
      ),
    );
  }

  Widget _statDivider() => Container(height: 30, width: 1, color: context.colors.separatorOpaque);

  Widget _buildCalendar(DateTime today, AppLocalizations l10n) {
    final year = _currentMonth.year;
    final month = _currentMonth.month;
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);
    final startWeekday = firstDay.weekday % 7;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
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
              Text(l10n.reportMonthLabel(_currentMonth.year.toString(), _currentMonth.month.toString()), style: context.textStyles.h3),
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
            children: [l10n.weekMon, l10n.weekTue, l10n.weekWed, l10n.weekThu, l10n.weekFri, l10n.weekSat, l10n.weekSun]
                .map<Widget>((d) => Expanded(
                      child: Center(child: Text(d, style: context.textStyles.caption.copyWith(fontWeight: FontWeight.w500))),
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
                          ? context.colors.primary.withValues(alpha: 0.15)
                          : (isSelected ? context.colors.primarySurface : null),
                      borderRadius: BorderRadius.circular(8),
                      border: isToday
                          ? Border.all(color: context.colors.primary, width: 1.5)
                          : (isSelected ? Border.all(color: context.colors.primary.withValues(alpha: 0.5), width: 1) : null),
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
                                ? context.colors.textHint
                                : (isChecked ? context.colors.primary : context.colors.textPrimary),
                          ),
                        ),
                        if (isChecked)
                          Icon(
                            isMakeup ? Icons.edit_calendar : Icons.check_circle,
                            size: 12,
                            color: context.colors.primary,
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

  Widget _buildBottomBar(DateTime today, AppLocalizations l10n) {
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
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.separatorOpaque, width: 0.5)),
      ),
      child: Row(
        children: [
          // 补签按钮
          Expanded(
            child: OutlinedButton.icon(
              onPressed: canMakeup ? _makeupCheckIn : null,
              icon: const Icon(Icons.edit_calendar, size: 18),
              label: Text(canMakeup ? l10n.checkinMakeupButton : l10n.checkinMakeupSelectButton),
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
              label: Text(_todayCheckedIn ? l10n.checkinTodayCheckIn : l10n.checkinTodayCheckInButton, style: const TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _todayCheckedIn ? context.colors.textHint : context.colors.primary,
                disabledBackgroundColor: context.colors.textHint,
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
