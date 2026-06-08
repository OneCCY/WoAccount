import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../core/widgets/navigation/main_shell.dart';
import '../../features/chat/presentation/pages/ai_chat_page.dart';
import '../../features/transaction/presentation/pages/transaction_list_page.dart';
import '../../features/transaction/presentation/pages/manual_entry_page.dart';
import '../../features/transaction/presentation/pages/transaction_detail_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/profile_edit_page.dart';
import '../../features/profile/presentation/pages/checkin_calendar_page.dart';
import '../../features/profile/presentation/pages/ac_coin_records_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/llm_settings_page.dart';
import '../../features/budget/presentation/pages/budget_page.dart';
import '../../features/budget/presentation/pages/budget_setting_page.dart';
import '../../features/category/presentation/pages/category_manage_page.dart';
import '../../features/security/presentation/pages/lock_settings_page.dart';
import '../../features/security/presentation/pages/pin_lock_page.dart';
import '../../features/security/presentation/pages/pattern_lock_page.dart';
import '../../features/account_book/presentation/pages/account_book_page.dart';
import '../../features/account_book/presentation/pages/account_book_detail_page.dart';
import '../../features/stats/presentation/pages/report_page.dart';

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
          // 记账首页（中 Tab）- AI 对话记账
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AiChatPage(),
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
        path: '/profile/edit',
        builder: (context, state) => const ProfileEditPage(),
      ),
      GoRoute(
        path: '/checkin-calendar',
        builder: (context, state) => const CheckInCalendarPage(),
      ),
      GoRoute(
        path: '/ac-coins',
        builder: (context, state) => const AcCoinRecordsPage(),
      ),
      GoRoute(
        path: '/settings/llm',
        builder: (context, state) => const LlmSettingsPage(),
      ),
      GoRoute(
        path: '/budget',
        builder: (context, state) => const BudgetPage(),
      ),
      GoRoute(
        path: '/budget/setting',
        builder: (context, state) => const BudgetSettingPage(),
      ),
      GoRoute(
        path: '/categories/manage',
        builder: (context, state) => const CategoryManagePage(),
      ),
      GoRoute(
        path: '/lock-settings',
        builder: (context, state) => const LockSettingsPage(),
      ),
      GoRoute(
        path: '/pin-lock',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final mode = extra?['mode'] as String? ?? 'verify';
          return PinLockPage(mode: mode);
        },
      ),
      GoRoute(
        path: '/pattern-lock',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final mode = extra?['mode'] as String? ?? 'verify';
          return PatternLockPage(mode: mode);
        },
      ),
      // 账本管理
      GoRoute(
        path: '/account-books',
        builder: (context, state) => const AccountBookPage(),
      ),
      GoRoute(
        path: '/account-books/detail',
        builder: (context, state) {
          final bookId = state.extra as int;
          return AccountBookDetailPage(bookId: bookId);
        },
      ),
      // 报表分析
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportPage(),
      ),
    ],
  );
}

// === 临时占位页面（后续替换为正式实现） ===

// TransactionDetailPage 已移至 features/transaction/presentation/pages/transaction_detail_page.dart

// ManualEntryPage 已移至 features/transaction/presentation/pages/manual_entry_page.dart

class AiAssistantPage extends StatelessWidget {
  const AiAssistantPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('AI 助手')));
  }
}

// SettingsPage 已移至 features/settings/presentation/pages/settings_page.dart
// LlmSettingsPage 已移至 features/settings/presentation/pages/llm_settings_page.dart
