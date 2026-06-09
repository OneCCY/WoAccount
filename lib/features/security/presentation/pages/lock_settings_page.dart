import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:wo_account/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.securityLockSettings)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: Text(l10n.securityLockSettings)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // 启用/关闭密码锁
            _buildSection(
              children: [
                _buildSwitchItem(
                  icon: Icons.lock_outline,
                  title: l10n.securityEnableLock,
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
                title: l10n.securityUnlockMethods,
                children: [
                  _buildLockTypeCheckbox(
                    icon: Icons.pin_outlined,
                    title: l10n.securityPinCode,
                    subtitle: l10n.securityPinCodeDesc,
                    type: 'pin',
                  ),
                  if (_biometricAvailable)
                    _buildLockTypeCheckbox(
                      icon: Icons.fingerprint,
                      title: l10n.securityBiometric,
                      subtitle: l10n.securityBiometricDesc,
                      type: 'biometric',
                    ),
                  _buildLockTypeCheckbox(
                    icon: Icons.gesture_outlined,
                    title: l10n.securityPatternLock,
                    subtitle: l10n.securityPatternLockDesc,
                    type: 'pattern',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 提示信息
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
                child: Text(
                  l10n.securityLockHint,
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
                  localizedReason: AppLocalizations.of(context)!.securityBiometricVerify,
                  options: const AuthenticationOptions(
                    stickyAuth: true,
                    biometricOnly: true,
                  ),
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.securityBiometricFail(e.toString())), duration: const Duration(milliseconds: 500)),
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
