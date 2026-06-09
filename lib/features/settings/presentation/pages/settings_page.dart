import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/locale/app_currency.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../main.dart';

/// 系统设置页
/// 通用/数据/AI设置 + 关于 + 危险区
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _autoBackup = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoBackup = prefs.getBool('autoBackup') ?? true;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    
    final themeProvider = ref.watch(themeProviderOverrideProvider);
    final isDark = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: const Text('系统设置')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // 通用设置
            _buildGroup(
              title: '通用',
              children: [
                _buildLocaleRow(),
                _buildSwitchRow('深色模式', isDark, (v) {
                  themeProvider.setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
                }),
                _buildCurrencyRow(),
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
                          color: context.colors.primarySurface,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        ),
                        child: Center(
                          child: Icon(Icons.account_balance_wallet, color: context.colors.primary, size: 28),
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
              color: context.colors.surface,
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
        activeThumbColor: context.colors.primary,
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
      trailing: Icon(Icons.chevron_right, size: 20, color: context.colors.textTertiary),
      onTap: onTap,
    );
  }

  /// 语言选择行
  Widget _buildLocaleRow() {
    final localeProvider = ref.watch(localeProviderOverrideProvider);
    return _SettingRow(
      label: '语言',
      trailing: Text(localeProvider.localeDisplayName, style: AppTextStyles.footnote),
      onTap: _showLanguagePicker,
    );
  }

  /// 货币选择行
  Widget _buildCurrencyRow() {
    final localeProvider = ref.watch(localeProviderOverrideProvider);
    final c = localeProvider.currency;
    return _SettingRow(
      label: '货币',
      trailing: Text('${c.code} (${c.symbol})', style: AppTextStyles.footnote),
      onTap: _showCurrencyPicker,
    );
  }

  /// 语言选择底部弹窗
  void _showLanguagePicker() {
    final localeProvider = ref.read(localeProviderOverrideProvider);
    final current = localeProvider.locale;

    final options = <_LocaleOption>[
      _LocaleOption(const Locale('zh', 'CN'), '简体中文', '🇨🇳'),
      _LocaleOption(const Locale('zh', 'TW'), '繁體中文', '🇹🇼'),
      _LocaleOption(const Locale('ja'), '日本語', '🇯🇵'),
      _LocaleOption(const Locale('ko'), '한국어', '🇰🇷'),
      _LocaleOption(const Locale('en', 'US'), 'English', '🇺🇸'),
    ];

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('选择语言', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            ...options.map((opt) => ListTile(
              leading: Text(opt.flag, style: const TextStyle(fontSize: 24)),
              title: Text(opt.label),
              trailing: current == opt.locale
                  ? Icon(Icons.check, color: context.colors.primary)
                  : null,
              onTap: () {
                Navigator.pop(ctx);
                localeProvider.setLocale(opt.locale);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// 货币选择底部弹窗
  void _showCurrencyPicker() {
    final localeProvider = ref.read(localeProviderOverrideProvider);
    final current = localeProvider.currency;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('选择货币', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            ...AppCurrency.values.map((currency) => ListTile(
              leading: Text(currency.symbol, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              title: Text('${currency.code} — ${currency.label}'),
              trailing: current == currency
                  ? Icon(Icons.check, color: context.colors.primary)
                  : null,
              onTap: () {
                Navigator.pop(ctx);
                localeProvider.setCurrency(currency);
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerRow(String label, VoidCallback onTap) {
    return _SettingRow(
      label: label,
      labelColor: context.colors.error,
      trailing: Icon(Icons.chevron_right, size: 20, color: context.colors.error),
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
            child: Text('确定', style: TextStyle(color: context.colors.error)),
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
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: context.colors.separatorOpaque, width: 0.5),
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

/// 语言选项数据
class _LocaleOption {
  final Locale locale;
  final String label;
  final String flag;
  const _LocaleOption(this.locale, this.label, this.flag);
}
