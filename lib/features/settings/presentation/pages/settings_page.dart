import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 系统设置页
/// 通用/数据/AI设置 + 关于 + 危险区
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _autoBackup = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _darkMode = prefs.getBool('darkMode') ?? false;
      _autoBackup = prefs.getBool('autoBackup') ?? true;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('系统设置')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // 通用设置
            _buildGroup(
              title: '通用',
              children: [
                _buildInfoRow('语言', '简体中文'),
                _buildSwitchRow('深色模式', _darkMode, (v) {
                  setState(() => _darkMode = v);
                  _saveBool('darkMode', v);
                }),
                _buildInfoRow('货币', 'CNY (¥)'),
              ],
            ),

            // 数据设置
            _buildGroup(
              title: '数据',
              children: [
                _buildSwitchRow('自动备份', _autoBackup, (v) {
                  setState(() => _autoBackup = v);
                  _saveBool('autoBackup', v);
                }),
                _buildInfoRow('备份频率', '每天'),
                _buildNavRow('恢复数据', () {
                  // TODO: 恢复数据
                }),
              ],
            ),

            // 关于
            _buildGroup(
              title: '关于',
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: const Center(
                          child: Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 28),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('WoAccount', style: AppTextStyles.h3),
                          const SizedBox(height: 2),
                          Text('v1.0.0 (Build 1)', style: AppTextStyles.caption),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 危险区
            _buildGroup(
              title: '危险区',
              children: [
                _buildDangerRow('清除所有数据', () {
                  _showConfirmDialog('清除所有数据', '此操作不可恢复，确定要清除所有数据吗？');
                }),
                _buildDangerRow('注销账号', () {
                  _showConfirmDialog('注销账号', '注销后所有数据将被永久删除，确定要继续吗？');
                }),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGroup({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(title, style: AppTextStyles.footnote),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return _SettingRow(
      label: label,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return _SettingRow(
      label: label,
      trailing: Text(value, style: AppTextStyles.footnote),
    );
  }

  Widget _buildNavRow(String label, VoidCallback onTap) {
    return _SettingRow(
      label: label,
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiary),
      onTap: onTap,
    );
  }

  Widget _buildDangerRow(String label, VoidCallback onTap) {
    return _SettingRow(
      label: label,
      labelColor: AppColors.error,
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.error),
      onTap: onTap,
    );
  }

  void _showConfirmDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('确定', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final Widget trailing;
  final VoidCallback? onTap;
  final Color? labelColor;

  const _SettingRow({
    required this.label,
    required this.trailing,
    this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.separatorOpaque, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body.copyWith(color: labelColor),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
