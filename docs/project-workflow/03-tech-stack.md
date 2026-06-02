# 03 - 技术选型文档 (Technical Specification)

> **版本**: v3.0 | **更新日期**: 2026-06-02 | **状态**: 已更新为本地优先方案

---

## 3.0 架构策略说明

**当前阶段: 本地优先 (Local-First)**

作为个人开发者、前期自用的场景，采用本地优先策略：

- **数据存储**: 仅使用本地 SQLite (Drift)，无云端数据库
- **认证系统**: 无用户认证，App 打开即用
- **数据同步**: 无多设备同步，数据仅在本机
- **监控分析**: 无 Firebase，通过日志和手动测试验证
- **后端服务**: 无 Supabase/自建后端

**未来扩展路径**: Clean Architecture 分层设计保留了 RemoteDataSource 接口位置，未来需要多设备同步时，只需实现 RemoteDataSource + SyncService，无需重构业务逻辑。

---

## 3.1 技术栈总览

```
┌─────────────────────────────────────────────────────────────────┐
│                      WoAccount 技术栈                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    前端层 (Mobile)                        │   │
│  │  ├── Framework: Flutter 3.x                              │   │
│  │  ├── Language: Dart 3.x                                  │   │
│  │  ├── State Management: Riverpod 2.x                     │   │
│  │  ├── Navigation: go_router 13.x                         │   │
│  │  ├── Local DB: Drift 2.x (SQLite)                       │   │
│  │  ├── HTTP Client: Dio 5.x                               │   │
│  │  └── Charts: fl_chart 0.66.x                            │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    AI层                                  │   │
│  │  ├── Primary: 通义千问 API (qwen-turbo)                 │   │
│  │  ├── Fallback: GPT-4o-mini / Claude-3-haiku             │   │
│  │  ├── Rule Engine: 本地规则引擎                           │   │
│  │  ├── Function Calling: LLM工具调用                       │   │
│  │  └── Prompt Engineering: 场景化Prompt模板                │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    工具层                                │   │
│  │  ├── Version Control: Git + GitHub                       │   │
│  │  ├── CI/CD: GitHub Actions                               │   │
│  │  ├── Design: Figma                                       │   │
│  │  └── IDE: VS Code / Android Studio                       │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3.2 前端技术选型

### 3.2.1 框架对比

| 维度 | Flutter | React Native | Kotlin Multiplatform | 原生开发 |
|------|---------|--------------|---------------------|----------|
| **语言** | Dart | JavaScript/TypeScript | Kotlin | Swift/Kotlin |
| **跨平台** | ✅ iOS/Android/Web/Desktop | ✅ iOS/Android | ✅ iOS/Android | ❌ 需两套代码 |
| **性能** | ⭐⭐⭐⭐⭐ (编译为原生) | ⭐⭐⭐⭐ (JS Bridge) | ⭐⭐⭐⭐⭐ (原生) | ⭐⭐⭐⭐⭐ |
| **UI一致性** | ⭐⭐⭐⭐⭐ (自绘引擎) | ⭐⭐⭐ (平台组件) | ⭐⭐⭐⭐ (Compose Multiplatform) | ⭐⭐⭐ |
| **热重载** | ✅ (毫秒级) | ✅ (Fast Refresh) | ✅ (有限) | ❌ |
| **生态** | ⭐⭐⭐⭐ (pub.dev 40k+包) | ⭐⭐⭐⭐⭐ (npm) | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **学习曲线** | 中 (需学Dart) | 低 (JS/TS) | 中高 | 高 |
| **适合场景** | 跨平台App | 跨平台App | 共享业务逻辑 | 高性能App |

**选择: Flutter**

**技术理由**:
1. **自绘引擎**: 不依赖平台组件，UI一致性最佳
2. **AOT编译**: Release模式编译为原生代码，性能优秀
3. **单代码库**: 一套代码覆盖iOS/Android/Web
4. **热重载**: 毫秒级热重载，开发效率高
5. **Google支持**: 持续更新，生态快速发展

**风险评估**:
| 风险 | 概率 | 影响 | 应对策略 |
|------|------|------|----------|
| Dart语言小众 | 中 | 低 | 学习曲线平缓，文档完善 |
| 原生功能缺失 | 中 | 中 | Platform Channel桥接 |
| 包体积较大 | 中 | 低 | Tree Shaking优化 |

### 3.2.2 依赖清单

```yaml
# pubspec.yaml

