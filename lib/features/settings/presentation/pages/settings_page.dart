import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:intl/intl.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/widgets/toast.dart';
import '../../../../core/locale/app_currency.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../main.dart';
import '../../../profile/data/services/backup_service.dart';

/// 系统设置页
/// 通用/数据/AI设置 + 关于 + 危险区
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _autoBackup = true;
  BackupFrequency _backupFrequency = BackupFrequency.daily;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final backupService = ref.read(backupServiceProvider);
    final autoBackup = await backupService.isAutoBackupEnabled();
    final frequency = await backupService.getBackupFrequency();
    if (mounted) {
      setState(() {
        _autoBackup = autoBackup;
        _backupFrequency = frequency;
      });
    }
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
                  ref.read(backupServiceProvider).setAutoBackup(v);
                }),
                _buildNavRow(
                  l10n.settingsBackupFrequency,
                  _frequencyLabel(l10n),
                  () => _showFrequencyPicker(l10n),
                ),
                _buildNavRow(l10n.settingsRestoreData, null, () {
                  _showRestoreDialog(l10n);
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

  String _frequencyLabel(AppLocalizations l10n) {
    switch (_backupFrequency) {
      case BackupFrequency.daily:
        return l10n.settingsBackupDaily;
      case BackupFrequency.weekly:
        return l10n.settingsBackupWeekly;
      case BackupFrequency.monthly:
        return l10n.settingsBackupMonthly;
      case BackupFrequency.manual:
        return l10n.settingsBackupManual;
    }
  }

  void _showFrequencyPicker(AppLocalizations l10n) {
    final options = <(BackupFrequency, String)>[
      (BackupFrequency.daily, l10n.settingsBackupDaily),
      (BackupFrequency.weekly, l10n.settingsBackupWeekly),
      (BackupFrequency.monthly, l10n.settingsBackupMonthly),
      (BackupFrequency.manual, l10n.settingsBackupManual),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: context.colors.textTertiary.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(l10n.settingsBackupFrequency, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              ...options.map((opt) => ListTile(
                title: Text(opt.$2),
                trailing: _backupFrequency == opt.$1
                    ? Icon(Icons.check, color: context.colors.primary)
                    : null,
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _backupFrequency = opt.$1);
                  ref.read(backupServiceProvider).setBackupFrequency(opt.$1);
                },
              )),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showRestoreDialog(AppLocalizations l10n) async {
    final backupService = ref.read(backupServiceProvider);
    final backups = await backupService.listBackups();

    if (!mounted) return;

    if (backups.isEmpty) {
      AppToast.show(context, l10n.settingsNoBackupFound);
      return;
    }

    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.settingsRestoreData),
        children: backups.take(10).map((f) {
          final name = f.path.split('/').last.split('\\').last;
          final size = (f.statSync().size / 1024).toStringAsFixed(1);
          final date = DateFormat('yyyy-MM-dd HH:mm').format(f.statSync().modified);
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, f.path),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('$date · ${size}KB', style: context.textStyles.caption),
              ],
            ),
          );
        }).toList(),
      ),
    );
    if (selected == null || !mounted) return;

    // 确认恢复
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsRestoreData),
        content: Text(l10n.settingsRestoreConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonConfirm, style: TextStyle(color: context.colors.warning)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await backupService.restoreFromBackup(selected);
      if (mounted) AppToast.show(context, l10n.settingsRestoreSuccess);
    } catch (e) {
      if (mounted) AppToast.show(context, l10n.settingsRestoreFailed(e.toString()));
    }
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

  Widget _buildNavRow(String label, String? value, VoidCallback onTap) {
    return _SettingRow(
      label: label,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(value, style: AppTextStyles.footnote),
          Icon(Icons.chevron_right, size: 20, color: context.colors.textTertiary),
        ],
      ),
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
    final isClearData = title == AppLocalizations.of(context)!.settingsClearData;
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
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (isClearData) {
                await _clearCurrentBookData();
              } else {
                await _deleteAccountData();
              }
            },
            child: Text(AppLocalizations.of(context)!.commonConfirm, style: TextStyle(color: context.colors.error)),
          ),
        ],
      ),
    );
  }

  /// 清空当前账本数据
  Future<void> _clearCurrentBookData() async {
    try {
      final bookRepo = ref.read(accountBookRepositoryProvider);
      final bookId = ref.read(currentBookProvider);
      await bookRepo.clearData(bookId);
      if (mounted) {
        AppToast.show(context, AppLocalizations.of(context)!.settingsClearDataSuccess);
      }
    } catch (e) {
      debugPrint('清空数据失败: $e');
    }
  }

  /// 删除账户数据（清空所有账本 + 重置用户资料）
  Future<void> _deleteAccountData() async {
    try {
      final bookRepo = ref.read(accountBookRepositoryProvider);
      final profileRepo = ref.read(userProfileRepositoryProvider);

      // 清空所有账本数据
      final books = await bookRepo.getAll();
      for (final book in books) {
        await bookRepo.clearData(book.id);
      }

      // 重置用户资料
      await profileRepo.updateProfile(const UserProfilesCompanion(
        nickname: Value(''),
        avatarPath: Value(null),
        gender: Value(null),
        email: Value(null),
        phone: Value(null),
      ));

      if (mounted) {
        AppToast.show(context, AppLocalizations.of(context)!.settingsDeleteAccountSuccess);
      }
    } catch (e) {
      debugPrint('删除账户数据失败: $e');
    }
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
