import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

/// WoAccount 路由配置
/// 使用 GoRouter 声明式路由
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // 底部导航 Shell
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // 账单列表（左 Tab）
          GoRoute(
            path: '/transactions',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TransactionListPage(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => TransactionDetailPage(
                  transactionId: int.parse(state.pathParameters['id']!),
                ),
              ),
            ],
          ),
          // 记账首页（中 Tab）
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          // 我的（右 Tab）
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfilePage(),
            ),
          ),
        ],
      ),

      // 非 Shell 路由（全屏页面）
      GoRoute(
        path: '/manual-entry',
        builder: (context, state) => const ManualEntryPage(),
      ),
      GoRoute(
        path: '/ai-assistant',
        builder: (context, state) => const AiAssistantPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/settings/llm',
        builder: (context, state) => const LlmSettingsPage(),
      ),
    ],
  );
}

// === 临时占位页面 ===

/// 主 Shell（底部导航栏）
class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (index) => _onTap(context, index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: '账单'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '记账'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
    );
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/transactions')) return 0;
    if (location == '/') return 1;
    if (location.startsWith('/profile')) return 2;
    return 1;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/transactions');
      case 1: context.go('/');
      case 2: context.go('/profile');
    }
  }
}

// 占位页面
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('记账首页')));
  }
}

class TransactionListPage extends StatelessWidget {
  const TransactionListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('账单列表')));
  }
}

class TransactionDetailPage extends StatelessWidget {
  final int transactionId;
  const TransactionDetailPage({super.key, required this.transactionId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('账单详情 #$transactionId')));
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('我的')));
  }
}

class ManualEntryPage extends StatelessWidget {
  const ManualEntryPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('手动记账')));
  }
}

class AiAssistantPage extends StatelessWidget {
  const AiAssistantPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('AI 助手')));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('设置')));
  }
}

class LlmSettingsPage extends StatelessWidget {
  const LlmSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('LLM 配置')));
  }
}
