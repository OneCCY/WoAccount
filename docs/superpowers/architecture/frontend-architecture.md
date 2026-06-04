# WoAccount 前端架构设计

> **版本**: v1.0 | **创建日期**: 2026-06-04 | **技术栈**: Flutter + Riverpod + GoRouter

---

## 1. 项目结构（Feature-First）

```
lib/
├── core/                          # 核心模块（全局共享）
│   ├── constants/                 # 常量定义
│   │   ├── app_constants.dart     # 应用常量
│   │   └── api_constants.dart     # API相关常量
│   ├── error/                     # 错误处理
│   │   ├── exceptions.dart        # 自定义异常
│   │   └── failures.dart          # 错误类型定义
│   ├── extensions/                # Dart扩展方法
│   │   ├── string_extensions.dart
│   │   └── datetime_extensions.dart
│   ├── theme/                     # 主题配置
│   │   ├── app_theme.dart         # 主题定义
│   │   ├── app_colors.dart        # 颜色系统
│   │   ├── app_text_styles.dart   # 字体样式
│   │   └── app_dimensions.dart    # 间距/圆角
│   ├── utils/                     # 工具类
│   │   ├── date_utils.dart        # 日期工具
│   │   ├── currency_utils.dart    # 货币格式化
│   │   └── validation_utils.dart  # 验证工具
│   └── widgets/                   # 公共组件
│       ├── buttons/               # 按钮组件
│       ├── cards/                 # 卡片组件
│       ├── inputs/                # 输入框组件
│       ├── dialogs/               # 弹窗组件
│       └── loading/               # 加载组件
│
├── features/                      # 功能模块
│   ├── home/                      # 首页（记账入口）
│   │   ├── data/                  # 数据层
│   │   │   ├── datasources/       # 数据源
│   │   │   ├── models/            # 数据模型
│   │   │   └── repositories/      # 仓库实现
│   │   ├── domain/                # 领域层
│   │   │   ├── entities/          # 实体
│   │   │   ├── repositories/      # 仓库接口
│   │   │   └── usecases/          # 用例
│   │   └── presentation/          # 展示层
│   │       ├── providers/         # Riverpod Providers
│   │       ├── pages/             # 页面
│   │       └── widgets/           # 页面专属组件
│   │
│   ├── transaction/               # 交易记录
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── budget/                    # 预算管理
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── category/                  # 分类管理
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── ai_assistant/              # AI助手
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── settings/                  # 设置
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── config/                        # 配置
│   ├── routes/                    # 路由配置
│   │   └── app_router.dart
│   ├── di/                        # 依赖注入
│   │   └── providers.dart         # 全局Providers
│   └── database/                  # 数据库配置
│       └── app_database.dart
│
└── main.dart                      # 应用入口
```

---

## 2. 三层架构（Clean Architecture）

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation（展示层）                  │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐   │
│  │  Pages  │  │ Widgets │  │Providers│  │  State  │   │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘   │
│       │            │            │            │          │
├───────┴────────────┴────────────┴────────────┴──────────┤
│                    Domain（领域层）                        │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐                 │
│  │Entities │  │UseCases │  │Repository│                 │
│  │         │  │         │  │Interface │                 │
│  └────┬────┘  └────┬────┘  └────┬────┘                 │
│       │            │            │                        │
├───────┴────────────┴────────────┴───────────────────────┤
│                    Data（数据层）                          │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐                 │
│  │ Models  │  │DataSources│ │Repository│                │
│  │         │  │(API/DB) │  │Implementation│             │
│  └─────────┘  └─────────┘  └─────────┘                 │
└─────────────────────────────────────────────────────────┘
```

### 各层职责

| 层 | 职责 | 依赖关系 |
|----|------|----------|
| **Presentation** | UI展示、用户交互、状态管理 | 依赖Domain |
| **Domain** | 业务逻辑、实体定义、仓库接口 | 不依赖任何层 |
| **Data** | 数据获取、模型转换、仓库实现 | 依赖Domain |

### 依赖规则

```
Presentation → Domain ← Data
```

**关键原则：**
- Domain层不依赖任何其他层
- Data层实现Domain层定义的接口
- Presentation层只调用Domain层的UseCase

---

## 3. Riverpod 状态管理（详解）

### 3.1 什么是Riverpod？

Riverpod是Flutter的状态管理工具，用于：
- 管理应用中的数据流
- 处理异步操作（API调用、数据库查询）
- 实现依赖注入
- 自动管理资源生命周期

### 3.2 核心概念

| 概念 | 说明 | 类比 |
|------|------|------|
| **Provider** | 提供一个值或对象 | 相当于一个"工厂" |
| **StateNotifier** | 管理可变状态 | 相当于一个"状态容器" |
| **ref.watch()** | 监听状态变化，自动重建UI | 订阅 |
| **ref.read()** | 一次性读取当前值 | 快照 |
| **ref.listen()** | 监听状态变化，执行副作用 | 回调 |

### 3.3 Provider类型

#### 1. Provider（只读值）

```dart
// 提供一个不会变化的值
final greetingProvider = Provider<String>((ref) {
  return 'Hello, WoAccount!';
});

