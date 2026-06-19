import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/toast.dart';
import '../../../../core/widgets/page_refresh_mixin.dart';

/// 打卡日历页
class CheckInCalendarPage extends ConsumerStatefulWidget {
  const CheckInCalendarPage({super.key});

  @override
  ConsumerState<CheckInCalendarPage> createState() => _CheckInCalendarPageState();
}

class _CheckInCalendarPageState extends ConsumerState<CheckInCalendarPage> with PageRefreshMixin {
  @override
  String get routePath => '/profile/checkin';

  @override
  void onRefresh() => _loadData();

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
    final checkInRepo = ref.read(checkInRepositoryProvider);
    final acCoinRepo = ref.read(acCoinRepositoryProvider);

    // 加载 AC 币余额
    final balance = await acCoinRepo.getBalance();

    // 加载当月打卡记录
    final records = await checkInRepo.getByMonth(_currentMonth.year, _currentMonth.month);

    final checked = <int>{};
    final makeup = <int>{};
    for (final r in records) {
      checked.add(r.checkInDate.day);
      if (r.isMakeup) makeup.add(r.checkInDate.day);
    }

    // 检查今天是否已打卡
    final checkedToday = await checkInRepo.isCheckedToday();

    // 计算连续打卡天数
    final consecutive = await checkInRepo.getConsecutiveDays();

    if (mounted) {
      setState(() {
        _checkedDays = checked;
        _makeupDays = makeup;
        _acBalance = balance;
        _todayCheckedIn = checkedToday;
        _consecutiveDays = consecutive;
      });
    }
  }

  Future<void> _checkIn() async {
    if (_todayCheckedIn) {
      AppToast.show(context, AppLocalizations.of(context)!.checkinAlreadyCheckedIn, duration: const Duration(milliseconds: 800));
      return;
    }

    final checkInRepo = ref.read(checkInRepositoryProvider);
    final oldConsecutive = _consecutiveDays;
    final success = await checkInRepo.checkIn();

    if (!success) {
      if (mounted) {
        AppToast.show(context, AppLocalizations.of(context)!.checkinAlreadyCheckedIn, duration: const Duration(milliseconds: 800));
      }
      return;
    }

    // 检查连续打卡奖励
    final newConsecutive = oldConsecutive + 1;
    _showStreakRewardIfNeeded(newConsecutive);

    await _loadData();

    if (mounted) {
      AppToast.show(context, AppLocalizations.of(context)!.checkinCheckInSuccess, duration: const Duration(milliseconds: 800));
    }
  }

  /// 根据连续天数判断并显示奖励通知
  void _showStreakRewardIfNeeded(int consecutive) {
    final l10n = AppLocalizations.of(context)!;
    if (consecutive == 365) {
      _showRewardSnackBar(l10n.checkinStreak365);
    } else if (consecutive == 180) {
      _showRewardSnackBar(l10n.checkinStreak180);
    } else if (consecutive == 30) {
      _showRewardSnackBar(l10n.checkinStreak30);
    } else if (consecutive == 7) {
      _showRewardSnackBar(l10n.checkinStreak7);
    }
  }

  void _showRewardSnackBar(String msg) {
    if (mounted) {
      AppToast.show(context, msg, duration: const Duration(seconds: 2));
    }
  }

  Future<void> _makeupCheckIn() async {
    final l10n = AppLocalizations.of(context)!;
    final selected = _selectedDay;
    if (selected == null) {
      AppToast.show(context, l10n.checkinMakeupSelectHint, duration: const Duration(milliseconds: 800));
      return;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(selected.year, selected.month, selected.day);

    if (!selectedDate.isBefore(today)) {
      AppToast.show(context, l10n.checkinMakeupFutureError, duration: const Duration(milliseconds: 800));
      return;
    }

    if (_checkedDays.contains(selected.day)) {
      AppToast.show(context, l10n.checkinMakeupAlreadyChecked, duration: const Duration(milliseconds: 800));
      return;
    }

    if (_acBalance < 100) {
      AppToast.show(context, l10n.checkinMakeupInsufficient, duration: const Duration(milliseconds: 800));
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

    final checkInRepo = ref.read(checkInRepositoryProvider);
    final success = await checkInRepo.makeupCheckIn(selectedDate);

    if (!success) {
      if (mounted) {
        AppToast.show(context, l10n.checkinMakeupAlreadyChecked, duration: const Duration(milliseconds: 800));
      }
      return;
    }

    await _loadData();

    if (mounted) {
      AppToast.show(context, l10n.checkinMakeupSuccess, duration: const Duration(milliseconds: 800));
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
