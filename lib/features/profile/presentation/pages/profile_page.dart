import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../main.dart';

/// 我的页面
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  UserProfile? _profile;
  int _consecutiveDays = 0;
  int _totalCheckInDays = 0;
  int _totalTransactions = 0;
  bool _todayCheckedIn = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final db = ref.read(appDatabaseProvider);

      // 加载用户资料
      final profiles = await db.select(db.userProfiles).get();
      final profile = profiles.isNotEmpty ? profiles.first : null;

      // 加载打卡数据
      final checkIns = await db.select(db.checkInRecords).get();
      final totalDays = checkIns.length;

      // 计算连续打卡天数
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayRecord = checkIns.where((r) {
        final d = r.checkInDate;
        return d.year == today.year && d.month == today.month && d.day == today.day;
      }).toList();
      final checkedToday = todayRecord.isNotEmpty;

      int consecutive = 0;
      if (checkedToday) {
        consecutive = 1;
        for (int i = 1; i < 365; i++) {
          final day = today.subtract(Duration(days: i));
          final found = checkIns.any((r) {
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

      // 加载记账总笔数
      final txnCount = await db.select(db.transactions).get();
      final count = txnCount.where((t) => !t.isDeleted).length;

      if (mounted) {
        setState(() {
          _profile = profile;
          _consecutiveDays = consecutive;
          _totalCheckInDays = totalDays;
          _totalTransactions = count;
          _todayCheckedIn = checkedToday;
        });
      }
    } catch (e) {
      // 加载失败时静默处理，保留当前状态
      debugPrint('加载数据失败: $e');
    }
  }

  Future<void> _checkIn() async {
    if (_todayCheckedIn) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('今天已经打过卡了'), behavior: SnackBarBehavior.floating, duration: Duration(milliseconds: 800)),
        );
      }
      return;
    }

    try {
      final db = ref.read(appDatabaseProvider);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      await db.into(db.checkInRecords).insert(
        CheckInRecordsCompanion.insert(checkInDate: today),
      );

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('打卡成功！'), behavior: SnackBarBehavior.floating, duration: Duration(milliseconds: 800)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打卡失败: $e'), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 用户卡片 + 打卡按钮
                  _buildUserCard(),
                  const SizedBox(height: 12),
                  // 统计数据
                  _buildStatsRow(),
                  const SizedBox(height: 12),
                  // 功能菜单
                  _buildFuncGrid(),
                  const SizedBox(height: 12),
                  // 工具与服务
                  _buildMenuGroup(
                    title: '工具与服务',
                    context: context,
                    items: [
                      _MenuItem(Icons.lock_outline, '密码锁'),
                      _MenuItem(Icons.monetization_on_outlined, 'AC币'),
                      _MenuItem(Icons.smart_toy_outlined, 'AI 配置'),
                      _MenuItem(Icons.cloud_outlined, '数据备份'),
                      _MenuItem(Icons.file_download_outlined, '账单导入'),
                      _MenuItem(Icons.file_upload_outlined, '账单导出'),
                      _MenuItem(Icons.chat_bubble_outline, '用户反馈'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 设置
                  _buildMenuGroup(
                    context: context,
                    items: [
                      _MenuItem(Icons.settings_outlined, '设置'),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 用户卡片 + 打卡按钮
  Widget _buildUserCard() {
    final avatarPath = _profile?.avatarPath;
    final nickname = _profile?.nickname ?? '用户';
    final uid = _profile?.uid ?? '';

    // 检查头像文件是否存在
    final hasValidAvatar = avatarPath != null && File(avatarPath).existsSync();

    return Container(
      padding: const EdgeInsets.fromLTRB(AppDimensions.md, 20, AppDimensions.md, 20),
      color: AppColors.surface,
      child: Row(
        children: [
          // 头像（点击进入个人资料编辑）
          GestureDetector(
            onTap: () => context.push('/profile/edit').then((_) => _loadData()),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primarySurface,
                  backgroundImage: hasValidAvatar ? FileImage(File(avatarPath)) : null,
                  onBackgroundImageError: hasValidAvatar ? (exception, stackTrace) {
                    debugPrint('头像加载失败: $exception');
                  } : null,
                  child: !hasValidAvatar
                      ? const Icon(Icons.person_outline, size: 28, color: AppColors.primaryDark)
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nickname, style: AppTextStyles.h3),
                    const SizedBox(height: 2),
                    Text('ID: $uid', style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // 打卡按钮
          GestureDetector(
            onTap: _checkIn,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _todayCheckedIn ? AppColors.surfaceSecondary : AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _todayCheckedIn ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                    size: 18,
                    color: _todayCheckedIn ? AppColors.textTertiary : Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _todayCheckedIn ? '已打卡' : '打卡',
                    style: AppTextStyles.footnote.copyWith(
                      color: _todayCheckedIn ? AppColors.textTertiary : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 统计数据行：连续打卡 / 打卡总天数 / 记账总笔数
  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.push('/checkin-calendar').then((_) => _loadData()),
            child: _buildStatItem('$_consecutiveDays', '连续打卡'),
          ),
          _buildStatDivider(),
          _buildStatItem('$_totalCheckInDays', '打卡总天数'),
          _buildStatDivider(),
          _buildStatItem('$_totalTransactions', '记账总笔数'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: AppTextStyles.h2.copyWith(color: AppColors.primary), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.caption, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.separatorOpaque,
    );
  }

  /// 功能网格（5列，无背景色图标）
  Widget _buildFuncGrid() {
    const items = [
      _FuncItem(Icons.palette_outlined, '主题切换'),
      _FuncItem(Icons.book_outlined, '我的账本'),
      _FuncItem(Icons.account_balance_wallet_outlined, '预算管理'),
      _FuncItem(Icons.category_outlined, '分类管理'),
      _FuncItem(Icons.bar_chart_outlined, '报表分析'),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 0.9,
          mainAxisSpacing: 8,
          crossAxisSpacing: 4,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => _buildFuncButton(items[index], context),
      ),
    );
  }

  Widget _buildFuncButton(_FuncItem item, BuildContext context) {
    return InkWell(
      onTap: () => _onFuncTap(context, item.label),
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: 24, color: AppColors.textPrimary),
          const SizedBox(height: 4),
          Text(item.label, style: AppTextStyles.caption, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  /// 菜单组
  Widget _buildMenuGroup({
    String? title,
    required BuildContext context,
    required List<_MenuItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
              ),
            ...items.map((item) => _buildMenuItem(item, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item, BuildContext context, {Color? iconColor}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onMenuTap(context, item.label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.separatorOpaque, width: 0.5)),
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 20, color: iconColor ?? AppColors.textPrimary),
              const SizedBox(width: 12),
              Expanded(child: Text(item.label, style: AppTextStyles.body)),
              const Icon(Icons.chevron_right, size: 16, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  void _onFuncTap(BuildContext context, String label) {
    switch (label) {
      case '主题切换':
        _showThemePicker(context, ref);
        break;
      case '我的账本':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('账本功能即将推出'), behavior: SnackBarBehavior.floating, duration: Duration(milliseconds: 500)),
        );
        break;
      case '预算管理':
        context.push('/budget');
        break;
      case '分类管理':
        context.push('/categories/manage');
        break;
      case 'AI 配置':
        context.push('/settings/llm');
        break;
      case '报表分析':
      case '数据备份':
      case '账单导入':
      case '账单导出':
      case '用户反馈':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label功能即将推出'), behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 500)),
        );
        break;
    }
  }

  void _onMenuTap(BuildContext context, String label) {
    switch (label) {
      case '密码锁':
        context.push('/lock-settings');
        break;
      case 'AC币':
        context.push('/checkin-calendar');
        break;
      case 'AI 配置':
        context.push('/settings/llm');
        break;
      case '数据备份':
      case '账单导入':
      case '账单导出':
      case '用户反馈':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label功能即将推出'), behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 500)),
        );
        break;
      case '设置':
        context.push('/settings');
        break;
    }
  }
}

class _FuncItem {
  final IconData icon;
  final String label;
  const _FuncItem(this.icon, this.label);
}

class _MenuItem {
  final IconData icon;
  final String label;
  const _MenuItem(this.icon, this.label);
}

void _showThemePicker(BuildContext context, WidgetRef ref) {
  final themeProvider = ref.read(themeProviderOverrideProvider);
  final current = themeProvider.themeMode;

  showModalBottomSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.light_mode),
            title: const Text('浅色模式'),
            trailing: current == ThemeMode.light ? Icon(Icons.check, color: AppColors.primary) : null,
            onTap: () { themeProvider.setThemeMode(ThemeMode.light); Navigator.pop(ctx); },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('深色模式'),
            trailing: current == ThemeMode.dark ? Icon(Icons.check, color: AppColors.primary) : null,
            onTap: () { themeProvider.setThemeMode(ThemeMode.dark); Navigator.pop(ctx); },
          ),
          ListTile(
            leading: const Icon(Icons.settings_brightness),
            title: const Text('跟随系统'),
            trailing: current == ThemeMode.system ? Icon(Icons.check, color: AppColors.primary) : null,
            onTap: () { themeProvider.setThemeMode(ThemeMode.system); Navigator.pop(ctx); },
          ),
        ],
      ),
    ),
  );
}
