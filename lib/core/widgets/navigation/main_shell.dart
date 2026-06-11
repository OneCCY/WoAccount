import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../config/di/ai_providers.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../voice/voice_recording_overlay.dart';

/// 底部导航 Shell
/// 左: 账单 | 中: 浮动记账按钮 | 右: 我的
class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return Scaffold(
      body: widget.child,
      // 使用 bottomNavigationBar 放置导航栏 + 浮动按钮
      bottomNavigationBar: _BottomBarWithFloatingButton(
        currentIndex: currentIndex,
        onNavTap: _onNavTap,
        onVoiceResult: _handleVoiceResult,
      ),
    );
  }

  Future<void> _handleVoiceResult(BuildContext context, VoiceResult result) async {
    if (result.action == VoiceResultAction.cancel) return;

    final provider = await ref.read(llmRepositoryProvider).getActiveProvider();
    if (!context.mounted) return;

    if (provider == null || !provider.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.homePageAiNotConfigured), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final pipeline = ref.read(transactionPipelineProvider);

    if (result.action == VoiceResultAction.transcribe && result.filePath != null) {
      try {
        final text = await pipeline.transcribeOnly(
          audioTempPath: result.filePath!,
          provider: provider,
        );
        if (!context.mounted) return;
        context.go('/', extra: {'transcribedText': text});
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.homePageRecordFailed(e.toString())), behavior: SnackBarBehavior.floating),
        );
      }
    } else if (result.action == VoiceResultAction.send && result.filePath != null) {
      context.go('/', extra: {'voicePath': result.filePath});
    }
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/transactions')) return 0;
    if (location == '/') return 1;
    if (location.startsWith('/profile')) return 2;
    return 1;
  }

  void _onNavTap(BuildContext context, int index) {
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

/// 底部导航栏 + 浮动记账按钮
class _BottomBarWithFloatingButton extends StatelessWidget {
  final int currentIndex;
  final void Function(BuildContext, int) onNavTap;
  final void Function(BuildContext, VoiceResult) onVoiceResult;

  const _BottomBarWithFloatingButton({
    required this.currentIndex,
    required this.onNavTap,
    required this.onVoiceResult,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110, // 导航栏高度 + 浮动按钮凸出部分
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 底部导航栏（只有左/右两个按钮）
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
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
                        onTap: () => onNavTap(context, 0),
                      ),
                      // 中间留空给浮动按钮
                      const Expanded(child: SizedBox()),
                      // 右：我的
                      _NavItem(
                        icon: Icons.person_outline,
                        activeIcon: Icons.person,
                        label: AppLocalizations.of(context)!.navProfile,
                        isActive: currentIndex == 2,
                        onTap: () => onNavTap(context, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 浮动记账按钮（居中，向上凸出）
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: _FloatingRecordButton(
                isActive: currentIndex == 1,
                onTap: () => onNavTap(context, 1),
                onVoiceResult: onVoiceResult,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 浮动记账按钮（支持长按录音）
class _FloatingRecordButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final void Function(BuildContext, VoiceResult) onVoiceResult;

  const _FloatingRecordButton({
    required this.isActive,
    required this.onTap,
    required this.onVoiceResult,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPressStart: (_) async {
        final result = await VoiceRecordingOverlay.show(context);
        if (result != null && context.mounted) {
          onVoiceResult(context, result);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 64,
        height: 64,
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
              color: context.colors.primary.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mic, size: 24, color: context.colors.textOnPrimary),
            Text(
              AppLocalizations.of(context)!.navRecord,
              style: TextStyle(fontSize: 10, color: context.colors.textOnPrimary, fontWeight: FontWeight.w600, height: 1),
            ),
          ],
        ),
      ),
    );
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
