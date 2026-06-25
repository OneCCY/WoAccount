import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import 'core/locale/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'config/routes/app_router.dart';
import 'config/di/providers.dart';
import 'features/security/presentation/widgets/auth_wrapper.dart';
import 'features/profile/data/services/backup_service.dart';
import 'features/ai/data/storage/config_migration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_CN');

  // 全局错误捕获
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  // AI 配置迁移（v1 → v2）
  try {
    await ConfigMigration.migrate();
  } catch (_) {
    // 迁移失败不阻塞启动
  }

  // 加载主题设置
  final themeProvider = ThemeProvider();
  await themeProvider.load();

  // 加载语言和货币设置
  final localeProvider = LocaleProvider();
  await localeProvider.load();

  // 加载上次选中的账本
  final prefs = await SharedPreferences.getInstance();
  final savedBookId = prefs.getInt('current_book_id') ?? 1;

  // 自动备份检查（后台执行，不阻塞启动）
  BackupService().autoBackup().catchError((_) => null);

  runApp(
    ProviderScope(
      overrides: [
        themeProviderOverrideProvider.overrideWith((ref) => themeProvider),
        localeProviderOverrideProvider.overrideWith((ref) => localeProvider),
        currentBookProvider.overrideWith((ref) => savedBookId),
      ],
      child: AuthWrapper(
        locale: localeProvider.locale,
        child: const WoAccountApp(),
      ),
    ),
  );
}

/// ThemeProvider 的 Riverpod Provider
final themeProviderOverrideProvider = ChangeNotifierProvider<ThemeProvider>((ref) {
  throw UnimplementedError('必须在 ProviderScope 中通过 override 提供');
});

class WoAccountApp extends ConsumerWidget {
  const WoAccountApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeProvider = ref.watch(themeProviderOverrideProvider);
    final localeProvider = ref.watch(localeProviderOverrideProvider);

    return MaterialApp.router(
      title: 'WoAccount',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,

      // 国际化配置
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleProvider.supportedLocales,

      routerConfig: AppRouter.router,
    );
  }
}
