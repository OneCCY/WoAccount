# 05 - 架构设计文档 (Technical Specification)

> **版本**: v2.0 | **更新日期**: 2025-01-15 | **状态**: 技术评审中

---

## 5.1 架构概述

### 5.1.1 架构原则

| 原则 | 描述 | 实践 |
|------|------|------|
| **单一职责** | 每个模块只负责一个功能 | Repository只负责数据访问 |
| **依赖倒置** | 高层模块不依赖低层模块 | 抽象接口 + 实现注入 |
| **关注点分离** | UI、业务逻辑、数据分离 | Clean Architecture |
| **可测试性** | 代码易于单元测试 | 依赖注入 + Mock |
| **可扩展性** | 易于添加新功能 | 插件化设计 |

### 5.1.2 架构模式

**选择: Clean Architecture + Riverpod**

```
┌─────────────────────────────────────────────────────────────────┐
│                      Clean Architecture                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    Presentation Layer                     │   │
│  │  ├── Pages (页面)                                        │   │
│  │  ├── Widgets (组件)                                      │   │
│  │  └── Providers (状态管理)                                │   │
│  └─────────────────────────┬───────────────────────────────┘   │
│                            │                                    │
│  ┌─────────────────────────▼───────────────────────────────┐   │
│  │                    Application Layer                      │   │
│  │  ├── UseCases (用例)                                     │   │
│  │  └── Services (服务)                                     │   │
│  └─────────────────────────┬───────────────────────────────┘   │
│                            │                                    │
│  ┌─────────────────────────▼───────────────────────────────┐   │
│  │                    Domain Layer                           │   │
│  │  ├── Entities (实体)                                     │   │
│  │  ├── Repositories (仓储接口)                             │   │
│  │  └── ValueObjects (值对象)                               │   │
│  └─────────────────────────┬───────────────────────────────┘   │
│                            │                                    │
│  ┌─────────────────────────▼───────────────────────────────┐   │
│  │                    Data Layer                             │   │
│  │  ├── Repositories (仓储实现)                             │   │
│  │  ├── DataSources (数据源)                                │   │
│  │  │   ├── Local (SQLite)                                  │   │
│  │  │   └── Remote (Supabase)                               │   │
│  │  └── Models (数据模型)                                   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 5.2 目录结构

```
lib/
├── main.dart                          # 应用入口
├── app.dart                           # App配置
│
├── core/                              # 核心模块
│   ├── constants/                     # 常量
│   │   ├── app_constants.dart
│   │   ├── api_constants.dart
│   │   └── db_constants.dart
│   ├── errors/                        # 错误处理
│   │   ├── app_exception.dart
│   │   └── error_handler.dart
│   ├── theme/                         # 主题
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   ├── text_styles.dart
│   │   ├── dimensions.dart
│   │   └── animations.dart
│   ├── utils/                         # 工具
│   │   ├── date_utils.dart
│   │   ├── currency_utils.dart
│   │   ├── validation_utils.dart
│   │   └── platform_utils.dart
│   └── extensions/                    # 扩展
│       ├── string_extensions.dart
│       ├── datetime_extensions.dart
│       └── double_extensions.dart
│
├── features/                          # 功能模块
│   ├── transaction/                   # 记账功能
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── transaction_local_ds.dart
│   │   │   │   └── transaction_remote_ds.dart
│   │   │   ├── models/
│   │   │   │   └── transaction_model.dart
│   │   │   └── repositories/
│   │   │       └── transaction_repo_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── transaction.dart
│   │   │   ├── repositories/
│   │   │   │   └── transaction_repo.dart
│   │   │   └── usecases/
│   │   │       ├── add_transaction.dart
│   │   │       ├── get_transactions.dart
│   │   │       └── delete_transaction.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── home_page.dart
│   │       │   └── transaction_detail_page.dart
│   │       ├── providers/
│   │       │   ├── transaction_provider.dart
│   │       │   └── transaction_provider.g.dart
│   │       └── widgets/
│   │           ├── transaction_input.dart
│   │           ├── ai_result_card.dart
│   │           └── transaction_tile.dart
│   │
│   ├── category/                      # 分类功能
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── stats/                         # 统计功能
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── ai/                            # AI功能
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── llm_api_ds.dart
│   │   │   ├── models/
│   │   │   │   ├── ai_parse_result.dart
│   │   │   │   └── chat_message.dart
│   │   │   └── repositories/
│   │   │       └── ai_repo_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── parse_result.dart
│   │   │   │   └── query_intent.dart
│   │   │   ├── repositories/
│   │   │   │   └── ai_repo.dart
│   │   │   └── services/
│   │   │       ├── ai_service.dart
│   │   │       ├── rule_engine.dart
│   │   │       └── llm_api_service.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   └── ai_assistant_page.dart
│   │       ├── providers/
│   │       │   ├── ai_provider.dart
│   │       │   └── chat_provider.dart
│   │       └── widgets/
│   │           ├── chat_message_tile.dart
│   │           └── quick_query_bar.dart
│   │
│   ├── budget/                        # 预算功能
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── auth/                          # 认证功能
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── settings/                      # 设置功能
│       ├── data/
│       ├── domain/
│       └── presentation/
│
├── shared/                            # 共享模块
│   ├── database/
│   │   ├── app_database.dart
│   │   ├── app_database.g.dart
│   │   ├── tables/
│   │   │   ├── transactions_table.dart
│   │   │   ├── categories_table.dart
│   │   │   └── budgets_table.dart
│   │   └── daos/
│   │       ├── transaction_dao.dart
│   │       └── category_dao.dart
│   ├── services/
│   │   ├── analytics_service.dart
│   │   ├── notification_service.dart
│   │   └── sync_service.dart
│   └── widgets/
│       ├── common_card.dart
│       ├── common_button.dart
│       ├── common_input.dart
│       ├── loading_indicator.dart
│       └── error_widget.dart
│
└── config/                            # 配置
    ├── routes/
    │   └── app_router.dart
    ├── di/
    │   └── providers.dart
    └── env/
        └── environment.dart
