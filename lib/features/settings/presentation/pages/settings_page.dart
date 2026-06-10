import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wo_account/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    final themeProvider = ref.watch(themeProviderOverrideProvider);
    final isDark = themeProvider.themeMode == ThemeMode.dark ||
        (themeProvider.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // 通用设置
            _buildGroup(
              title: l10n.settingsGeneral,
              children: [
                _buildLocaleRow(),
                _buildSwitchRow(l10n.settingsDarkMode, isDark, (v) {
                  themeProvider.setThemeMode(v ? ThemeMode.dark : ThemeMode.light);
                }),
                _buildCurrencyRow(),
              ],
            ),

            // 数据设置
            _buildGroup(
              title: l10n.settingsData,
              children: [
                _buildSwitchRow(l10n.settingsAutoBackup, _autoBackup, (v) {
                  setState(() => _autoBackup = v);
                  _saveBool('autoBackup', v);
                }),
                _buildInfoRow(l10n.settingsBackupFrequency, l10n.settingsBackupDaily),
                _buildNavRow(l10n.settingsRestoreData, () {
                  // TODO: 恢复数据
                }),
              ],
            ),

            // 关于
            _buildGroup(
              title: l10n.settingsAbout,
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
              title: l10n.settingsDangerZone,
              children: [
                _buildDangerRow(l10n.settingsClearData, () {
                  _showConfirmDialog(l10n.settingsClearData, l10n.settingsClearConfirm);
                }),
                _buildDangerRow(l10n.settingsDeleteAccount, () {
                  _showConfirmDialog(l10n.settingsDeleteAccount, l10n.settingsDeleteConfirm);
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
      label: AppLocalizations.of(context)!.settingsLanguage,
      trailing: Text(localeProvider.localeDisplayName, style: AppTextStyles.footnote),
      onTap: _showLanguagePicker,
    );
  }

  /// 货币选择行
  Widget _buildCurrencyRow() {
    final localeProvider = ref.watch(localeProviderOverrideProvider);
    final c = localeProvider.currency;
    return _SettingRow(
      label: AppLocalizations.of(context)!.settingsCurrency,
      trailing: Text('${c.code} (${c.symbol})', style: AppTextStyles.footnote),
      onTap: _showCurrencyPicker,
    );
  }

  /// 语言选择底部弹窗
  void _showLanguagePicker() {
    final l10n = AppLocalizations.of(context)!;
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.settingsSelectLanguage, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = ref.read(localeProviderOverrideProvider);
    final current = localeProvider.currency;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.settingsSelectCurrency, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            ...AppCurrency.values.map((currency) => ListTile(
              leading: Text(currency.symbol, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              title: Text('${currency.code} — ${currency.getLocalizedName(l10n)}'),
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
            child: Text(AppLocalizations.of(context)!.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context)!.commonConfirm, style: TextStyle(color: context.colors.error)),
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
