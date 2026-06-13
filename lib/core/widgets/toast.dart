import 'dart:async';
import 'package:flutter/material.dart';

/// 全局消息提醒工具
/// - 顶部弹出
/// - 绿色背景 + 柔和圆角
/// - 内置防抖，防止短时间内重复弹出
class AppToast {
  static Timer? _debounceTimer;
  static String? _lastMessage;
  static DateTime? _lastShowTime;

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
    _lastMessage = message;
    _lastShowTime = now;

    // 移除当前 SnackBar
    ScaffoldMessenger.of(context).clearSnackBars();

    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF4CAF50),
      duration: duration,
      margin: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    _debounceTimer = Timer(duration, () {
      _lastMessage = null;
    });
  }
}