```

---

## 5.3 数据库设计

### 5.3.1 ER图

```
┌─────────────────────────────────────────────────────────────────┐
│                          ER Diagram                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────┐       ┌─────────────┐       ┌─────────────┐  │
│  │   Users     │       │ Categories  │       │   Budgets   │  │
│  ├─────────────┤       ├─────────────┤       ├─────────────┤  │
│  │ id (PK)     │◀──┐   │ id (PK)     │◀──┐   │ id (PK)     │  │
│  │ email       │   │   │ user_id(FK) │   │   │ user_id(FK) │  │
│  │ created_at  │   │   │ name        │   │   │ category_id │  │
│  └─────────────┘   │   │ icon        │   │   │ amount      │  │
│                    │   │ color       │   │   │ period      │  │
│                    │   │ parent_id   │───┘   │ year        │  │
│                    │   │ level       │       │ month       │  │
│                    │   │ is_system   │       └─────────────┘  │
│                    │   └─────────────┘                         │
│                    │           ▲                                │
│                    │           │                                │
│                    │   ┌───────┴───────┐                       │
│                    │   │               │                       │
│  ┌─────────────────┴───┴───────────────┴───────────────────┐  │
│  │                    Transactions                           │  │
│  ├─────────────────────────────────────────────────────────┤  │
│  │ id (PK)                                                  │  │
│  │ user_id (FK → Users)                                     │  │
│  │ amount                                                   │  │
│  │ description                                              │  │
│  │ category_id (FK → Categories)                            │  │
│  │ subcategory_id (FK → Categories)                         │  │
│  │ transaction_date                                         │  │
│  │ original_input                                           │  │
│  │ ai_confidence                                            │  │
│  │ ai_source                                                │  │
│  │ user_confirmed                                           │  │
│  │ created_at                                               │  │
│  │ updated_at                                               │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                  ConversationMessages                     │  │
│  ├─────────────────────────────────────────────────────────┤  │
│  │ id (PK)                                                  │  │
│  │ conversation_id                                          │  │
│  │ role (user/assistant/system/function)                    │  │
│  │ content                                                  │  │
│  │ function_name                                            │  │
│  │ function_args                                            │  │
│  │ function_result                                          │  │
│  │ created_at                                               │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │                    AiTrainingData                         │  │
│  ├─────────────────────────────────────────────────────────┤  │
│  │ id (PK)                                                  │  │
│  │ user_id (FK → Users)                                     │  │
│  │ input_text                                               │  │
│  │ predicted_category_id                                    │  │
│  │ actual_category_id                                       │  │
│  │ was_correct                                              │  │
│  │ created_at                                               │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 5.3.2 本地数据库 (Drift)

