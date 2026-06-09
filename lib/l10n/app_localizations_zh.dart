// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'WoAccount';

  @override
  String get navTransactions => '账单';

  @override
  String get navRecord => '记账';

  @override
  String get navProfile => '我的';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => 'WoAccount';

  @override
  String get navTransactions => '帳單';

  @override
  String get navRecord => '記帳';

  @override
  String get navProfile => '我的';
}
