import 'dart:async';
import 'package:flutter/material.dart';

/// 全局消息提醒工具
/// - 顶部弹出（基于 Overlay）
/// - 绿色背景 + 柔和圆角
/// - 内置防抖，防止短时间内重复弹出
class AppToast {
  static Timer? _debounceTimer;
  static Timer? _dismissTimer;
  static String? _lastMessage;
  static DateTime? _lastShowTime;
  static OverlayEntry? _currentEntry;

  /// 显示一条顶部消息提醒
  ///
  /// [message] 消息内容
  /// [duration] 显示时长，默认 1.5 秒
  /// [debounceMs] 防抖间隔（毫秒），同一条消息在此间隔内不会重复弹出
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 1500),
    int debounceMs = 1500,
  }) {
    final now = DateTime.now();

    // 防抖：同一条消息在 debounceMs 内不重复弹出
    if (_lastMessage == message &&
        _lastShowTime != null &&
        now.difference(_lastShowTime!).inMilliseconds < debounceMs) {
      return;
    }

    _debounceTimer?.cancel();
    _dismissTimer?.cancel();
    _lastMessage = message;
    _lastShowTime = now;

    // 移除当前弹窗
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        topPadding: topPadding,
        onDismissed: () {
          if (entry == _currentEntry) {
            entry.remove();
            _currentEntry = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);

    // 自动消失
    _dismissTimer = Timer(duration, () {
      if (entry == _currentEntry) {
        entry.remove();
        _currentEntry = null;
      }
    });

    _debounceTimer = Timer(duration, () {
      _lastMessage = null;
    });
  }
}

/// 顶部 Toast 动画组件
class _ToastWidget extends StatefulWidget {
  final String message;
  final double topPadding;
  final VoidCallback onDismissed;

  const _ToastWidget({
    required this.message,
    required this.topPadding,
    required this.onDismissed,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.topPadding + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                widget.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