```dart
// lib/shared/database/app_database.dart

import 'package:drift/drift.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// 交易表
@DataClassName('TransactionRecord')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  RealColumn get amount => real()();
  TextColumn get description => text().withLength(min: 1, max: 500)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get subcategoryId => integer().nullable().references(Categories, #id)();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get originalInput => text().nullable()();
  RealColumn get aiConfidence => real().nullable()();
  TextColumn get aiSource => text().withLength(max: 20).withDefault(const Constant('manual'))();
  BoolColumn get userConfirmed => boolean().withDefault(const Constant(false))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// 分类表
@DataClassName('CategoryRecord')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get icon => text().withLength(max: 10).nullable()();
  TextColumn get color => text().withLength(max: 9).withDefault(const Constant('#607D8B'))();
  IntColumn get parentId => integer().nullable().references(Categories, #id)();
  IntColumn get level => integer().withDefault(const Constant(1))();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  BoolColumn get isExpense => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// 预算表
@DataClassName('BudgetRecord')
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get remoteId => text().nullable()();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  RealColumn get amount => real()();
  TextColumn get period => text().withLength(min: 1, max: 20).withDefault(const Constant('monthly'))();
  IntColumn get year => integer()();
  IntColumn get month => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  List<Set<Column>> get uniqueKeys => [{categoryId, year, month}];
}

/// 对话消息表
@DataClassName('ConversationMessageRecord')
class ConversationMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get conversationId => text().withLength(max: 50)();
  TextColumn get role => text().withLength(max: 20)();
  TextColumn get content => text()();
  TextColumn get functionName => text().nullable()();
  TextColumn get functionArgs => text().nullable()();
  TextColumn get functionResult => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// AI训练数据表
@DataClassName('AiTrainingDataRecord')
class AiTrainingData extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get inputText => text()();
  IntColumn get predictedCategoryId => integer().nullable()();
  IntColumn get actualCategoryId => integer().nullable()();
  BoolColumn get wasCorrect => boolean().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [
  Transactions,
  Categories,
  Budgets,
  ConversationMessages,
  AiTrainingData,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _seedDefaultCategories();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // 版本迁移
    },
  );
  
  /// 初始化默认分类
  Future<void> _seedDefaultCategories() async {
    final defaultCategories = [
      {'name': '餐饮', 'icon': '🍜', 'color': '#FF9800', 'sortOrder': 1},
      {'name': '交通', 'icon': '🚗', 'color': '#2196F3', 'sortOrder': 2},
      {'name': '购物', 'icon': '🛒', 'color': '#E91E63', 'sortOrder': 3},
      {'name': '住房', 'icon': '🏠', 'color': '#9C27B0', 'sortOrder': 4},
      {'name': '娱乐', 'icon': '🎮', 'color': '#4CAF50', 'sortOrder': 5},
      {'name': '教育', 'icon': '📚', 'color': '#00BCD4', 'sortOrder': 6},
      {'name': '医疗', 'icon': '💊', 'color': '#F44336', 'sortOrder': 7},
      {'name': '社交', 'icon': '👤', 'color': '#FF5722', 'sortOrder': 8},
      {'name': '其他', 'icon': '💰', 'color': '#607D8B', 'sortOrder': 9},
    ];
    
    for (final cat in defaultCategories) {
      await into(categories).insert(CategoriesCompanion.insert(
        name: cat['name'] as String,
        icon: Value(cat['icon'] as String),
        color: Value(cat['color'] as String),
        isSystem: const Value(true),
        sortOrder: Value(cat['sortOrder'] as int),
      ));
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'wo_account.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
```

---

## 5.4 核心模块设计

### 5.4.1 AI服务模块