name: wo_account
description: AI智能记账App - 本地优先
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.0.0'

dependencies:
  flutter:
    sdk: flutter

  # 状态管理
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

  # 路由
  go_router: ^13.0.0

  # 本地数据库
  drift: ^2.14.1
  sqlite3_flutter_libs: ^0.5.18
  path_provider: ^2.1.2
  path: ^1.8.3

  # 网络请求 (调用LLM API)
  dio: ^5.4.0

  # JSON序列化
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1

  # UI组件
  fl_chart: ^0.66.2
  flutter_slidable: ^3.0.1

  # 国际化
  intl: ^0.19.0

  # 工具
  uuid: ^4.2.2
  shared_preferences: ^2.2.2
  collection: ^1.18.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1

  # 代码生成
  drift_dev: ^2.14.1
  build_runner: ^2.4.8
  riverpod_generator: ^2.3.9
  json_serializable: ^6.7.1
  freezed: ^2.4.6

  # 测试
  mockito: ^5.4.4
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
  generate: true  # 国际化
```

---

## 3.3 状态管理选型

### 3.3.1 方案对比

| 维度 | Riverpod | Bloc | Provider | GetX |
|------|----------|------|----------|------|
| **类型安全** | ✅ 编译时检查 | ✅ | ❌ 运行时 | ❌ |
| **可测试性** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **代码生成** | ✅ (riverpod_generator) | ❌ | ❌ | ❌ |
| **异步支持** | ✅ (AsyncValue) | ✅ | ✅ | ✅ |
| **依赖注入** | ✅ 内置 | ❌ 需额外 | ❌ | ✅ |
| **学习曲线** | 中 | 中高 | 低 | 低 |
| **性能** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

**选择: Riverpod**

**技术理由**:
1. **编译时安全**: 类型错误在编译时发现
2. **代码生成**: 减少样板代码
3. **可测试性**: 易于Mock和单元测试
4. **无BuildContext**: 更灵活的状态访问

### 3.3.2 Riverpod 使用示例

```dart
// lib/features/transaction/providers/transaction_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'transaction_provider.g.dart';

/// 交易列表Provider
@riverpod
class TransactionList extends _$TransactionList {
  @override
  Future<List<Transaction>> build() async {
    final repository = ref.watch(transactionRepositoryProvider);
    return repository.getTransactions(
      startDate: DateTime.now().startOfDay,
      endDate: DateTime.now().endOfDay,
    );
  }
  
  /// 添加交易
  Future<void> addTransaction(String input) async {
    state = const AsyncValue.loading();
    
    state = await AsyncValue.guard(() async {
      final aiService = ref.read(aiServiceProvider);
      final repository = ref.read(transactionRepositoryProvider);
      
      // AI解析
      final result = await aiService.parseInput(input);
      
      // 创建交易
      final transaction = Transaction(
        amount: result.amount!,
        description: result.description,
        categoryId: result.category.id,
        transactionDate: DateTime.now(),
        originalInput: input,
        aiConfidence: result.confidence,
      );
      
      // 保存
      await repository.addTransaction(transaction);
      
      // 刷新列表
      return repository.getTransactions(
        startDate: DateTime.now().startOfDay,
        endDate: DateTime.now().endOfDay,
      );
    });
  }
}

