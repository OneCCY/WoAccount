import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'config/routes/app_router.dart';
import 'features/security/presentation/widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_CN');

  // 全局错误捕获
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };

  // 加载主题设置
  final themeProvider = ThemeProvider();
  await themeProvider.load();

  runApp(
    ProviderScope(
      overrides: [
        themeProviderOverrideProvider.overrideWith((ref) => themeProvider),
      ],
      child: const AuthWrapper(
        child: WoAccountApp(),
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

    return MaterialApp.router(
      title: 'WoAccount',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: AppRouter.router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('zh', 'CN'),
    );
  }
}