```dart
// lib/features/ai/domain/services/ai_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AI服务接口
abstract class AiService {
  /// 解析用户输入
  Future<AiParseResult> parseInput(String input);
  
  /// 识别查询意图
  Future<QueryIntent> recognizeQueryIntent(String query);
  
  /// 对话
  Future<ChatResponse> chat(String message, ConversationContext context);
  
  /// 生成洞察
  Future<List<Insight>> generateInsights(InsightRequest request);
}

/// AI服务实现
class AiServiceImpl implements AiService {
  final RuleEngine _ruleEngine;
  final LlmApiService _llmApi;
  final CategoryRepository _categoryRepo;
  final TransactionRepository _transactionRepo;
  
  AiServiceImpl({
    required RuleEngine ruleEngine,
    required LlmApiService llmApi,
    required CategoryRepository categoryRepo,
    required TransactionRepository transactionRepo,
  })  : _ruleEngine = ruleEngine,
        _llmApi = llmApi,
        _categoryRepo = categoryRepo,
        _transactionRepo = transactionRepo;
  
  @override
  Future<AiParseResult> parseInput(String input) async {
    final stopwatch = Stopwatch()..start();
    
    // 1. 预处理
    final cleaned = _preprocess(input);
    
    // 2. 提取金额
    final amount = _extractAmount(cleaned);
    if (amount == null) {
      throw ValidationException('未识别到金额信息');
    }
    
    // 3. 规则引擎匹配
    final ruleResult = await _ruleEngine.match(cleaned);
    if (ruleResult != null && ruleResult.confidence > 0.85) {
      stopwatch.stop();
      return AiParseResult(
        amount: amount,
        category: ruleResult.category,
        subcategory: ruleResult.subcategory,
        description: cleaned,
        confidence: ruleResult.confidence,
        source: AiSource.rule,
        parseDurationMs: stopwatch.elapsedMilliseconds,
      );
    }
    
    // 4. LLM API调用
    final llmResult = await _llmApi.parseTransaction(cleaned);
    
    // 5. 匹配本地分类
    final category = await _matchCategory(llmResult.categoryName);
    
    stopwatch.stop();
    return AiParseResult(
      amount: amount,
      category: category,
      subcategory: llmResult.subcategory,
      description: llmResult.description,
      confidence: llmResult.confidence,
      source: AiSource.llm,
      parseDurationMs: stopwatch.elapsedMilliseconds,
    );
  }
  
  @override
  Future<ChatResponse> chat(String message, ConversationContext context) async {
    // 构建工具列表
    final tools = [
      AgentTools.createTransaction,
      AgentTools.queryTransactions,
      AgentTools.analyzeSpending,
      AgentTools.setBudget,
    ];
    
    // 调用LLM
    final response = await _llmApi.chatWithTools(
      message: message,
      tools: tools,
      history: context.history,
      systemPrompt: context.buildSystemPrompt(),
    );
    
    // 处理Function Calling
    if (response.hasFunctionCall) {
      final functionResult = await _executeFunction(response.functionCall!);
      return ChatResponse(
        reply: response.reply,
        functionCalls: [functionResult],
      );
    }
    
    return ChatResponse(reply: response.reply);
  }
  
  /// 执行函数调用
  Future<FunctionResult> _executeFunction(FunctionCall call) async {
    switch (call.name) {
      case 'create_transaction':
        return await _executeCreateTransaction(call.arguments);
      case 'query_transactions':
        return await _executeQueryTransactions(call.arguments);
      case 'analyze_spending':
        return await _executeAnalyzeSpending(call.arguments);
      case 'set_budget':
        return await _executeSetBudget(call.arguments);
      default:
        throw Exception('Unknown function: ${call.name}');
    }
  }
  
  /// 执行创建交易
  Future<FunctionResult> _executeCreateTransaction(Map<String, dynamic> args) async {
    final amount = args['amount'] as double;
    final description = args['description'] as String;
    final categoryName = args['category'] as String;
    final dateStr = args['date'] as String?;
    
    final category = await _matchCategory(categoryName);
    final date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
    
    final transaction = Transaction(
      amount: amount,
      description: description,
      categoryId: category.id,
      transactionDate: date,
      aiSource: 'agent',
      userConfirmed: true,
    );
    
    await _transactionRepo.addTransaction(transaction);
    
    return FunctionResult(
      success: true,
      data: transaction.toJson(),
      message: '已创建交易: $description ¥$amount',
    );
  }
  
  /// 执行查询交易
  Future<FunctionResult> _executeQueryTransactions(Map<String, dynamic> args) async {
    final startDate = args['start_date'] != null ? DateTime.parse(args['start_date']) : null;
    final endDate = args['end_date'] != null ? DateTime.parse(args['end_date']) : null;
    final categoryName = args['category'] as String?;
    final keyword = args['keyword'] as String?;
    final minAmount = args['min_amount'] as double?;
    final maxAmount = args['max_amount'] as double?;
    final limit = args['limit'] as int? ?? 20;
    
    final transactions = await _transactionRepo.getTransactions(
      startDate: startDate,
      endDate: endDate,
      keyword: keyword,
      minAmount: minAmount,
      maxAmount: maxAmount,
      limit: limit,
    );
    
    return FunctionResult(
      success: true,
      data: transactions.map((t) => t.toJson()).toList(),
      message: '找到${transactions.length}条记录',
    );
  }
  
  /// 执行分析消费
  Future<FunctionResult> _executeAnalyzeSpending(Map<String, dynamic> args) async {
    final period = args['period'] as String;
    final categoryName = args['category'] as String?;
    final compare = args['compare'] as bool? ?? false;
    
    // 计算日期范围
    final dateRange = _calculateDateRange(period);
    
    // 查询交易
    final transactions = await _transactionRepo.getTransactions(
      startDate: dateRange.start,
      endDate: dateRange.end,
    );
    
    // 计算统计
    final total = transactions.fold(0.0, (sum, t) => sum + t.amount);
    final count = transactions.length;
    final dailyAverage = total / dateRange.duration.inDays;
    
    // 按分类分组
    final byCategory = <String, double>{};
    for (final t in transactions) {
      final categoryName = t.category.name;
      byCategory[categoryName] = (byCategory[categoryName] ?? 0) + t.amount;
    }
    
    return FunctionResult(
      success: true,
      data: {
        'total': total,
        'count': count,
        'daily_average': dailyAverage,
        'by_category': byCategory,
      },
      message: '总消费¥${total.toStringAsFixed(2)}，共$count笔',
    );
  }
  
  /// 预处理文本
  String _preprocess(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[，。！？、]'), '');
  }
  
  /// 提取金额
  double? _extractAmount(String input) {
    final regex = RegExp(r'(\d+\.?\d*)(元|块|¥)?');
    final match = regex.firstMatch(input);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }
  
  /// 匹配分类
  Future<Category> _matchCategory(String categoryName) async {
    final categories = await _categoryRepo.getAllCategories();
    return categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => categories.firstWhere((c) => c.name == '其他'),
    );
  }
  
  /// 计算日期范围
  DateRange _calculateDateRange(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'this_week':
        return DateRange(
          start: now.subtract(Duration(days: now.weekday - 1)),
          end: now,
        );
      case 'last_week':
        return DateRange(
          start: now.subtract(Duration(days: now.weekday + 6)),
          end: now.subtract(Duration(days: now.weekday)),
        );
      case 'this_month':
        return DateRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
      case 'last_month':
        return DateRange(
          start: DateTime(now.year, now.month - 1, 1),
          end: DateTime(now.year, now.month, 0),
        );
      default:
        return DateRange(start: now, end: now);
    }
  }
}

/// AI解析结果
class AiParseResult {
  final double amount;
  final Category category;
  final String? subcategory;
  final String description;
  final double confidence;
  final AiSource source;
  final int parseDurationMs;
  
  const AiParseResult({
    required this.amount,
    required this.category,
    this.subcategory,
    required this.description,
    required this.confidence,
    required this.source,
    required this.parseDurationMs,
  });
}

enum AiSource { rule, llm, cache, agent }
```

