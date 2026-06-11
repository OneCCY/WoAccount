import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../config/di/ai_providers.dart';
import '../../../core/ai/llm_error_resolver.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

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

  const _BottomBarWithFloatingButton({
    required this.currentIndex,
    required this.onNavTap,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 浮动记账按钮（支持长按录音）
class _FloatingRecordButton extends ConsumerStatefulWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _FloatingRecordButton({required this.isActive, required this.onTap});

  @override
  ConsumerState<_FloatingRecordButton> createState() => _FloatingRecordButtonState();
}

class _FloatingRecordButtonState extends ConsumerState<_FloatingRecordButton> {
  final _audioRecorder = AudioRecorder();

  bool _isRecording = false;
  bool _isCancelled = false;
  bool _isTranscribeOnly = false;
  Offset _dragOffset = Offset.zero;
  DateTime? _recordStartTime;

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _onVoiceStart(LongPressStartDetails details) async {
    HapticFeedback.heavyImpact();

    // 先设置录音状态（视觉反馈）
    setState(() {
      _isRecording = true;
      _isCancelled = false;
      _isTranscribeOnly = false;
      _dragOffset = Offset.zero;
    });

    // 检查权限（带超时）
    bool hasPermission = false;
    try {
      hasPermission = await _audioRecorder.hasPermission()
          .timeout(const Duration(seconds: 3), onTimeout: () => false);
    } catch (_) {
      hasPermission = false;
    }

    if (!hasPermission) {
      if (mounted) {
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.chatInputMicPermission), behavior: SnackBarBehavior.floating),
        );
      }
      return;
    }

    _recordStartTime = DateTime.now();

    try {
      // 生成明确的临时文件路径（Android 16 不支持空路径）
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: tempPath,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.chatInputMicPermission), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  void _onVoiceUpdate(LongPressMoveUpdateDetails details) {
    setState(() => _dragOffset = details.offsetFromOrigin);

    // 左滑取消
    if (_dragOffset.dx < -50 && _dragOffset.dy < -20) {
      if (!_isCancelled) {
        HapticFeedback.heavyImpact();
        setState(() {
          _isCancelled = true;
          _isTranscribeOnly = false;
        });
      }
    }
    // 右滑仅转文字
    else if (_dragOffset.dx > 50 && _dragOffset.dy < -20) {
      if (!_isTranscribeOnly) {
        HapticFeedback.heavyImpact();
        setState(() {
          _isTranscribeOnly = true;
          _isCancelled = false;
        });
      }
    }
    // 回到中间
    else if (_isCancelled || _isTranscribeOnly) {
      setState(() {
        _isCancelled = false;
        _isTranscribeOnly = false;
      });
    }
  }

  Future<void> _onVoiceEnd(LongPressEndDetails details) async {
    if (!_isRecording) return;

    final path = await _audioRecorder.stop();
    final wasCancelled = _isCancelled;
    final wasTranscribeOnly = _isTranscribeOnly;

    setState(() {
      _isRecording = false;
      _isCancelled = false;
      _isTranscribeOnly = false;
      _dragOffset = Offset.zero;
    });

    if (wasCancelled || path == null || path.isEmpty) return;

    // 检查最小时长
    final duration = _recordStartTime != null
        ? DateTime.now().difference(_recordStartTime!)
        : Duration.zero;
    if (duration.inMilliseconds < 500) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.chatInputRecordShort), behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 800)),
        );
      }
      return;
    }

    HapticFeedback.lightImpact();

    // 处理录音结果
    await _handleVoiceResult(path, wasTranscribeOnly);
  }

  Future<void> _handleVoiceResult(String filePath, bool transcribeOnly) async {
    final provider = await ref.read(llmRepositoryProvider).getActiveProvider();
    if (!mounted) return;

    if (provider == null || !provider.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.homePageAiNotConfigured), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final pipeline = ref.read(transactionPipelineProvider);

    if (transcribeOnly) {
      // 仅转文字 → 跳转 AI 聊天页并传入文本
      try {
        final text = await pipeline.transcribeOnly(
          audioTempPath: filePath,
          provider: provider,
        );
        if (!mounted) return;
        // 跳转到 AI 聊天页，传递转写文本
        context.go('/', extra: {'transcribedText': text});
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.homePageRecordFailed(resolveLlmError(e, AppLocalizations.of(context)!))), behavior: SnackBarBehavior.floating),
        );
      }
    } else {
      // 完整管线 → 跳转 AI 聊天页并传入语音路径
      context.go('/', extra: {'voicePath': filePath});
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onLongPressStart: _onVoiceStart,
      onLongPressMoveUpdate: _onVoiceUpdate,
      onLongPressEnd: _onVoiceEnd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: _isRecording ? 72 : 64,
        height: _isRecording ? 72 : 64,
        decoration: BoxDecoration(
          gradient: _isRecording
              ? LinearGradient(
                  colors: _isCancelled
                      ? [context.colors.error, context.colors.error.withValues(alpha: 0.8)]
                      : _isTranscribeOnly
                          ? [const Color(0xFF2196F3), const Color(0xFF1565C0)]
                          : [context.colors.primary, const Color(0xFF2E7D32)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: widget.isActive
                      ? [context.colors.primary, const Color(0xFF2E7D32)]
                      : [const Color(0xFF66BB6A), const Color(0xFF43A047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (_isRecording
                      ? (_isCancelled ? context.colors.error : _isTranscribeOnly ? const Color(0xFF2196F3) : context.colors.primary)
                      : context.colors.primary)
                  .withValues(alpha: 0.4),
              blurRadius: _isRecording ? 16 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isRecording
                  ? (_isCancelled ? Icons.close : _isTranscribeOnly ? Icons.text_snippet : Icons.mic)
                  : Icons.mic,
              size: _isRecording ? 28 : 24,
              color: context.colors.textOnPrimary,
            ),
            if (!_isRecording)
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
