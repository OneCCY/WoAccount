import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/page_refresh_mixin.dart';
import '../../../../core/widgets/toast.dart';
import '../../../../main.dart';

/// 我的页面
class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> with PageRefreshMixin {
  UserProfile? _profile;
  int _consecutiveDays = 0;
  int _totalCheckInDays = 0;
  int _totalTransactions = 0;
  bool _todayCheckedIn = false;
  bool _isLoading = true;

  @override
  String get routePath => '/profile';

  @override
  void onRefresh() => _loadData();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final profileRepo = ref.read(userProfileRepositoryProvider);
      final checkInRepo = ref.read(checkInRepositoryProvider);
      final txnRepo = ref.read(transactionRepositoryProvider);
      final bookId = ref.read(currentBookProvider);

      final profile = await profileRepo.getProfile();
      final totalDays = await checkInRepo.getCount();
      final checkedToday = await checkInRepo.isCheckedToday();
      final consecutive = await checkInRepo.getConsecutiveDays();
      final txns = await txnRepo.getAll(bookId);

      if (mounted) {
        setState(() {
          _profile = profile;
          _consecutiveDays = consecutive;
          _totalCheckInDays = totalDays;
          _totalTransactions = txns.length;
          _todayCheckedIn = checkedToday;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      debugPrint('加载数据失败: $e');
    }
  }

  Future<void> _checkIn() async {
    if (_todayCheckedIn) {
      if (mounted) {
        AppToast.show(context, AppLocalizations.of(context)!.profileAlreadyCheckedIn, duration: const Duration(milliseconds: 800));
      }
      return;
    }

    try {
      final checkInRepo = ref.read(checkInRepositoryProvider);
      final success = await checkInRepo.checkIn();

      if (!success) {
        if (mounted) {
          AppToast.show(context, AppLocalizations.of(context)!.profileAlreadyCheckedIn, duration: const Duration(milliseconds: 800));
        }
        return;
      }

      // 检查是否触发了连续打卡奖励
      final claimedTypes = await checkInRepo.getConsecutiveDays();
      final newConsecutive = claimedTypes;
      _showStreakRewardIfNeeded(newConsecutive);

      await _loadData();

      if (mounted) {
        AppToast.show(context, AppLocalizations.of(context)!.profileCheckInSuccess, duration: const Duration(milliseconds: 800));
      }
    } catch (e) {
      if (mounted) {
        AppToast.show(context, AppLocalizations.of(context)!.profileCheckInFailure(e.toString()), duration: const Duration(seconds: 2));
      }
    }
  }

  /// 根据连续天数判断并显示奖励通知
  void _showStreakRewardIfNeeded(int consecutive) {
    final l10n = AppLocalizations.of(context)!;
    // 由于签到后连续天数已 +1，检查各里程碑
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: context.colors.primary))
          : Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 用户卡片 + 打卡按钮
                  _buildUserCard(l10n),
                  const SizedBox(height: 12),
                  // 统计数据
                  _buildStatsRow(l10n),
                  const SizedBox(height: 12),
                  // 功能菜单
                  _buildFuncGrid(l10n),
                  const SizedBox(height: 12),
                  // 工具与服务
                  _buildMenuGroup(
                    title: l10n.profileToolsAndServices,
                    context: context,
                    items: [
                      _MenuItem(Icons.lock_outline, l10n.profileMenuPasswordLock),
                      _MenuItem(Icons.monetization_on_outlined, l10n.profileMenuAcCoins),
                      _MenuItem(Icons.label_outline, l10n.tagManage),
                      _MenuItem(Icons.smart_toy_outlined, l10n.profileMenuAiConfig),
                      _MenuItem(Icons.cloud_outlined, l10n.profileMenuDataBackup),
                      _MenuItem(Icons.file_download_outlined, l10n.profileMenuImport),
                      _MenuItem(Icons.file_upload_outlined, l10n.profileMenuExport),
                      _MenuItem(Icons.chat_bubble_outline, l10n.profileMenuFeedback),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 设置
                  _buildMenuGroup(
                    context: context,
                    items: [_MenuItem(Icons.settings_outlined, l10n.profileMenuSettings)],
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
  Widget _buildUserCard(AppLocalizations l10n) {
    final avatarPath = _profile?.avatarPath;
    final nickname = (_profile?.nickname ?? '').isNotEmpty ? _profile!.nickname : l10n.profileDefaultNickname;
    final uid = _profile?.uid ?? '';

    // 检查头像文件是否存在
    final hasValidAvatar = avatarPath != null && File(avatarPath).existsSync();

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.md,
        20,
        AppDimensions.md,
        20,
      ),
      color: context.colors.surface,
      child: Row(
        children: [
          // 头像（点击进入个人资料编辑）
          GestureDetector(
            onTap: () => context.push('/profile/edit').then((_) => _loadData()),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: context.colors.primarySurface,
                    backgroundImage: hasValidAvatar
                        ? FileImage(File(avatarPath))
                        : null,
                    onBackgroundImageError: hasValidAvatar
                        ? (exception, stackTrace) {
                            debugPrint('头像加载失败: $exception');
                          }
                        : null,
                    child: !hasValidAvatar
                        ? Icon(
                            Icons.person_outline,
                            size: 28,
                            color: context.colors.primaryDark,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nickname, style: context.textStyles.h3),
                    const SizedBox(height: 2),
                    Text(
                      l10n.profileUserId(uid),
                      style: context.textStyles.caption.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // 打卡按钮
          GestureDetector(
            onTap: () {
              if (_todayCheckedIn) {
                context.push('/checkin-calendar').then((_) => _loadData());
              } else {
                _checkIn();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _todayCheckedIn
                    ? context.colors.surfaceSecondary
                    : context.colors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _todayCheckedIn
                        ? Icons.check_circle_outline
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: _todayCheckedIn
                        ? context.colors.textTertiary
                        : Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _todayCheckedIn ? l10n.profileCheckedIn : l10n.profileCheckIn,
                    style: context.textStyles.footnote.copyWith(
                      color: _todayCheckedIn
                          ? context.colors.textTertiary
                          : Colors.white,
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
  Widget _buildStatsRow(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          _buildStatItem('$_consecutiveDays', l10n.profileConsecutiveDays),
          _buildStatDivider(),
          _buildStatItem('$_totalCheckInDays', l10n.profileTotalCheckInDays),
          _buildStatDivider(),
          _buildStatItem('$_totalTransactions', l10n.profileTotalTransactions),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: context.textStyles.h2.copyWith(
              color: context.colors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      color: context.colors.separatorOpaque,
    );
  }

  /// 功能网格（5列，无背景色图标）
  Widget _buildFuncGrid(AppLocalizations l10n) {
    final items = [
      _FuncItem(Icons.palette_outlined, l10n.profileFuncTheme),
      _FuncItem(Icons.book_outlined, l10n.profileFuncAccountBooks),
      _FuncItem(Icons.account_balance_wallet_outlined, l10n.profileFuncBudget),
      _FuncItem(Icons.category_outlined, l10n.profileFuncCategories),
      _FuncItem(Icons.bar_chart_outlined, l10n.profileFuncReports),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 0.75,
          mainAxisSpacing: 8,
          crossAxisSpacing: 4,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) =>
            _buildFuncButton(items[index], context),
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
          Icon(item.icon, size: 24, color: context.colors.textPrimary),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: context.textStyles.caption,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
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
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  title,
                  style: context.textStyles.caption.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ),
            ...items.map((item) => _buildMenuItem(item, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    _MenuItem item,
    BuildContext context, {
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onMenuTap(context, item.label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: context.colors.separatorOpaque,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 20,
                color: iconColor ?? context.colors.textPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(item.label, style: context.textStyles.body)),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: context.colors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onFuncTap(BuildContext context, String label) {
    final l10n = AppLocalizations.of(context)!;
    if (label == l10n.profileFuncTheme) {
      _showThemePicker(context, ref);
    } else if (label == l10n.profileFuncAccountBooks) {
      context.push('/account-books');
    } else if (label == l10n.profileFuncBudget) {
      context.push('/budget');
    } else if (label == l10n.profileFuncCategories) {
      context.push('/categories/manage');
    } else if (label == l10n.profileMenuAiConfig) {
      context.push('/settings/llm');
    } else if (label == l10n.profileFuncReports) {
      context.push('/reports');
    } else if (label == l10n.profileMenuDataBackup ||
        label == l10n.profileMenuImport ||
        label == l10n.profileMenuExport ||
        label == l10n.profileMenuFeedback) {
      AppToast.show(context, l10n.profileFeatureComingSoon(label), duration: const Duration(milliseconds: 500));
    }
  }

  void _onMenuTap(BuildContext context, String label) {
    final l10n = AppLocalizations.of(context)!;
    if (label == l10n.profileMenuPasswordLock) {
      context.push('/lock-settings');
    } else if (label == l10n.profileMenuAcCoins) {
      context.push('/ac-coins');
    } else if (label == l10n.tagManage) {
      context.push('/tags/manage');
    } else if (label == l10n.profileMenuAiConfig) {
      context.push('/settings/llm');
    } else if (label == l10n.profileMenuDataBackup ||
        label == l10n.profileMenuImport ||
        label == l10n.profileMenuExport ||
        label == l10n.profileMenuFeedback) {
      AppToast.show(context, l10n.profileFeatureComingSoon(label), duration: const Duration(milliseconds: 500));
    } else if (label == l10n.profileMenuSettings) {
      context.push('/settings');
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
  final l10n = AppLocalizations.of(context)!;
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
            title: Text(l10n.profileThemeLight),
            trailing: current == ThemeMode.light
                ? Icon(Icons.check, color: context.colors.primary)
                : null,
            onTap: () {
              themeProvider.setThemeMode(ThemeMode.light);
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: Text(l10n.profileThemeDark),
            trailing: current == ThemeMode.dark
                ? Icon(Icons.check, color: context.colors.primary)
                : null,
            onTap: () {
              themeProvider.setThemeMode(ThemeMode.dark);
              Navigator.pop(ctx);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_brightness),
            title: Text(l10n.profileThemeSystem),
            trailing: current == ThemeMode.system
                ? Icon(Icons.check, color: context.colors.primary)
                : null,
            onTap: () {
              themeProvider.setThemeMode(ThemeMode.system);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    ),
  );
}
