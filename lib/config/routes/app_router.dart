import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../core/widgets/navigation/main_shell.dart';
import '../../features/home/presentation/pages/home_page.dart';

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

// === 临时占位页面（后续替换为正式实现） ===

class TransactionListPage extends StatelessWidget {
  const TransactionListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('账单')),
      body: const Center(child: Text('账单列表 - 待实现')),
    );
  }
}

class TransactionDetailPage extends StatelessWidget {
  final int transactionId;
  const TransactionDetailPage({super.key, required this.transactionId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('账单详情')),
      body: Center(child: Text('账单详情 #$transactionId')),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('我的')),
      body: const Center(child: Text('我的 - 待实现')),
    );
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
