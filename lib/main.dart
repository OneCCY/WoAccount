import 'dart:async';
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
import 'config/di/ai_providers.dart';
import 'features/ai/data/repository/memory_repository.dart';
import 'features/security/presentation/widgets/auth_wrapper.dart';
import 'features/profile/data/services/backup_service.dart';
import 'features/ai/data/storage/config_migration.dart';
import 'features/ai/data/storage/persona_storage.dart';

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

  // 初始化预设角色（前台执行，确保首次运行有预设数据）
  try {
    await PersonaStorage.initPresets();
  } catch (_) {}

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

class WoAccountApp extends ConsumerStatefulWidget {
  const WoAccountApp({super.key});

  @override
  ConsumerState<WoAccountApp> createState() => _WoAccountAppState();
}

class _WoAccountAppState extends ConsumerState<WoAccountApp> with WidgetsBindingObserver {
  Timer? _decayTimer;
  AppLifecycleListener? _lifecycleListener;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 内存 decay 定时器：每 24 小时清理一次低分记忆
    _decayTimer = Timer.periodic(const Duration(hours: 24), (_) async {
      try {
        final db = ref.read(appDatabaseProvider);
        final memoryRepo = MemoryRepository(db);
        await memoryRepo.decayAndPrune();
      } catch (_) {}
    });

    // App 生命周期监听（切后台时触发记忆提取）
    _lifecycleListener = AppLifecycleListener(
      onInactive: _onBackgrounded,
      onPause: _onBackgrounded,
      onDetach: _onBackgrounded,
    );
  }

  void _onBackgrounded() {
    try {
      final queue = ref.read(memoryExtractionQueueProvider);
      queue.onAppBackgrounded();
    } catch (_) {}
  }

  @override
  void dispose() {
    _decayTimer?.cancel();
    _lifecycleListener?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