### 5.4.2 规则引擎模块

```dart
// lib/features/ai/domain/services/rule_engine.dart

/// 规则引擎
class RuleEngine {
  final List<CategoryRule> _rules;
  
  RuleEngine() : _rules = _initRules();
  
  /// 初始化规则
  static List<CategoryRule> _initRules() {
    return [
      // 餐饮规则
      CategoryRule(
        keywords: ['吃', '饭', '餐', '外卖', '奶茶', '咖啡', '火锅', '烧烤', '拉面', '面', '粉', '米线'],
        category: '餐饮',
        confidence: 0.9,
      ),
      CategoryRule(
        keywords: ['早餐', '午饭', '晚饭', '夜宵', '下午茶'],
        category: '餐饮',
        subcategory: '正餐',
        confidence: 0.95,
      ),
      CategoryRule(
        keywords: ['零食', '薯片', '饼干', '水果', '瓜子'],
        category: '餐饮',
        subcategory: '零食',
        confidence: 0.9,
      ),
      CategoryRule(
        keywords: ['奶茶', '咖啡', '可乐', '果汁', '饮料'],
        category: '餐饮',
        subcategory: '饮料',
        confidence: 0.9,
      ),
      
      // 交通规则
      CategoryRule(
        keywords: ['打车', '滴滴', '出租', '的士'],
        category: '交通',
        subcategory: '打车',
        confidence: 0.95,
      ),
      CategoryRule(
        keywords: ['公交', '地铁', '轻轨', '高铁', '火车', '飞机'],
        category: '交通',
        subcategory: '公共交通',
        confidence: 0.95,
      ),
      CategoryRule(
        keywords: ['加油', '停车', '过路费', 'ETC', '洗车'],
        category: '交通',
        subcategory: '自驾',
        confidence: 0.9,
      ),
      
      // 购物规则
      CategoryRule(
        keywords: ['买', '购', '淘宝', '京东', '拼多多', '超市', '商场'],
        category: '购物',
        confidence: 0.85,
      ),
      CategoryRule(
        keywords: ['衣服', '裤子', '鞋', '帽子', '袜子'],
        category: '购物',
        subcategory: '服饰',
        confidence: 0.9,
      ),
      CategoryRule(
        keywords: ['手机', '电脑', '耳机', '充电器', '数据线'],
        category: '购物',
        subcategory: '数码',
        confidence: 0.9,
      ),
      
      // 住房规则
      CategoryRule(
        keywords: ['房租', '租金', '租房'],
        category: '住房',
        subcategory: '房租',
        confidence: 0.95,
      ),
      CategoryRule(
        keywords: ['水电', '电费', '水费', '燃气', '物业'],
        category: '住房',
        subcategory: '水电煤',
        confidence: 0.95,
      ),
      
      // 娱乐规则
      CategoryRule(
        keywords: ['电影', '游戏', 'KTV', '唱歌', '旅游', '景区', '门票'],
        category: '娱乐',
        confidence: 0.9,
      ),
      CategoryRule(
        keywords: ['健身', '运动', '游泳', '跑步', '瑜伽'],
        category: '娱乐',
        subcategory: '运动',
        confidence: 0.9,
      ),
      
      // 教育规则
      CategoryRule(
        keywords: ['书', '课程', '培训', '学习', '网课'],
        category: '教育',
        confidence: 0.9,
      ),
      
      // 医疗规则
      CategoryRule(
        keywords: ['挂号', '看病', '药', '体检', '医院', '牙科'],
        category: '医疗',
        confidence: 0.95,
      ),
      
      // 社交规则
      CategoryRule(
        keywords: ['红包', '礼物', '聚餐', '请客', 'AA'],
        category: '社交',
        confidence: 0.9,
      ),
    ];
  }
  
  /// 匹配规则
  Future<RuleMatchResult?> match(String input) async {
    for (final rule in _rules) {
      for (final keyword in rule.keywords) {
        if (input.contains(keyword)) {
          return RuleMatchResult(
            category: rule.category,
            subcategory: rule.subcategory,
            confidence: rule.confidence,
            matchedKeyword: keyword,
          );
        }
      }
    }
    return null;
  }
  
  /// 添加用户自定义规则
  void addUserRule(CategoryRule rule) {
    _rules.add(rule);
  }
}

/// 分类规则
class CategoryRule {
  final List<String> keywords;
  final String category;
  final String? subcategory;
  final double confidence;
  
  const CategoryRule({
    required this.keywords,
    required this.category,
    this.subcategory,
    required this.confidence,
  });
}

/// 规则匹配结果
class RuleMatchResult {
  final String category;
  final String? subcategory;
  final double confidence;
  final String matchedKeyword;
  
  const RuleMatchResult({
    required this.category,
    this.subcategory,
    required this.confidence,
    required this.matchedKeyword,
  });
}
```

