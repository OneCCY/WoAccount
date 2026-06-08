import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 密码锁设置页
/// 支持多选解锁方式：指纹、图案、PIN
class LockSettingsPage extends StatefulWidget {
  const LockSettingsPage({super.key});

  @override
  State<LockSettingsPage> createState() => _LockSettingsPageState();
}

class _LockSettingsPageState extends State<LockSettingsPage> {
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _lockEnabled = false;
  Set<String> _enabledTypes = {}; // 多选：pin, pattern, biometric
  bool _biometricAvailable = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkBiometric();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final types = prefs.getStringList('lock_types') ?? [];
    setState(() {
      _lockEnabled = prefs.getBool('lock_enabled') ?? false;
      _enabledTypes = types.toSet();
      _isLoading = false;
    });
  }

  Future<void> _checkBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      setState(() {
        _biometricAvailable = canCheck && isDeviceSupported && availableBiometrics.isNotEmpty;
      });
    } catch (_) {
      setState(() => _biometricAvailable = false);
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('lock_enabled', _lockEnabled);
    await prefs.setStringList('lock_types', _enabledTypes.toList());
    // 保持向后兼容
    if (_enabledTypes.isNotEmpty) {
      await prefs.setString('lock_type', _enabledTypes.first);
    } else {
      await prefs.setString('lock_type', 'none');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('密码锁设置')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: const Text('密码锁设置')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // 启用/关闭密码锁
            _buildSection(
              children: [
                _buildSwitchItem(
                  icon: Icons.lock_outline,
                  title: '启用密码锁',
                  value: _lockEnabled,
                  onChanged: (v) {
                    setState(() {
                      _lockEnabled = v;
                      if (!v) _enabledTypes.clear();
                    });
                    _saveSettings();
                  },
                ),
              ],
            ),

            if (_lockEnabled) ...[
              const SizedBox(height: 16),

              // 解锁方式选择（多选）
              _buildSection(
                title: '解锁方式（可多选）',
                children: [
                  _buildLockTypeCheckbox(
                    icon: Icons.pin_outlined,
                    title: '数字密码',
                    subtitle: '四位数字密码解锁',
                    type: 'pin',
                  ),
                  if (_biometricAvailable)
                    _buildLockTypeCheckbox(
                      icon: Icons.fingerprint,
                      title: '指纹解锁',
                      subtitle: '使用设备指纹快速解锁',
                      type: 'biometric',
                    ),
                  _buildLockTypeCheckbox(
                    icon: Icons.gesture_outlined,
                    title: '图案解锁',
                    subtitle: '绘制图案解锁',
                    type: 'pattern',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 提示信息
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                child: Text(
                  '勾选多种解锁方式后，解锁界面会出现切换按钮。指纹解锁需要设备支持生物识别功能。',
                  style: context.textStyles.caption.copyWith(color: context.colors.textTertiary),
                ),
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({String? title, required List<Widget> children}) {
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
                child: Text(title, style: context.textStyles.footnote.copyWith(color: context.colors.textTertiary)),
              ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: context.colors.textPrimary),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: context.textStyles.body)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: context.colors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildLockTypeCheckbox({
    required IconData icon,
    required String title,
    required String subtitle,
    required String type,
  }) {
    final isSelected = _enabledTypes.contains(type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (isSelected) {
            // 取消选中
            setState(() => _enabledTypes.remove(type));
            _saveSettings();
          } else {
            // 选中 - 需要先设置
            bool success = false;
            if (type == 'pin') {
              final result = await context.push('/pin-lock', extra: {'mode': 'setup'});
              success = result == true;
            } else if (type == 'pattern') {
              final result = await context.push('/pattern-lock', extra: {'mode': 'setup'});
              success = result == true;
            } else if (type == 'biometric') {
              try {
                success = await _localAuth.authenticate(
                  localizedReason: '验证指纹以启用指纹解锁',
                  options: const AuthenticationOptions(
                    stickyAuth: true,
                    biometricOnly: true,
                  ),
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('指纹验证失败: $e'), duration: const Duration(milliseconds: 500)),
                  );
                }
              }
            }
            if (success) {
              setState(() => _enabledTypes.add(type));
              _saveSettings();
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: context.colors.separatorOpaque, width: 0.5)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: context.colors.textPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: context.textStyles.body),
                    const SizedBox(height: 2),
                    Text(subtitle, style: context.textStyles.caption.copyWith(color: context.colors.textTertiary)),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                size: 22,
                color: isSelected ? context.colors.primary : context.colors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
