import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// 底部导航 Shell
/// 左: 账单 | 中: 记账（突出大按钮） | 右: 我的
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(
            top: BorderSide(color: context.colors.separatorOpaque, width: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0D000000),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                // 左：账单
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  label: AppLocalizations.of(context)!.navTransactions,
                  isActive: currentIndex == 0,
                  onTap: () => _onTap(context, 0),
                ),

                // 中：记账按钮（突出）
                _RecordButton(
                  isActive: currentIndex == 1,
                  onTap: () => _onTap(context, 1),
                ),

                // 右：我的
                _NavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: AppLocalizations.of(context)!.navProfile,
                  isActive: currentIndex == 2,
                  onTap: () => _onTap(context, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/transactions')) return 0;
    if (location == '/') return 1;
    if (location.startsWith('/profile')) return 2;
    return 1;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/transactions');
      case 1:
        context.go('/');
      case 2:
        context.go('/profile');
    }
  }
}

/// 底部导航项
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? context.colors.primary : context.colors.textTertiary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.navLabel.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

/// 中间突出的记账按钮
class _RecordButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _RecordButton({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 突出的圆形按钮
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isActive
                      ? [context.colors.primary, const Color(0xFF2E7D32)]
                      : [const Color(0xFF66BB6A), const Color(0xFF43A047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic, size: 24, color: context.colors.textOnPrimary),
                  Text(AppLocalizations.of(context)!.navRecord, style: TextStyle(fontSize: 9, color: context.colors.textOnPrimary, fontWeight: FontWeight.w600, height: 1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