### 5.4.3 Repository模式

```dart
// lib/features/transaction/domain/repositories/transaction_repo.dart

/// 交易仓储接口
abstract class TransactionRepository {
  /// 获取交易列表
  Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    String? keyword,
    double? minAmount,
    double? maxAmount,
    int limit = 50,
    int offset = 0,
  });
  
  /// 获取单个交易
  Future<Transaction?> getTransaction(int id);
  
  /// 添加交易
  Future<Transaction> addTransaction(Transaction transaction);
  
  /// 更新交易
  Future<Transaction> updateTransaction(Transaction transaction);
  
  /// 删除交易 (软删除)
  Future<void> deleteTransaction(int id);
  
  /// 获取统计
  Future<StatsData> getStats({
    required DateTime startDate,
    required DateTime endDate,
  });
  
  /// 搜索交易
  Future<List<Transaction>> searchTransactions(String query);
}

// lib/features/transaction/data/repositories/transaction_repo_impl.dart

/// 交易仓储实现
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource _localDataSource;
  final TransactionRemoteDataSource? _remoteDataSource;
  
  TransactionRepositoryImpl({
    required TransactionLocalDataSource localDataSource,
    TransactionRemoteDataSource? remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;
  
  @override
  Future<List<Transaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    String? keyword,
    double? minAmount,
    double? maxAmount,
    int limit = 50,
    int offset = 0,
  }) async {
    // 优先从本地获取
    return await _localDataSource.getTransactions(
      startDate: startDate,
      endDate: endDate,
      categoryId: categoryId,
      keyword: keyword,
      minAmount: minAmount,
      maxAmount: maxAmount,
      limit: limit,
      offset: offset,
    );
  }
  
  @override
  Future<Transaction> addTransaction(Transaction transaction) async {
    // 保存到本地
    final localTransaction = await _localDataSource.addTransaction(transaction);
    
    // 异步同步到云端
    _remoteDataSource?.syncTransaction(localTransaction).catchError((e) {
      // 记录同步失败，稍后重试
      print('Sync failed: $e');
    });
    
    return localTransaction;
  }
  
  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final updated = await _localDataSource.updateTransaction(transaction);
    
    _remoteDataSource?.syncTransaction(updated).catchError((e) {
      print('Sync failed: $e');
    });
    
    return updated;
  }
  
  @override
  Future<void> deleteTransaction(int id) async {
    await _localDataSource.deleteTransaction(id);
    
    _remoteDataSource?.deleteTransaction(id).catchError((e) {
      print('Sync failed: $e');
    });
  }
  
  @override
  Future<StatsData> getStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _localDataSource.getStats(
      startDate: startDate,
      endDate: endDate,
    );
  }
  
  @override
  Future<List<Transaction>> searchTransactions(String query) async {
    return await _localDataSource.searchTransactions(query);
  }
}
```

