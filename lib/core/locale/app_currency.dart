import 'package:wo_account/l10n/app_localizations.dart';

/// 支持的货币类型
enum AppCurrency {
  cny('CNY', '¥', '人民币'),
  usd('USD', '\$', '美元'),
  krw('KRW', '₩', '韩元'),
  jpy('JPY', '¥', '日元'),
  eur('EUR', '€', '欧元'),
  gbp('GBP', '£', '英镑');

  final String code;
  final String symbol;
  final String label;

  const AppCurrency(this.code, this.symbol, this.label);

  /// Returns the localized name for this currency.
  String getLocalizedName(AppLocalizations l10n) {
    switch (this) {
      case AppCurrency.cny:
        return l10n.currencyCny;
      case AppCurrency.usd:
        return l10n.currencyUsd;
      case AppCurrency.krw:
        return l10n.currencyKrw;
      case AppCurrency.jpy:
        return l10n.currencyJpy;
      case AppCurrency.eur:
        return l10n.currencyEur;
      case AppCurrency.gbp:
        return l10n.currencyGbp;
    }
  }

  static AppCurrency fromCode(String code) {
    return AppCurrency.values.where((c) => c.code == code).firstOrNull ?? cny;
  }

  /// 格式化金额（带货币符号）
  String formatAmount(double amount, {int decimals = 2}) {
    return '$symbol${amount.toStringAsFixed(decimals)}';
  }

  /// 带符号格式化（支出为负，收入为正）
  String formatWithSign(double amount, bool isExpense, {int decimals = 2}) {
    final prefix = isExpense ? '-' : '+';
    return '$prefix$symbol${amount.toStringAsFixed(decimals)}';
  }

  /// 缩写金额（中文用"万"，其他用 k/M/B）
  String formatAbbreviated(double amount) {
    if (code == 'CNY' || code == 'JPY') {
      // 中文/日文习惯：万
      if (amount >= 100000000) {
        return '$symbol${(amount / 100000000).toStringAsFixed(1)}亿';
      } else if (amount >= 10000) {
        return '$symbol${(amount / 10000).toStringAsFixed(1)}万';
      } else if (amount >= 1000) {
        return '$symbol${(amount / 1000).toStringAsFixed(1)}k';
      }
    } else if (code == 'KRW') {
      // 韩元：만 (万)
      if (amount >= 100000000) {
        return '$symbol${(amount / 100000000).toStringAsFixed(1)}억';
      } else if (amount >= 10000) {
        return '$symbol${(amount / 10000).toStringAsFixed(1)}만';
      } else if (amount >= 1000) {
        return '$symbol${(amount / 1000).toStringAsFixed(1)}k';
      }
    } else {
      // 英文习惯：k/M/B
      if (amount >= 1000000000) {
        return '$symbol${(amount / 1000000000).toStringAsFixed(1)}B';
      } else if (amount >= 1000000) {
        return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
      } else if (amount >= 1000) {
        return '$symbol${(amount / 1000).toStringAsFixed(1)}k';
      }
    }

    // 小金额：整数不显示小数
    if (amount == amount.roundToDouble()) {
      return '$symbol${amount.toInt()}';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }

  /// 紧凑格式（不带符号，周视图用）
  String formatCompact(double amount) {
    if (amount >= 1000) {
      if (code == 'CNY' || code == 'JPY' || code == 'KRW') {
        return '${(amount / 1000).toStringAsFixed(1)}k';
      }
      return '${(amount / 1000).toStringAsFixed(1)}k';
    }
    if (amount == amount.roundToDouble()) {
      return '${amount.toInt()}';
    }
    return amount.toStringAsFixed(0);
  }
}
