import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../config/di/ai_providers.dart';
import '../../../features/text_ai/data/services/platform_stt_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../voice/voice_recording_overlay.dart';
import '../toast.dart';

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
        sttService: ref.read(platformSttServiceProvider),
      ),
    );
  }

  Future<void> _handleVoiceResult(BuildContext context, VoiceResult result) async {
    if (result.action == VoiceResultAction.cancel) return;
    if (result.filePath == null) return;

    final orchestrator = ref.read(voiceTranscriptionOrchestratorProvider);

    try {
      final transcription = await orchestrator.transcribe(
        audioPath: result.filePath!,
        platformText: result.platformText,
      );
      if (!context.mounted) return;

      if (result.action == VoiceResultAction.transcribe) {
        context.go('/', extra: {'transcribedText': transcription.mergedText});
      } else {
        context.go('/', extra: {'transcription': transcription});
      }
    } catch (e) {
      if (!context.mounted) return;
      AppToast.show(context, AppLocalizations.of(context)!.homePageRecordFailed(e.toString()));
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
  final PlatformSttService? sttService;

  const _BottomBarWithFloatingButton({
    required this.currentIndex,
    required this.onNavTap,
    required this.onVoiceResult,
    this.sttService,
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
                      // 中：记账（麦克风）
                      _NavItem(
                        icon: Icons.mic,
                        activeIcon: Icons.mic,
                        label: AppLocalizations.of(context)!.navRecord,
                        isActive: currentIndex == 1,
                        onTap: () => onNavTap(context, 1),
                        onLongPress: currentIndex == 1
                            ? () async {
                                final result = await VoiceRecordingOverlay.show(context, sttService: sttService);
                                if (result != null && context.mounted) {
                                  onVoiceResult(context, result);
                                }
                              }
                            : null,
                      ),
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
        ],
      ),
    );
  }
}

/// 底部导航项（支持长按录音）
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? context.colors.primary : context.colors.textTertiary;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isActive ? activeIcon : icon, size: 28, color: color),
                const SizedBox(height: 5),
                Text(label, style: AppTextStyles.navLabel.copyWith(color: color, fontSize: 13)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