---

## 5.5 状态管理设计

### 5.5.1 Provider定义

```dart
// lib/config/di/providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 数据库Provider
@riverpod
AppDatabase appDatabase(AppDatabaseRef ref) {
  return AppDatabase();
}

/// 交易仓储Provider
@riverpod
TransactionRepository transactionRepo(TransactionRepoRef ref) {
  return TransactionRepositoryImpl(
    localDataSource: TransactionLocalDataSourceImpl(
      database: ref.watch(appDatabaseProvider),
    ),
  );
}

/// 分类仓储Provider
@riverpod
CategoryRepository categoryRepo(CategoryRepoRef ref) {
  return CategoryRepositoryImpl(
    localDataSource: CategoryLocalDataSourceImpl(
      database: ref.watch(appDatabaseProvider),
    ),
  );
}

/// AI服务Provider
@riverpod
AiService aiService(AiServiceRef ref) {
  return AiServiceImpl(
    ruleEngine: ref.watch(ruleEngineProvider),
    llmApi: ref.watch(llmApiProvider),
    categoryRepo: ref.watch(categoryRepoProvider),
    transactionRepo: ref.watch(transactionRepoProvider),
  );
}

/// 规则引擎Provider
@riverpod
RuleEngine ruleEngine(RuleEngineRef ref) {
  return RuleEngine();
}

/// LLM API Provider
@riverpod
LlmApiService llmApi(LlmApiRef ref) {
  return LlmApiServiceImpl(
    apiKey: ref.watch(apiKeyProvider),
    baseUrl: ref.watch(baseUrlProvider),
  );
}

/// API Key Provider
@riverpod
String apiKey(ApiKeyRef ref) {
  return const String.fromEnvironment('AI_API_KEY');
}

/// Base URL Provider
@riverpod
String baseUrl(BaseUrlRef ref) {
  return const String.fromEnvironment('AI_BASE_URL', 
    defaultValue: 'https://dashscope.aliyuncs.com/api/v1');
}
```

### 5.5.2 Feature Provider

```dart
// lib/features/transaction/presentation/providers/transaction_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_provider.g.dart';

/// 今日交易列表
@riverpod
class TodayTransactions extends _$TodayTransactions {
  @override
  Future<List<Transaction>> build() async {
    final repo = ref.watch(transactionRepoProvider);
    return repo.getTransactions(
      startDate: DateTime.now().startOfDay,
      endDate: DateTime.now().endOfDay,
    );
  }
  
  /// 刷新
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

/// 交易操作
@riverpod
class TransactionActions extends _$TransactionActions {
  @override
  void build() {}
  
  /// AI解析并添加交易
  Future<AiParseResult> parseAndAdd(String input) async {
    final aiService = ref.read(aiServiceProvider);
    final repo = ref.read(transactionRepoProvider);
    
    // AI解析
    final result = await aiService.parseInput(input);
    
    // 创建交易
    final transaction = Transaction(
      amount: result.amount,
      description: result.description,
      categoryId: result.category.id,
      transactionDate: DateTime.now(),
      originalInput: input,
      aiConfidence: result.confidence,
      aiSource: result.source.name,
      userConfirmed: true,
    );
    
    // 保存
    await repo.addTransaction(transaction);
    
    // 刷新列表
    ref.invalidate(todayTransactionsProvider);
    
    return result;
  }
  
  /// 删除交易
  Future<void> delete(int id) async {
    final repo = ref.read(transactionRepoProvider);
    await repo.deleteTransaction(id);
    ref.invalidate(todayTransactionsProvider);
  }
  
  /// 更新交易
  Future<void> update(Transaction transaction) async {
    final repo = ref.read(transactionRepoProvider);
    await repo.updateTransaction(transaction);
    ref.invalidate(todayTransactionsProvider);
  }
}
```

---

## 5.6 错误处理

### 5.6.1 异常定义

