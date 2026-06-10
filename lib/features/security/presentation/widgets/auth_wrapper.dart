import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../pages/pin_lock_page.dart';
import '../pages/pattern_lock_page.dart';

/// 认证包装器
class AuthWrapper extends StatefulWidget {
  final Widget child;
  final Locale locale;

  const AuthWrapper({super.key, required this.child, this.locale = const Locale('zh', 'CN')});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isAuthenticated = false;
  bool _isLoading = true;
  List<String> _enabledTypes = []; // 多选解锁方式
  String _currentType = ''; // 当前显示的解锁方式
  final LocalAuthentication _localAuth = LocalAuthentication();
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lockEnabled = prefs.getBool('lock_enabled') ?? false;
      final types = prefs.getStringList('lock_types') ?? [];

      if (!lockEnabled || types.isEmpty) {
        if (mounted) {
          setState(() {
            _isAuthenticated = true;
            _isLoading = false;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _enabledTypes = types;
          _currentType = types.first;
          _isLoading = false;
        });
      }

      if (_currentType == 'biometric') {
        _tryBiometricAuth();
      }
    } catch (e) {
      debugPrint('[AuthWrapper] _checkAuth error: $e');
      // 出错时直接放行，避免卡死
      if (mounted) {
        setState(() {
          _isAuthenticated = true;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _tryBiometricAuth() async {
    try {
      final didAuth = await _localAuth.authenticate(
        localizedReason: AppLocalizations.of(context)!.securityAuthRequired,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // 允许设备密码作为后备
          useErrorDialogs: true,
        ),
      );
      if (didAuth && mounted) {
        setState(() => _isAuthenticated = true);
      }
    } on Exception {
      // 认证失败或用户取消，不自动重试，等待用户点击重试按钮
    }
  }

  void _onAuthenticated() {
    setState(() => _isAuthenticated = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        locale: widget.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocaleProvider.supportedLocales,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    if (_isAuthenticated) return widget.child;

    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      locale: widget.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocaleProvider.supportedLocales,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: _buildLockScreen(),
    );
  }

  Widget _buildLockScreen() {
    final showSwitcher = _enabledTypes.length > 1;

    switch (_currentType) {
      case 'pin':
        return _PinAuthScreen(
          onAuthenticated: _onAuthenticated,
          onSwitchType: showSwitcher ? _showTypeSwitcher : null,
        );
      case 'pattern':
        return _PatternAuthScreen(
          onAuthenticated: _onAuthenticated,
          onSwitchType: showSwitcher ? _showTypeSwitcher : null,
        );
      case 'biometric':
        return _BiometricAuthScreen(
          onAuthenticated: _onAuthenticated,
          onRetryBiometric: _tryBiometricAuth,
          onSwitchType: showSwitcher ? _showTypeSwitcher : null,
        );
      default:
        return widget.child;
    }
  }

  void _showTypeSwitcher() {
    final navContext = _navigatorKey.currentContext;
    if (navContext == null) return;

    final labels = {
      'pin': AppLocalizations.of(navContext)!.securityPinCode,
      'pattern': AppLocalizations.of(navContext)!.securityPatternLock,
      'biometric': AppLocalizations.of(navContext)!.securityBiometric,
    };
    final icons = {
      'pin': Icons.pin_outlined,
      'pattern': Icons.gesture_outlined,
      'biometric': Icons.fingerprint,
    };

    showModalBottomSheet(
      context: navContext,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(AppLocalizations.of(navContext)!.securitySelectUnlockMethod, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            ..._enabledTypes.map((type) => ListTile(
              leading: Icon(icons[type] ?? Icons.lock),
              title: Text(labels[type] ?? type),
              trailing: _currentType == type ? const Icon(Icons.check, color: Colors.green) : null,
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _currentType = type);
                if (type == 'biometric') _tryBiometricAuth();
              },
            )),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// PIN 认证屏幕
class _PinAuthScreen extends StatelessWidget {
  final VoidCallback onAuthenticated;
  final VoidCallback? onSwitchType;

  const _PinAuthScreen({required this.onAuthenticated, this.onSwitchType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PinLockPage(mode: 'verify', onAuthenticated: onAuthenticated),
          ),
          if (onSwitchType != null)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: onSwitchType,
                  child: Text(AppLocalizations.of(context)!.securitySwitchUnlockMethod),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 图案认证屏幕
class _PatternAuthScreen extends StatelessWidget {
  final VoidCallback onAuthenticated;
  final VoidCallback? onSwitchType;

  const _PatternAuthScreen({required this.onAuthenticated, this.onSwitchType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PatternLockPage(mode: 'verify', onAuthenticated: onAuthenticated),
          ),
          if (onSwitchType != null)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: onSwitchType,
                  child: Text(AppLocalizations.of(context)!.securitySwitchUnlockMethod),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 生物识别认证屏幕
class _BiometricAuthScreen extends StatelessWidget {
  final VoidCallback onAuthenticated;
  final VoidCallback onRetryBiometric;
  final VoidCallback? onSwitchType;

  const _BiometricAuthScreen({
    required this.onAuthenticated,
    required this.onRetryBiometric,
    this.onSwitchType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fingerprint, size: 80, color: Colors.grey),
              const SizedBox(height: 24),
              Text(AppLocalizations.of(context)!.securityVerifyFingerprint, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(AppLocalizations.of(context)!.securityTouchToUnlock, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: onRetryBiometric,
                child: Text(AppLocalizations.of(context)!.securityRetryFingerprint),
              ),
              if (onSwitchType != null) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: onSwitchType,
                  child: Text(AppLocalizations.of(context)!.securitySwitchUnlockMethod),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