/// AI服务Provider
@riverpod
AiService aiService(AiServiceRef ref) {
  return AiServiceImpl(
    ruleEngine: ref.watch(ruleEngineProvider),
    llmApi: ref.watch(llmApiProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
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
```

---

## 3.4 数据库选型

### 3.4.1 方案对比

| 维度 | SQLite (Drift) | Hive | Isar | Supabase (远程) |
|------|----------------|------|------|-----------------|
| **类型** | 关系型 | KV存储 | NoSQL | 关系型 |
| **SQL支持** | ✅ 完整SQL | ❌ | ❌ | ✅ PostgreSQL |
| **类型安全** | ✅ (Drift) | ❌ | ✅ | ✅ |
| **关系查询** | ✅ | ❌ | ✅ | ✅ |
| **迁移** | ✅ 自动 | ❌ | ✅ | ✅ |
| **性能** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ (网络) |
| **离线** | ✅ | ✅ | ✅ | ❌ |

**选择: SQLite (Drift) 本地**

> 当前阶段仅使用本地 SQLite。未来需要云同步时，可按需接入 Supabase。

### 3.4.2 Drift 数据库定义

```dart
// lib/shared/database/app_database.dart

import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// 交易表
@DataClassName('Transaction')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get description => text().withLength(min: 1, max: 500)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get subcategoryId => integer().nullable().references(Categories, #id)();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get originalInput => text().nullable()();
  RealColumn get aiConfidence => real().nullable()();
  TextColumn get aiSource => text().withLength(max: 20).withDefault(const Constant('manual'))();
  BoolColumn get userConfirmed => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// 分类表
@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
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
@DataClassName('Budget')
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  RealColumn get amount => real()();
  TextColumn get period => text().withLength(min: 1, max: 20).withDefault(const Constant('monthly'))();
  IntColumn get year => integer()();
  IntColumn get month => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  List<Set<Column>> get uniqueKeys => [{categoryId, year, month}];
}

/// AI训练数据表
@DataClassName('AiTrainingData')
class AiTrainingData extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get inputText => text()();
  IntColumn get predictedCategoryId => integer().nullable()();
  IntColumn get actualCategoryId => integer().nullable()();
  BoolColumn get wasCorrect => boolean().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// 对话历史表
@DataClassName('ConversationMessage')
class ConversationMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get conversationId => text().withLength(max: 50)();
  TextColumn get role => text().withLength(max: 20)();  // user, assistant, system, function
  TextColumn get content => text()();
  TextColumn get functionName => text().nullable()();
  TextColumn get functionArgs => text().nullable()();
  TextColumn get functionResult => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [
  Transactions,
  Categories,
  Budgets,
  AiTrainingData,
  ConversationMessages,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _seedCategories();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // 版本迁移逻辑
    },
  );
  
  /// 初始化系统分类
  Future<void> _seedCategories() async {
    final categories = [
      // 餐饮
      CategoriesCompanion.insert(name: '餐饮', icon: '🍜', color: '#FF9800', level: 1, isSystem: const Value(true), sortOrder: const Value(1)),
      CategoriesCompanion.insert(name: '交通', icon: '🚗', color: '#2196F3', level: 1, isSystem: const Value(true), sortOrder: const Value(2)),
      CategoriesCompanion.insert(name: '购物', icon: '🛒', color: '#E91E63', level: 1, isSystem: const Value(true), sortOrder: const Value(3)),
      CategoriesCompanion.insert(name: '住房', icon: '🏠', color: '#9C27B0', level: 1, isSystem: const Value(true), sortOrder: const Value(4)),
      CategoriesCompanion.insert(name: '娱乐', icon: '🎮', color: '#4CAF50', level: 1, isSystem: const Value(true), sortOrder: const Value(5)),
      CategoriesCompanion.insert(name: '教育', icon: '📚', color: '#00BCD4', level: 1, isSystem: const Value(true), sortOrder: const Value(6)),
      CategoriesCompanion.insert(name: '医疗', icon: '💊', color: '#F44336', level: 1, isSystem: const Value(true), sortOrder: const Value(7)),
      CategoriesCompanion.insert(name: '社交', icon: '👤', color: '#FF5722', level: 1, isSystem: const Value(true), sortOrder: const Value(8)),
      CategoriesCompanion.insert(name: '其他', icon: '💰', color: '#607D8B', level: 1, isSystem: const Value(true), sortOrder: const Value(9)),
    ];
    
    for (final category in categories) {
      await into(categories).insert(category);
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

## 3.5 AI服务选型

### 3.5.1 LLM API 对比

| 维度 | 通义千问 | OpenAI GPT | Claude | 文心一言 |
|------|----------|------------|--------|----------|
| **模型** | qwen-turbo | gpt-4o-mini | claude-3-haiku | ernie-speed |
| **价格** | ¥0.008/千token | $0.00015/千token | $0.00025/千token | ¥0.008/千token |
| **国内访问** | ✅ | ❌ | ❌ | ✅ |
| **中文优化** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Function Calling** | ✅ | ✅ | ✅ | ✅ |
| **响应速度** | 快 | 中 | 中 | 快 |
| **稳定性** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

**选择: 通义千问 (主力) + GPT-4o-mini (备选)**

### 3.5.2 AI服务架构

```dart
// lib/shared/services/ai_service.dart

/// AI服务接口
abstract class AiService {
  /// 解析用户输入
  Future<AiParseResult> parseInput(String input);
  
  /// 查询意图识别
  Future<QueryIntent> recognizeQueryIntent(String query);
  
  /// 生成对话回复
  Future<ChatResponse> chat(String message, ConversationContext context);
  
  /// 生成消费洞察
  Future<List<Insight>> generateInsights(InsightRequest request);
}

/// AI服务实现
class AiServiceImpl implements AiService {
  final RuleEngine _ruleEngine;
  final LlmApiService _llmApi;
  final CategoryRepository _categoryRepo;
  
  AiServiceImpl({
    required RuleEngine ruleEngine,
    required LlmApiService llmApi,
    required CategoryRepository categoryRepo,
  })  : _ruleEngine = ruleEngine,
        _llmApi = llmApi,
        _categoryRepo = categoryRepo;
  
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
    // 构建Function Calling请求
    final tools = [
      AgentTools.createTransaction,
      AgentTools.queryTransactions,
      AgentTools.analyzeSpending,
      AgentTools.setBudget,
    ];
    
    final response = await _llmApi.chatWithTools(
      message: message,
      tools: tools,
      history: context.history,
      systemPrompt: context.buildSystemPrompt(),
    );
    
    // 处理Function Calling
    if (response.hasFunctionCall) {
      final functionResult = await _executeFunction(
        response.functionCall!,
      );
      return ChatResponse(
        reply: response.reply,
        functionCalls: [functionResult],
      );
    }
    
    return ChatResponse(reply: response.reply);
  }
  
  /// 提取金额
  double? _extractAmount(String input) {
    final regex = RegExp(r'(\d+\.?\d*)(元|块|¥)?');
    final match = regex.firstMatch(input);
    return match != null ? double.tryParse(match.group(1)!) : null;
  }
  
  /// 预处理文本
  String _preprocess(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[，。！？、]'), '');
  }
  
  /// 匹配本地分类
  Future<Category> _matchCategory(String categoryName) async {
    final categories = await _categoryRepo.getAllCategories();
    return categories.firstWhere(
      (c) => c.name == categoryName,
      orElse: () => categories.firstWhere((c) => c.name == '其他'),
    );
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

enum AiSource { rule, llm, cache }
```

### 3.5.3 LLM API 封装

```dart
// lib/shared/services/llm_api_service.dart

/// LLM API服务
class LlmApiServiceImpl implements LlmApiService {
  final Dio _dio;
  final String _apiKey;
  final String _baseUrl;
  
  LlmApiServiceImpl({
    required String apiKey,
    required String baseUrl,
  })  : _apiKey = apiKey,
        _baseUrl = baseUrl,
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ));
  
  @override
  Future<LlmParseResult> parseTransaction(String input) async {
    final response = await _dio.post('/chat/completions', data: {
      'model': 'qwen-turbo',
      'messages': [
        {
          'role': 'system',
          'content': _buildParseSystemPrompt(),
        },
        {
          'role': 'user',
          'content': '用户输入: $input',
        },
      ],
      'temperature': 0.1,
      'response_format': {'type': 'json_object'},
    });
    
    final content = response.data['choices'][0]['message']['content'];
    final json = jsonDecode(content);
    
    return LlmParseResult.fromJson(json);
  }
  
  @override
  Future<ChatCompletion> chatWithTools({
    required String message,
    required List<FunctionDefinition> tools,
    required List<Message> history,
    required String systemPrompt,
  }) async {
    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...history.map((m) => m.toJson()),
      {'role': 'user', 'content': message},
    ];
    
    final response = await _dio.post('/chat/completions', data: {
      'model': 'qwen-turbo',
      'messages': messages,
      'tools': tools.map((t) => t.toJson()).toList(),
      'tool_choice': 'auto',
      'temperature': 0.7,
    });
    
    return ChatCompletion.fromJson(response.data);
  }
  
  String _buildParseSystemPrompt() {
    return '''你是一个智能记账助手。请分析用户的消费描述，提取以下信息：

1. amount: 金额 (数字)
2. category: 一级分类名称
3. subcategory: 二级分类名称 (可选)
4. description: 精简描述 (10字以内)
5. confidence: 置信度 (0-1)

可用的一级分类: 餐饮, 交通, 购物, 住房, 娱乐, 教育, 医疗, 社交, 其他

请严格按照JSON格式返回:
{
  "amount": 数字,
  "category": "分类名",
  "subcategory": "子分类(可选)",
  "description": "精简描述",
  "confidence": 0-1
}''';
  }
}
```

---

## 3.6 后端服务说明

当前阶段**无后端服务**。所有数据存储在本地 SQLite，AI 功能通过 Dio 直接调用通义千问 API。

**未来扩展方案**: 需要多设备同步时，可接入 Supabase (开源 BaaS)：
- Supabase Auth: 用户认证
- Supabase PostgreSQL: 云端数据存储
- Supabase Realtime: 实时数据同步
- Row Level Security: 多用户数据隔离

**选择: 当前无后端，未来 Supabase**

---

## 3.7 CI/CD 选型

### 3.7.1 GitHub Actions 配置

```yaml
# .github/workflows/ci.yml

name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  FLUTTER_VERSION: '3.19.0'

jobs:
  # 代码检查
  lint:
    name: Lint & Analyze
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Analyze code
        run: flutter analyze --fatal-infos
      
      - name: Check formatting
        run: dart format --set-exit-if-changed .

  # 单元测试
  test:
    name: Unit Tests
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info

  # 构建Android
  build-android:
    name: Build Android
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Build AAB
        run: flutter build appbundle --release
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: android-release
          path: |
            build/app/outputs/flutter-apk/app-release.apk
            build/app/outputs/bundle/release/app-release.aab

  # 构建iOS
  build-ios:
    name: Build iOS
    runs-on: macos-latest
    needs: test
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build iOS
        run: flutter build ios --release --no-codesign
      
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: ios-release
          path: build/ios/iphoneos/Runner.app
```

---

## 3.8 监控说明

当前阶段**无 Firebase 监控**。通过以下方式保障质量：

- **开发阶段**: 单元测试 + 集成测试 + 手动真机测试
- **错误处理**: 应用内全局错误捕获 + 本地日志记录
- **AI 质量**: 内置训练数据表记录用户修正，用于评估准确率

**未来扩展**: 用户量增长后可接入 Firebase Crashlytics + Analytics。

---

## 3.9 性能优化策略

### 3.9.1 前端优化

| 优化点 | 技术方案 | 预期效果 |
|--------|----------|----------|
| **懒加载** | 按需加载页面和数据 | 首屏加载 < 1s |
| **虚拟列表** | ListView.builder + 离屏渲染 | 1000+列表流畅 |
| **图片缓存** | cached_network_image | 图片加载 < 200ms |
| **代码分割** | go_router lazy loading | 包体积减小 |
| **状态优化** | Riverpod select | 减少不必要的rebuild |

### 3.9.2 数据库优化

| 优化点 | 技术方案 | 预期效果 |
|--------|----------|----------|
| **索引** | 关键字段添加索引 | 查询 < 50ms |
| **分页** | LIMIT + OFFSET | 大数据量查询 |
| **缓存** | 内存缓存热点数据 | 重复查询 < 10ms |
| **批量操作** | batch insert/update | 批量操作性能提升 |

### 3.9.3 AI优化

| 优化点 | 技术方案 | 预期效果 |
|--------|----------|----------|
| **规则缓存** | 缓存规则匹配结果 | 相同输入 < 10ms |
| **结果缓存** | 缓存相似输入的解析 | 相似输入 < 50ms |
| **异步处理** | AI解析异步执行 | UI不阻塞 |
| **降级策略** | 规则引擎兜底 | 网络异常可用 |

---

## 3.10 安全策略

### 3.10.1 数据安全

| 层级 | 措施 | 实现方式 |
|------|------|----------|
| **传输层** | HTTPS/TLS 1.3 | LLM API 调用强制 HTTPS |
| **存储层** | 本地存储 | 数据仅存本机 SQLite |
| **应用层** | 输入校验 | 防止 SQL 注入 |

> 当前阶段无用户认证、无云端数据，安全风险集中在 LLM API Key 保护和本地数据完整性。API Key 通过 `--dart-define` 注入，不硬编码在代码中。

---

## 3.11 技术风险评估

| 风险 | 概率 | 影响 | 应对策略 |
|------|------|------|----------|
| Flutter版本兼容 | 低 | 中 | 锁定版本，及时更新 |
| LLM API不稳定 | 中 | 高 | 多服务商备选，规则引擎兜底 |
| 本地数据丢失 | 低 | 高 | 定期导出备份，SQLite 事务保证 |
| 数据库性能瓶颈 | 低 | 中 | 索引优化，分页查询 |
| 国内网络问题 | 中 | 高 | 规则引擎离线可用，选择国内 LLM 服务商 |
| 包体积过大 | 中 | 低 | Tree Shaking，代码分割 |
