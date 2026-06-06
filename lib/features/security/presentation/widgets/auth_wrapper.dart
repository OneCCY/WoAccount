import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import '../pages/pin_lock_page.dart';
import '../pages/pattern_lock_page.dart';

/// 认证包装器
/// 在应用启动时检查是否需要解锁，如果需要则显示相应的解锁界面
class AuthWrapper extends StatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isAuthenticated = false;
  bool _isLoading = true;
  String _lockType = 'none';
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final lockEnabled = prefs.getBool('lock_enabled') ?? false;
    final lockType = prefs.getString('lock_type') ?? 'none';

    if (!lockEnabled || lockType == 'none') {
      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _lockType = lockType;
      _isLoading = false;
    });

    // 如果是生物识别，自动尝试验证
    if (lockType == 'biometric') {
      _tryBiometricAuth();
    }
  }

  Future<void> _tryBiometricAuth() async {
    try {
      final didAuth = await _localAuth.authenticate(
        localizedReason: '请验证身份以解锁应用',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (didAuth && mounted) {
        setState(() => _isAuthenticated = true);
      }
    } catch (_) {
      // 生物识别失败，等待用户手动选择其他方式
    }
  }

  void _onAuthenticated() {
    setState(() => _isAuthenticated = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_isAuthenticated) {
      return widget.child;
    }

    // 显示解锁界面
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _buildLockScreen(),
    );
  }

  Widget _buildLockScreen() {
    switch (_lockType) {
      case 'pin':
        return _PinAuthScreen(
          onAuthenticated: _onAuthenticated,
          onSwitchType: _showTypeSwitcher,
        );
      case 'pattern':
        return _PatternAuthScreen(
          onAuthenticated: _onAuthenticated,
          onSwitchType: _showTypeSwitcher,
        );
      case 'biometric':
        return _BiometricAuthScreen(
          onAuthenticated: _onAuthenticated,
          onRetryBiometric: _tryBiometricAuth,
          onSwitchType: _showTypeSwitcher,
        );
      default:
        return widget.child;
    }
  }

  void _showTypeSwitcher() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('选择解锁方式', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            ListTile(
              leading: const Icon(Icons.pin_outlined),
              title: const Text('数字密码'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _lockType = 'pin');
              },
            ),
            ListTile(
              leading: const Icon(Icons.gesture_outlined),
              title: const Text('图案解锁'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _lockType = 'pattern');
              },
            ),
            ListTile(
              leading: const Icon(Icons.fingerprint),
              title: const Text('指纹解锁'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _lockType = 'biometric');
                _tryBiometricAuth();
              },
            ),
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
  final VoidCallback onSwitchType;

  const _PinAuthScreen({
    required this.onAuthenticated,
    required this.onSwitchType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PinLockPage(
              mode: 'verify',
              onAuthenticated: onAuthenticated,
            ),
          ),
          // 切换解锁方式按钮
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: onSwitchType,
                child: const Text('切换解锁方式'),
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
  final VoidCallback onSwitchType;

  const _PatternAuthScreen({
    required this.onAuthenticated,
    required this.onSwitchType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PatternLockPage(
              mode: 'verify',
              onAuthenticated: onAuthenticated,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: onSwitchType,
                child: const Text('切换解锁方式'),
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
  final VoidCallback onSwitchType;

  const _BiometricAuthScreen({
    required this.onAuthenticated,
    required this.onRetryBiometric,
    required this.onSwitchType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fingerprint,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: 24),
              const Text(
                '请验证指纹',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                '触摸指纹传感器以解锁应用',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: onRetryBiometric,
                child: const Text('重试指纹'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: onSwitchType,
                child: const Text('切换解锁方式'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