// 使用
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final greeting = ref.watch(greetingProvider);
    return Text(greeting);
  }
}
```

**适用场景：** 常量、配置、工具类实例

---

#### 2. StateProvider（简单可变状态）

```dart
// 提供一个可以修改的值
final counterProvider = StateProvider<int>((ref) => 0);

// 使用
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    return Column(
      children: [
        Text('Count: $counter'),
        ElevatedButton(
          onPressed: () => ref.read(counterProvider.notifier).state++,
          child: Text('Increment'),
        ),
      ],
    );
  }
}
```

**适用场景：** 简单状态（开关、计数器、选中项）

---

#### 3. StateNotifierProvider（复杂状态）

```dart
// 定义状态管理器
class TransactionNotifier extends StateNotifier<AsyncValue<List<Transaction>>> {
  final TransactionRepository repository;
  
  TransactionNotifier(this.repository) : super(const AsyncValue.loading()) {
    loadTransactions();
  }
  
  Future<void> loadTransactions() async {
    state = const AsyncValue.loading();
    try {
      final transactions = await repository.getAll();
      state = AsyncValue.data(transactions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> addTransaction(Transaction transaction) async {
    await repository.insert(transaction);
    await loadTransactions(); // 重新加载
  }
}

// 定义Provider
final transactionProvider = StateNotifierProvider<
    TransactionNotifier, AsyncValue<List<Transaction>>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionNotifier(repository);
});

// 使用
class TransactionListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionProvider);
    
    return transactionsAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (transactions) => ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return TransactionItem(transaction: transactions[index]);
        },
      ),
    );
  }
}
```

**适用场景：** 复杂业务逻辑、需要多个方法的状态管理

---

#### 4. FutureProvider（异步单次请求）

```dart
// 获取单个数据
final transactionProvider = FutureProvider.family<Transaction, int>((ref, id) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return await repository.getById(id);
});

// 使用
class TransactionDetailPage extends ConsumerWidget {
  final int transactionId;
  
  const TransactionDetailPage({required this.transactionId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsync = ref.watch(transactionProvider(transactionId));
    
    return transactionAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (transaction) => TransactionDetail(transaction: transaction),
    );
  }
}
```

**适用场景：** 一次性异步请求（查询详情、加载配置）

---

#### 5. StreamProvider（实时数据流）

```dart
// 监听数据库变化
final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final database = ref.watch(databaseProvider);
  return database.watchAllTransactions();
});

// 使用
class TransactionListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    
    return transactionsAsync.when(
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
      data: (transactions) => ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          return TransactionItem(transaction: transactions[index]);
        },
      ),
    );
  }
}
```

**适用场景：** 实时数据（数据库监听、WebSocket）

---

### 3.4 Provider依赖关系

```dart
// Repository Provider
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return TransactionRepositoryImpl(database);
});

// UseCase Provider
final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return AddTransactionUseCase(repository);
});

// Notifier Provider
final transactionNotifierProvider = StateNotifierProvider<
    TransactionNotifier, AsyncValue<List<Transaction>>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionNotifier(repository);
});
```

**依赖链：**
```
databaseProvider → transactionRepositoryProvider → transactionNotifierProvider
```

---

### 3.5 最佳实践

#### ✅ 推荐

```dart
// 1. 使用autoDispose避免内存泄漏
final transactionProvider = StateNotifierProvider.autoDispose<
    TransactionNotifier, AsyncValue<List<Transaction>>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionNotifier(repository);
});

// 2. 使用family传递参数
final transactionProvider = FutureProvider.family<Transaction, int>((ref, id) async {
  // ...
});

// 3. 在build中使用ref.watch，在事件处理中使用ref.read
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watchdataProvider); // 监听变化
    return ElevatedButton(
      onPressed: () {
        ref.readdataProvider.notifier).doSomething(); // 读取一次
      },
      child: Text('Click'),
    );
  }
}

