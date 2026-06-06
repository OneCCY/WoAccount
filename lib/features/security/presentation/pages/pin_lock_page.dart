import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// PIN 密码锁页面
/// 支持设置模式（设置新密码）和验证模式（输入密码解锁）
class PinLockPage extends StatefulWidget {
  final String mode; // 'setup' or 'verify'
  final VoidCallback? onAuthenticated;

  const PinLockPage({super.key, required this.mode, this.onAuthenticated});

  @override
  State<PinLockPage> createState() => _PinLockPageState();
}

class _PinLockPageState extends State<PinLockPage> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String _error = '';
  static const int _pinLength = 4;

  @override
  Widget build(BuildContext context) {
    final isSetup = widget.mode == 'setup';
    final title = isSetup
        ? (_isConfirming ? '请再次输入新密码' : '设置四位数字密码')
        : '请输入密码解锁';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isSetup ? '设置密码锁' : '解锁'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),

            // 标题
            Text(title, style: AppTextStyles.h3.copyWith(fontSize: 18)),
            const SizedBox(height: 32),

            // PIN 显示圆点
            _buildPinDots(),
            const SizedBox(height: 16),

            // 错误提示
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _error,
                  style: AppTextStyles.caption.copyWith(color: AppColors.error),
                  textAlign: TextAlign.center,
                ),
              ),

            const Spacer(flex: 1),

            // 数字键盘
            _buildNumpad(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// PIN 圆点显示
  Widget _buildPinDots() {
    final currentPin = _isConfirming ? _confirmPin : _pin;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pinLength, (index) {
        final filled = index < currentPin.length;
        return Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? AppColors.primary : Colors.transparent,
            border: Border.all(
              color: _error.isNotEmpty ? AppColors.error : AppColors.textTertiary,
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  /// 数字键盘
  Widget _buildNumpad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          _buildNumpadRow(['1', '2', '3']),
          const SizedBox(height: 12),
          _buildNumpadRow(['4', '5', '6']),
          const SizedBox(height: 12),
          _buildNumpadRow(['7', '8', '9']),
          const SizedBox(height: 12),
          _buildNumpadRow(['', '0', 'backspace']),
        ],
      ),
    );
  }

  Widget _buildNumpadRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildNumpadKey(key)).toList(),
    );
  }

  Widget _buildNumpadKey(String key) {
    if (key.isEmpty) return const SizedBox(width: 72, height: 72);

    final isBackspace = key == 'backspace';

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (isBackspace) {
          _onBackspace();
        } else {
          _onDigitInput(key);
        }
      },
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: isBackspace ? Colors.transparent : AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: isBackspace
              ? const Icon(Icons.backspace_outlined, size: 24, color: AppColors.textSecondary)
              : Text(
                  key,
                  style: AppTextStyles.h3.copyWith(fontSize: 28),
                ),
        ),
      ),
    );
  }

  void _onDigitInput(String digit) {
    setState(() => _error = '');

    if (_isConfirming) {
      if (_confirmPin.length < _pinLength) {
        setState(() => _confirmPin += digit);

        if (_confirmPin.length == _pinLength) {
          _verifyConfirmPin();
        }
      }
    } else {
      if (_pin.length < _pinLength) {
        setState(() => _pin += digit);

        if (_pin.length == _pinLength) {
          if (widget.mode == 'setup') {
            // 设置模式：进入确认
            setState(() {
              _isConfirming = true;
              _confirmPin = '';
            });
          } else {
            // 验证模式：校验密码
            _verifyPin();
          }
        }
      }
    }
  }

  void _onBackspace() {
    if (_isConfirming) {
      if (_confirmPin.isNotEmpty) {
        setState(() => _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1));
      }
    } else {
      if (_pin.isNotEmpty) {
        setState(() => _pin = _pin.substring(0, _pin.length - 1));
      }
    }
  }

  Future<void> _verifyPin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('lock_pin') ?? '';

    if (_pin == savedPin) {
      // 验证成功
      if (widget.onAuthenticated != null) {
        widget.onAuthenticated!();
      } else if (mounted) {
        Navigator.of(context).pop(true);
      }
    } else {
      setState(() {
        _error = '密码错误，请重试';
        _pin = '';
      });
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _verifyConfirmPin() async {
    if (_pin == _confirmPin) {
      // 两次输入一致，保存密码
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lock_pin', _pin);
      await prefs.setBool('lock_enabled', true);
      await prefs.setString('lock_type', 'pin');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('密码设置成功'), duration: Duration(milliseconds: 500)),
        );
        Navigator.of(context).pop(true);
      }
    } else {
      setState(() {
        _error = '两次输入不一致，请重新设置';
        _pin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
      HapticFeedback.heavyImpact();
    }
  }
}
