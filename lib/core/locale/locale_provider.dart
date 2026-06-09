import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_currency.dart';

/// 全局 LocaleProvider 的 Riverpod Provider
final localeProviderOverrideProvider = ChangeNotifierProvider<LocaleProvider>((ref) {
  throw UnimplementedError('必须在 ProviderScope 中通过 override 提供');
});

/// 语言和货币管理（与 ThemeProvider 同模式）
class LocaleProvider extends ChangeNotifier {
  static const _localeKey = 'app_locale';
  static const _currencyKey = 'app_currency';

  Locale _locale = const Locale('zh', 'CN');
  AppCurrency _currency = AppCurrency.cny;

  Locale get locale => _locale;
  AppCurrency get currency => _currency;

  /// 当前语言的显示名称
  String get localeDisplayName {
    switch (_locale.languageCode) {
      case 'zh':
        return _locale.countryCode == 'TW' ? '繁體中文' : '简体中文';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'en':
        return 'English';
      default:
        return '简体中文';
    }
  }

  /// 从本地存储加载
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final localeCode = prefs.getString(_localeKey) ?? 'zh_CN';
    _locale = _parseLocale(localeCode);

    final currencyCode = prefs.getString(_currencyKey) ?? 'CNY';
    _currency = AppCurrency.fromCode(currencyCode);
  }

  /// 设置语言并持久化
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final code = locale.countryCode != null
        ? '${locale.languageCode}_${locale.countryCode}'
        : locale.languageCode;
    await prefs.setString(_localeKey, code);
  }

  /// 设置货币并持久化
  Future<void> setCurrency(AppCurrency currency) async {
    if (_currency == currency) return;
    _currency = currency;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency.code);
  }

  /// 解析 locale 字符串
  static Locale _parseLocale(String code) {
    final parts = code.split('_');
    if (parts.length >= 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }

  /// 所有支持的语言
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'),
    Locale('zh', 'TW'),
    Locale('ja'),
    Locale('ko'),
    Locale('en', 'US'),
  ];
}

/// BuildContext 扩展 — `context.localeProvider.currency`
extension LocaleProviderExtension on BuildContext {
  LocaleProvider get localeProvider =>
      ProviderScope.containerOf(this).read(localeProviderOverrideProvider);
}