// 4. 使用ref.listen处理副作用
class MyWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  @override
  void initState() {
    super.initState();
    ref.listenManual(transactionProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${next.error}')),
        );
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // ...
  }
}
```

#### ❌ 避免

```dart
// 1. 不要在build方法外使用ref.watch
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ❌ 错误：在其他方法中使用ref.watch
    void doSomething() {
      final data = ref.watch(provider); // 不要这样做
    }
    
    return Container();
  }
}

// 2. 不要直接修改状态
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ❌ 错误：直接修改状态
    ref.read(provider).value = newValue; // 不要这样做
    
    // ✅ 正确：通过notifier修改
    ref.read(provider.notifier).update(newValue);
    
    return Container();
  }
}
```

---

## 4. 导航方案（GoRouter）

### 4.1 路由配置

```dart
// lib/config/routes/app_router.dart

import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // 底部导航Shell
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        // 账单页
        GoRoute(
          path: '/transactions',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TransactionListPage(),
          ),
          routes: [
            // 账单详情
            GoRoute(
              path: ':id',
              builder: (context, state) => TransactionDetailPage(
                transactionId: int.parse(state.pathParameters['id']!),
              ),
            ),
          ],
        ),
        // 记账首页
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomePage(),
          ),
        ),
        // 我的
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfilePage(),
          ),
        ),
      ],
    ),
    
    // 非Shell路由（全屏页面）
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
```

### 4.2 路由结构

```
/                           → 记账首页（中Tab）
/transactions               → 账单列表（左Tab）
/transactions/:id           → 账单详情
/profile                    → 我的（右Tab）
/manual-entry               → 手动记账（全屏）
/ai-assistant               → AI助手（全屏）
/settings                   → 设置（全屏）
/settings/llm               → LLM配置（全屏）
```

### 4.3 页面转场动画

```dart
// 自定义转场动画
GoRoute(
  path: '/manual-entry',
  pageBuilder: (context, state) => CustomTransitionPage(
    child: const ManualEntryPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),  // 从底部滑入
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 400), // 更慢节奏
  ),
);
```

---

## 5. 组件规范

### 5.1 组件分类

| 类型 | 位置 | 说明 |
|------|------|------|
| **全局组件** | `lib/core/widgets/` | 整个应用共享 |
| **功能组件** | `lib/features/*/presentation/widgets/` | 单个功能使用 |

### 5.2 全局组件示例

```dart
// lib/core/widgets/buttons/primary_button.dart

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  
  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
```

### 5.3 组件命名规范

| 类型 | 命名格式 | 示例 |
|------|----------|------|
| 页面 | `XxxPage` | `TransactionListPage` |
| 全局组件 | `XxxWidget` / `XxxButton` | `PrimaryButton` |
| 功能组件 | `XxxItem` / `XxxCard` | `TransactionItem` |
| 弹窗 | `XxxDialog` / `XxxSheet` | `ConfirmDialog` |

---

## 6. 数据流示例

### 6.1 添加交易记录

```
用户点击"完成"
       │
       ▼
┌─────────────────────────────────────┐
│  Presentation层                      │
│  ref.read(transactionProvider        │
│       .notifier)                     │
│       .addTransaction(transaction)   │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│  Domain层                            │
│  AddTransactionUseCase(transaction)  │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│  Data层                              │
│  TransactionRepositoryImpl.insert()  │
│  → Database.insertTransaction()      │
└──────────────────┬──────────────────┘
                   │
                   ▼
┌─────────────────────────────────────┐
│  状态更新                            │
│  state = AsyncValue.data(newList)    │
│  → UI自动重建                        │
└─────────────────────────────────────┘
```

---

## 7. 目录结构总结

| 目录 | 用途 | 示例文件 |
|------|------|----------|
| `core/constants/` | 全局常量 | `app_constants.dart` |
| `core/error/` | 错误处理 | `exceptions.dart` |
| `core/theme/` | 主题配置 | `app_theme.dart` |
| `core/widgets/` | 全局组件 | `primary_button.dart` |
| `features/*/data/` | 数据层 | `transaction_repository_impl.dart` |
| `features/*/domain/` | 领域层 | `transaction.dart` |
| `features/*/presentation/` | 展示层 | `transaction_list_page.dart` |
| `config/routes/` | 路由配置 | `app_router.dart` |
| `config/di/` | 依赖注入 | `providers.dart` |
| `config/database/` | 数据库配置 | `app_database.dart` |
