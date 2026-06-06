import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 我的页面
/// 用户卡片 + 功能按钮 + 菜单列表
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
                  _buildUserCard(),
                  _buildFuncBar(context),
                  const SizedBox(height: 12),
                  _buildMenuGroup(
                    title: '数据与服务',
                    context: context,
                    items: [
                      _MenuItem(Icons.cloud_outlined, '数据备份'),
                      _MenuItem(Icons.file_download_outlined, '账单导入'),
                      _MenuItem(Icons.file_upload_outlined, '账单导出'),
                      _MenuItem(Icons.chat_bubble_outline, '用户反馈'),
                      _MenuItem(Icons.delete_outline, '账本回收站'),
                    ],
                  ),
                  _buildMenuGroup(
                    title: null,
                    context: context,
                    items: [
                      _MenuItem(Icons.smart_toy_outlined, 'AI 服务配置'),
                      _MenuItem(Icons.category_outlined, '分类管理'),
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

  /// 用户卡片
  Widget _buildUserCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppDimensions.md, 24, AppDimensions.md, 24),
      color: AppColors.surface,
      child: Row(
        children: [
          Container(
            width: AppDimensions.avatarSize,
            height: AppDimensions.avatarSize,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.person_outline, size: 28, color: AppColors.primaryDark),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('用户昵称', style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text('记账达人 · 已连续记账 15 天', style: AppTextStyles.footnote),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, size: 24, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  /// 功能按钮栏
  Widget _buildFuncBar(BuildContext context) {
    final items = [
      _FuncItem(Icons.lock_outline, '密码锁', const Color(0xFFE8F5E9)),
      _FuncItem(Icons.palette_outlined, '主题切换', const Color(0xFFE3F2FD)),
      _FuncItem(Icons.book_outlined, '我的账本', const Color(0xFFFFF3E0)),
      _FuncItem(Icons.account_balance_wallet_outlined, '预算管理', const Color(0xFFFFF8E1)),
      _FuncItem(Icons.more_horiz, '更多', AppColors.surfaceSecondary),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) => _buildFuncButton(item, context)).toList(),
      ),
    );
  }

  Widget _buildFuncButton(_FuncItem item, BuildContext context) {
    return InkWell(
      onTap: () => _onFuncTap(context, item.label),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Center(child: Icon(item.icon, size: 22, color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 6),
            Text(item.label, style: AppTextStyles.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  /// 菜单组
  Widget _buildMenuGroup({
    required String? title,
    required BuildContext context,
    required List<_MenuItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.md, 12, AppDimensions.md, 0),
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Text(title, style: AppTextStyles.footnote.copyWith(color: AppColors.textTertiary)),
              ),
            ...items.map((item) => _buildMenuItem(item, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(_MenuItem item, BuildContext context) {
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
              Icon(item.icon, size: 20, color: AppColors.textPrimary),
              const SizedBox(width: 12),
              Expanded(child: Text(item.label, style: AppTextStyles.body)),
              const Icon(Icons.chevron_right, size: 16, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _FuncItem {
  final IconData icon;
  final String label;
  final Color bgColor;
  const _FuncItem(this.icon, this.label, this.bgColor);
}

class _MenuItem {
  final IconData icon;
  final String label;
  const _MenuItem(this.icon, this.label);
}

void _onFuncTap(BuildContext context, String label) {
  switch (label) {
    case '密码锁':
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('密码锁功能即将推出'), behavior: SnackBarBehavior.floating),
      );
      break;
    case '主题切换':
      _showThemePicker(context);
      break;
    case '我的账本':
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('账本功能即将推出'), behavior: SnackBarBehavior.floating),
      );
      break;
    case '预算管理':
      context.push('/budget');
      break;
    case '更多':
      _showMoreOptions(context);
      break;
  }
}

void _onMenuTap(BuildContext context, String label) {
  switch (label) {
    case '设置':
      context.push('/settings');
      break;
    case 'AI 服务配置':
      context.push('/settings/llm');
      break;
    case '分类管理':
      context.push('/categories/manage');
      break;
    case '账单导入':
    case '账单导出':
    case '数据备份':
    case '用户反馈':
    case '账本回收站':
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$label功能即将推出'), behavior: SnackBarBehavior.floating),
      );
      break;
  }
}

/// 展开更多选项
void _showMoreOptions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('更多功能', style: AppTextStyles.h3.copyWith(fontSize: 16)),
            ),
            _moreItem(ctx, Icons.category_outlined, '分类管理', () {
              Navigator.pop(ctx);
              context.push('/categories/manage');
            }),
            _moreItem(ctx, Icons.smart_toy_outlined, 'AI 服务配置', () {
              Navigator.pop(ctx);
              context.push('/settings/llm');
            }),
            _moreItem(ctx, Icons.settings_outlined, '设置', () {
              Navigator.pop(ctx);
              context.push('/settings');
            }),
            _moreItem(ctx, Icons.account_balance_wallet_outlined, '预算管理', () {
              Navigator.pop(ctx);
              context.push('/budget');
            }),
          ],
        ),
      ),
    ),
  );
}

Widget _moreItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
  return ListTile(
    leading: Icon(icon, color: AppColors.textPrimary),
    title: Text(label, style: AppTextStyles.body),
    trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiary),
    onTap: onTap,
  );
}

void _showThemePicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(leading: const Icon(Icons.light_mode), title: const Text('浅色模式'), onTap: () => Navigator.pop(ctx)),
          ListTile(leading: const Icon(Icons.dark_mode), title: const Text('深色模式'), onTap: () => Navigator.pop(ctx)),
          ListTile(leading: const Icon(Icons.settings_brightness), title: const Text('跟随系统'), onTap: () => Navigator.pop(ctx)),
        ],
      ),
    ),
  );
}