```dart
// lib/core/errors/app_exception.dart

/// 应用异常基类
sealed class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });
  
  @override
  String toString() => 'AppException: $message (code: $code)';
}

/// 数据库异常
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// AI服务异常
class AiServiceException extends AppException {
  const AiServiceException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// 网络异常
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// 验证异常
class ValidationException extends AppException {
  const ValidationException(String message) : super(message: message);
}

/// 认证异常
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });
}
```

### 5.6.2 错误处理

```dart
// lib/core/errors/error_handler.dart

/// 错误处理器
class ErrorHandler {
  /// 处理异步操作
  static Future<T> handle<T>(
    Future<T> Function() operation, {
    T? fallback,
    String? context,
  }) async {
    try {
      return await operation();
    } on DatabaseException catch (e) {
      _logError(e, context);
      if (fallback != null) return fallback;
      rethrow;
    } on AiServiceException catch (e) {
      _logError(e, context);
      // AI服务异常时尝试降级
      if (fallback != null) return fallback;
      rethrow;
    } on NetworkException catch (e) {
      _logError(e, context);
      // 网络异常时使用本地数据
      if (fallback != null) return fallback;
      rethrow;
    } on ValidationException catch (e) {
      _logError(e, context);
      rethrow;
    } catch (e, stack) {
      _logError(AppException(message: e.toString()), context);
      // 上报Crashlytics
      FirebaseCrashlytics.instance.recordError(e, stack, reason: context);
      rethrow;
    }
  }
  
  static void _logError(AppException error, String? context) {
    print('Error in $context: ${error.message}');
  }
}
```

---

## 5.7 性能优化

### 5.7.1 缓存策略

```dart
// lib/shared/services/cache_service.dart

/// 缓存服务
class CacheService {
  final Map<String, CacheEntry> _cache = {};
  
  /// 获取缓存
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }
    return entry.value as T;
  }
  
  /// 设置缓存
  void set<T>(String key, T value, {Duration ttl = const Duration(minutes: 5)}) {
    _cache[key] = CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl),
    );
  }
  
  /// 删除缓存
  void remove(String key) {
    _cache.remove(key);
  }
  
  /// 清空缓存
  void clear() {
    _cache.clear();
  }
}

class CacheEntry {
  final dynamic value;
  final DateTime expiresAt;
  
  CacheEntry({required this.value, required this.expiresAt});
  
  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
```

### 5.7.2 数据库优化

```dart
// 数据库索引
// 在Drift中通过migration添加索引

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (Migrator m) async {
    await m.createAll();
    // 添加索引
    await m.database.customStatement(
      'CREATE INDEX idx_transactions_date ON transactions(transaction_date DESC)'
    );
    await m.database.customStatement(
      'CREATE INDEX idx_transactions_category ON transactions(category_id)'
    );
    await m.database.customStatement(
      'CREATE INDEX idx_transactions_user_date ON transactions(user_id, transaction_date DESC)'
    );
  },
);
```

---

## 5.8 安全设计

### 5.8.1 数据加密

```dart
// lib/shared/services/encryption_service.dart

import 'package:encrypt/encrypt.dart';

/// 加密服务
class EncryptionService {
  late final Key _key;
  late final IV _iv;
  late final Encrypter _encrypter;
  
  EncryptionService(String secretKey) {
    _key = Key.fromUtf8(secretKey);
    _iv = IV.fromLength(16);
    _encrypter = Encrypter(AES(_key));
  }
  
  /// 加密
  String encrypt(String plainText) {
    return _encrypter.encrypt(plainText, iv: _iv).base64;
  }
  
  /// 解密
  String decrypt(String encryptedText) {
    return _encrypter.decrypt64(encryptedText, iv: _iv);
  }
}
```

### 5.8.2 Token管理

```dart
// lib/shared/services/token_service.dart

/// Token服务
class TokenService {
  final SharedPreferences _prefs;
  
  TokenService(this._prefs);
  
  /// 获取Access Token
  String? get accessToken => _prefs.getString('access_token');
  
  /// 获取Refresh Token
  String? get refreshToken => _prefs.getString('refresh_token');
  
  /// 保存Token
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _prefs.setString('access_token', accessToken);
    await _prefs.setString('refresh_token', refreshToken);
  }
  
  /// 清除Token
  Future<void> clearTokens() async {
    await _prefs.remove('access_token');
    await _prefs.remove('refresh_token');
  }
  
  /// 检查Token是否过期
  bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))
      );
      
      final exp = payload['exp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      return now >= exp;
    } catch (e) {
      return true;
    }
  }
}
```
