# 03 - 技术选型文档 (Technical Specification)

> **版本**: v3.1 | **更新日期**: 2026-06-02 | **状态**: 结合01需求/02竞品分析深化

## 3.0 架构策略说明

### 3.0.1 当前阶段: 本地优先 (Local-First)

基于 01 需求分析（个人开发者、前期自用）和 02 竞品分析（钱迹的本地优先理念、Copilot 的 AI 能力），采用本地优先策略：


| 维度     | 当前方案       | 理由 (来自01/02)                                         |
| -------- | -------------- | -------------------------------------------------------- |
| 数据存储 | SQLite (Drift) | 01: 数据安全是用户核心痛点；02: 钱迹验证了本地优先可行性 |
| 认证系统 | 无             | 01: 单用户场景，零摩擦使用                               |
| 数据同步 | 无             | 01: 单设备，无需同步                                     |
| 监控分析 | 本地日志       | 01: 个人自用，无需 Firebase                              |
| 后端服务 | 无             | 01: 降低运维成本，专注核心功能                           |

### 3.0.2 未来扩展路径

Clean Architecture 分层设计保留了扩展接口，具体扩展步骤：

```
Phase 1 (当前)          Phase 2 (按需)           Phase 3 (用户增长后)
┌─────────────┐        ┌─────────────────┐      ┌─────────────────────┐
│ SQLite 本地  │  ──▶   │ + Supabase 云端  │ ──▶  │ + Firebase 监控      │
│ 无认证       │        │ + Supabase Auth │      │ + 应用商店上架       │
│ 无同步       │        │ + Realtime 同步 │      │ + 多聚合器银行同步   │
└─────────────┘        └─────────────────┘      └─────────────────────┘
```

**扩展时只需**:

1. 实现 `RemoteDataSource` 接口 (Supabase)
2. 添加 `SyncService` (本地→云端同步)
3. 添加 `AuthService` (Supabase Auth)
4. 业务逻辑层**零改动**

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

## 3.2 前端技术选型

### 3.2.1 框架对比


| 维度         | Flutter                    | React Native          | Kotlin Multiplatform             | 原生开发      |
| ------------ | -------------------------- | --------------------- | -------------------------------- | ------------- |
| **语言**     | Dart                       | JavaScript/TypeScript | Kotlin                           | Swift/Kotlin  |
| **跨平台**   | ✅ iOS/Android/Web/Desktop | ✅ iOS/Android        | ✅ iOS/Android                   | ❌ 需两套代码 |
| **性能**     | ⭐⭐⭐⭐⭐ (编译为原生)    | ⭐⭐⭐⭐ (JS Bridge)  | ⭐⭐⭐⭐⭐ (原生)                | ⭐⭐⭐⭐⭐    |
| **UI一致性** | ⭐⭐⭐⭐⭐ (自绘引擎)      | ⭐⭐⭐ (平台组件)     | ⭐⭐⭐⭐ (Compose Multiplatform) | ⭐⭐⭐        |
| **热重载**   | ✅ (毫秒级)                | ✅ (Fast Refresh)     | ✅ (有限)                        | ❌            |
| **生态**     | ⭐⭐⭐⭐ (pub.dev 40k+包)  | ⭐⭐⭐⭐⭐ (npm)      | ⭐⭐⭐                           | ⭐⭐⭐⭐⭐    |
| **学习曲线** | 中 (需学Dart)              | 低 (JS/TS)            | 中高                             | 高            |
| **适合场景** | 跨平台App                  | 跨平台App             | 共享业务逻辑                     | 高性能App     |

**选择: Flutter**

**技术理由**:

1. **自绘引擎**: 不依赖平台组件，UI一致性最佳
2. **AOT编译**: Release模式编译为原生代码，性能优秀
3. **单代码库**: 一套代码覆盖iOS/Android/Web
4. **热重载**: 毫秒级热重载，开发效率高
5. **Google支持**: 持续更新，生态快速发展

**风险评估**:


| 风险         | 概率 | 影响 | 应对策略               |
| ------------ | ---- | ---- | ---------------------- |
| Dart语言小众 | 中   | 低   | 学习曲线平缓，文档完善 |
| 原生功能缺失 | 中   | 中   | Platform Channel桥接   |
| 包体积较大   | 中   | 低   | Tree Shaking优化       |

### 3.2.2 依赖清单

```yaml
# pubspec.yaml

name: wo_account
description: AI智能记账App - 本地优先
version: 1.0.0+1

environment:
  sdk: '>=3.2.0 <4.0.0'    # Dart 3.2+ (Records, Patterns)
  flutter: '>=3.16.0'       # Flutter 3.16+ (Impeller默认启用)

dependencies:
  flutter:
    sdk: flutter

  # === 状态管理 ===
  flutter_riverpod: ^2.5.1       # 响应式状态管理
  riverpod_annotation: ^2.3.5    # 注解支持

  # === 路由 ===
  go_router: ^14.2.0             # 声明式路由

  # === 本地数据库 ===
  drift: ^2.18.0                 # SQLite ORM (类型安全)
  sqlite3_flutter_libs: ^2.0.0   # SQLite 原生库
  path_provider: ^2.1.2          # 应用文档目录
  path: ^1.9.0                   # 路径处理

  # === 网络请求 (调用LLM API) ===
  dio: ^5.6.0                    # HTTP客户端

  # === JSON序列化 ===
  json_annotation: ^4.9.0        # JSON注解
  freezed_annotation: ^2.4.4     # 不可变数据类注解

  # === UI组件 ===
  fl_chart: ^0.68.0              # 图表 (饼图/折线图)
  flutter_slidable: ^3.1.0       # 列表滑动操作

  # === 国际化 ===
  intl: ^0.19.0                  # 日期/货币格式化

  # === 工具 ===
  uuid: ^4.4.0                   # UUID生成
  shared_preferences: ^2.2.3     # 轻量KV存储 (设置项)
  collection: ^1.18.0            # 集合工具

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

  # === 代码生成 ===
  drift_dev: ^2.18.0             # Drift代码生成
  build_runner: ^2.4.9           # 通用代码生成器
  riverpod_generator: ^2.4.0     # Riverpod代码生成
  json_serializable: ^6.8.0      # JSON序列化生成
  freezed: ^2.5.2                # 不可变类生成

  # === 测试 ===
  mockito: ^5.4.4                # Mock框架
  drift_dev: ^2.18.0             # Drift测试支持
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
  generate: true  # 国际化
```

**依赖选型理由** (结合01需求/02竞品):


| 依赖     | 选择理由                                 | 竞品参考                        |
| -------- | ---------------------------------------- | ------------------------------- |
| Drift    | 类型安全ORM，自动迁移，优于Room(Android) | 02: 钱迹用Room，Drift跨平台更优 |
| Riverpod | 编译时安全，代码生成，优于Bloc           | 02: Copilot用Swift原生状态管理  |
| fl_chart | 纯Dart实现，无原生依赖，轻量             | 02: 随手记图表臃肿              |
| Dio      | 拦截器丰富，支持重试/超时                | 01: LLM API需要重试机制         |

## 3.3 状态管理选型

### 3.3.1 方案对比


| 维度         | Riverpod                | Bloc       | Provider  | GetX     |
| ------------ | ----------------------- | ---------- | --------- | -------- |
| **类型安全** | ✅ 编译时检查           | ✅         | ❌ 运行时 | ❌       |
| **可测试性** | ⭐⭐⭐⭐⭐              | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐  | ⭐⭐⭐   |
| **代码生成** | ✅ (riverpod_generator) | ❌         | ❌        | ❌       |
| **异步支持** | ✅ (AsyncValue)         | ✅         | ✅        | ✅       |
| **依赖注入** | ✅ 内置                 | ❌ 需额外  | ❌        | ✅       |
| **学习曲线** | 中                      | 中高       | 低        | 低       |
| **性能**     | ⭐⭐⭐⭐⭐              | ⭐⭐⭐⭐   | ⭐⭐⭐⭐  | ⭐⭐⭐⭐ |

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

## 3.4 数据库选型

### 3.4.1 方案对比


| 维度         | SQLite (Drift) | Hive       | Isar       | Supabase (远程) |
| ------------ | -------------- | ---------- | ---------- | --------------- |
| **类型**     | 关系型         | KV存储     | NoSQL      | 关系型          |
| **SQL支持**  | ✅ 完整SQL     | ❌         | ❌         | ✅ PostgreSQL   |
| **类型安全** | ✅ (Drift)     | ❌         | ✅         | ✅              |
| **关系查询** | ✅             | ❌         | ✅         | ✅              |
| **迁移**     | ✅ 自动        | ❌         | ✅         | ✅              |
| **性能**     | ⭐⭐⭐⭐⭐     | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ (网络) |
| **离线**     | ✅             | ✅         | ✅         | ❌              |

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

## 3.5 AI服务选型

### 3.5.1 LLM API 对比 (国内模型优先)

基于 01 需求（国内网络问题概率"中"）和 02 竞品分析，优先选择国内 LLM 服务商，确保直连无障碍。


| 维度                 | DeepSeek (主力)     | 通义千问 (备选) | 文心一言 (备选) |
| -------------------- | ------------------- | --------------- | --------------- |
| **模型**             | deepseek-chat       | qwen-turbo      | ernie-speed     |
| **价格**             | ¥1/百万token       | ¥0.008/千token | ¥0.008/千token |
| **国内访问**         | ✅ 直连             | ✅ 直连         | ✅ 直连         |
| **中文优化**         | ⭐⭐⭐⭐⭐          | ⭐⭐⭐⭐⭐      | ⭐⭐⭐⭐⭐      |
| **Function Calling** | ✅ 原生             | ✅ 原生         | ✅ 原生         |
| **JSON模式**         | ✅                  | ✅              | ✅              |
| **响应速度**         | 快 (<1s)            | 快 (<1s)        | 快 (<1s)        |
| **稳定性**           | ⭐⭐⭐⭐⭐          | ⭐⭐⭐⭐⭐      | ⭐⭐⭐⭐        |
| **性价比**           | ⭐⭐⭐⭐⭐ (最便宜) | ⭐⭐⭐⭐        | ⭐⭐⭐⭐        |
| **推理能力**         | ⭐⭐⭐⭐⭐ (最强)   | ⭐⭐⭐⭐        | ⭐⭐⭐⭐        |

**选择: DeepSeek (主力) + 通义千问 (备选)**

**理由**:

- **DeepSeek**: 性价比最高，推理能力强，国内直连，Function Calling 支持好
- **通义千问**: 阿里云生态，稳定性极高，中文优化好，作为可靠备选
- **兜底**: 本地规则引擎，离线可用，零成本

### 3.5.2 多级 Fallback 策略

```
用户输入
    │
    ▼
┌─────────────────┐    命中(confidence>0.85)    ┌─────────────┐
│ L1: 规则引擎     │ ──────────────────────────▶ │ 返回结果     │
│ (本地, 离线)     │                              │ <10ms       │
└────────┬────────┘                              └─────────────┘
         │ 未命中 / confidence<0.85
         ▼
┌─────────────────┐    成功                       ┌─────────────┐
│ L2: DeepSeek API │ ──────────────────────────▶ │ 返回结果     │
│ (主力, 在线)     │                              │ <1s         │
└────────┬────────┘                              └─────────────┘
         │ 失败 / 超时(3s)
         ▼
┌─────────────────┐    成功                       ┌─────────────┐
│ L3: 通义千问 API │ ──────────────────────────▶ │ 返回结果     │
│ (备选, 在线)     │                              │ <1s         │
└────────┬────────┘                              └─────────────┘
         │ 失败
         ▼
┌─────────────────┐
│ L4: 规则引擎     │ (兜底, 返回低置信度结果)
│ (降级, 离线)     │
└─────────────────┘
```

**Fallback 规则**:

1. **L1 规则引擎**: 离线优先，命中率约 60-70%，响应 <10ms
2. **L2 DeepSeek**: 主力在线服务，超时 3s
3. **L3 通义千问**: 备选在线服务，超时 3s
4. **L4 规则引擎降级**: 所有在线服务失败时，返回低置信度结果，用户可手动修正

### 3.5.3 Fallback 配置

```dart
// lib/config/ai_config.dart

class AiConfig {
  /// LLM服务商优先级 (国内模型优先)
  static const providers = [
    LlmProvider(
      name: 'deepseek',
      baseUrl: 'https://api.deepseek.com/v1',
      model: 'deepseek-chat',
      apiKeyEnv: 'DEEPSEEK_API_KEY',
      timeout: Duration(seconds: 3),
      isPrimary: true,
    ),
    LlmProvider(
      name: 'qwen',
      baseUrl: 'https://dashscope.aliyuncs.com/api/v1',
      model: 'qwen-turbo',
      apiKeyEnv: 'QWEN_API_KEY',
      timeout: Duration(seconds: 3),
      isPrimary: false,
    ),
  ];

  /// 规则引擎置信度阈值
  static const double ruleConfidenceThreshold = 0.85;

  /// LLM超时后降级到规则引擎
  static const Duration llmTimeout = Duration(seconds: 3);

  /// 是否启用规则引擎兜底
  static const bool enableRuleFallback = true;
}
```

### 3.5.4 兜底方案详解


| 场景              | 处理方式                | 用户体验                       |
| ----------------- | ----------------------- | ------------------------------ |
| **无网络**        | 规则引擎直接处理        | 离线可用，准确率约 60-70%      |
| **DeepSeek 超时** | 自动切换通义千问        | 无感知，延迟增加约 1s          |
| **两家都失败**    | 规则引擎降级处理        | 返回低置信度结果，提示用户确认 |
| **API Key 无效**  | 规则引擎 + 提示用户配置 | 离线可用，设置页提示           |
| **LLM 返回异常**  | 规则引擎兜底 + 记录错误 | 离线可用，后台记录异常         |

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

### 3.5.5 LLM API 封装 (多服务商 Fallback)

```dart
// lib/shared/services/llm_api_service.dart

/// LLM API服务 (支持多服务商Fallback)
class LlmApiServiceImpl implements LlmApiService {
  final List<LlmProvider> _providers;
  final RuleEngine _ruleEngine;

  LlmApiServiceImpl({
    required List<LlmProvider> providers,
    required RuleEngine ruleEngine,
  })  : _providers = providers,
        _ruleEngine = ruleEngine;

  /// 带Fallback的LLM调用
  Future<T> _callWithFallback<T>(
    Future<T> Function(LlmProvider provider) call,
  ) async {
    for (final provider in _providers) {
      try {
        return await call(provider).timeout(
          provider.timeout,
          onTimeout: () => throw TimeoutException('LLM timeout'),
        );
      } catch (e) {
        continue; // 尝试下一个服务商
      }
    }
    throw AiServiceException('所有LLM服务商均不可用');
  }

  @override
  Future<LlmParseResult> parseTransaction(String input) async {
    return _callWithFallback((provider) async {
      final dio = Dio(BaseOptions(
        baseUrl: provider.baseUrl,
        headers: {
          'Authorization': 'Bearer ${provider.apiKey}',
          'Content-Type': 'application/json',
        },
      ));

      final response = await dio.post('/chat/completions', data: {
        'model': provider.model,
        'messages': [
          {'role': 'system', 'content': _buildParseSystemPrompt()},
          {'role': 'user', 'content': '用户输入: $input'},
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

## 3.6 AI 能力扩展与优化策略

### 3.6.1 检索速度优化

#### 本地缓存层 (L1 Cache)

```
用户输入 → 缓存查询 → 命中? → 返回缓存结果 (<1ms)
                  │
                  └─ 未命中 → LLM API → 缓存结果 → 返回
```

```dart
// lib/shared/services/ai_cache_service.dart

class AiCacheService {
  final Map<String, CacheEntry> _cache = {};
  final AppDatabase _db;

  AiCacheService(this._db);

  /// 精确匹配缓存
  AiParseResult? get(String input) {
    final key = _normalize(input);
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.result;
    }
    return null;
  }

  /// 语义相似度匹配 (基于编辑距离)
  AiParseResult? getSimilar(String input, {double threshold = 0.85}) {
    final normalized = _normalize(input);
    for (final entry in _cache.entries) {
      if (entry.value.isExpired) continue;
      final similarity = _calculateSimilarity(normalized, entry.key);
      if (similarity >= threshold) {
        return entry.value.result;
      }
    }
    return null;
  }

  /// 规范化输入 (去空格、标点、统一数字格式)
  String _normalize(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[，。！？、元块¥]'), '')
        .replaceAll(RegExp(r'(\d+)块', caseSensitive: false), r'$1元')
        .toLowerCase();
  }
}
```

**缓存策略**:

- 精确匹配: 相同输入直接返回 (<1ms)
- 相似匹配: 编辑距离 > 0.85 返回缓存 (<5ms)
- 缓存淘汰: LRU + 过期时间 (24h)

#### 本地规则引擎优化 (L2 Cache)

```dart
// lib/features/ai/domain/services/rule_engine.dart

class RuleEngine {
  final List<CategoryRule> _systemRules;  // 系统预设规则
  final List<CategoryRule> _userRules;    // 用户学习规则

  /// 从用户修正数据中学习新规则
  Future<void> learnFromCorrections() async {
    final corrections = await _db.getRecentCorrections(limit: 100);
    final patterns = _extractPatterns(corrections);

    for (final pattern in patterns) {
      if (pattern.confidence > 0.9 && pattern.count >= 3) {
        _userRules.add(CategoryRule(
          keywords: pattern.keywords,
          category: pattern.category,
          confidence: pattern.confidence,
          isLearned: true,
        ));
      }
    }
  }

  /// 规则优先级: 用户规则 > 系统规则
  Future<RuleMatchResult?> match(String input) async {
    // 1. 先查用户学习的规则 (更精准)
    for (final rule in _userRules) {
      if (rule.matches(input)) {
        return RuleMatchResult(
          category: rule.category,
          confidence: rule.confidence,
          source: 'user_rule',
        );
      }
    }
    // 2. 再查系统预设规则
    for (final rule in _systemRules) {
      if (rule.matches(input)) {
        return RuleMatchResult(
          category: rule.category,
          confidence: rule.confidence,
          source: 'system_rule',
        );
      }
    }
    return null;
  }
}
```

**优化效果**:

- 初始命中率: 60-70% (系统规则)
- 使用 1 个月后: 80-90% (用户规则学习)
- 使用 3 个月后: 90%+ (规则库完善)

### 3.6.2 检索准确率优化

#### RAG (检索增强生成)

当用户查询历史账单时，先检索相关数据，再让 LLM 基于数据生成回答：

```
用户查询: "这个月餐饮花了多少？"
    │
    ▼
┌─────────────────┐
│ 1. 意图识别      │  → intent: query_spending, category: 餐饮, period: this_month
└────────┬────────┘
         ▼
┌─────────────────┐
│ 2. 本地数据检索  │  → SQL: SELECT SUM(amount) FROM transactions WHERE category='餐饮' AND ...
└────────┬────────┘
         ▼
┌─────────────────┐
│ 3. 构建上下文    │  → "本月餐饮消费2340元，共45笔，日均78元..."
└────────┬────────┘
         ▼
┌─────────────────┐
│ 4. LLM 生成回复  │  → "本月餐饮共消费2,340元，日均78元。其中外卖占51%..."
└─────────────────┘
```

**优势**: LLM 不需要"记住"所有数据，只需基于检索结果生成自然语言回复。数据越查越准。

#### Function Calling 优化

```dart
// 工具定义 (给LLM用)
final tools = [
  FunctionDefinition(
    name: 'query_transactions',
    description: '查询历史账单记录',
    parameters: {
      'type': 'object',
      'properties': {
        'start_date': {'type': 'string', 'description': '开始日期'},
        'end_date': {'type': 'string', 'description': '结束日期'},
        'category': {'type': 'string', 'description': '分类名称'},
        'keyword': {'type': 'string', 'description': '关键词'},
        'min_amount': {'type': 'number', 'description': '最小金额'},
        'max_amount': {'type': 'number', 'description': '最大金额'},
      },
    },
  ),
  // ... 更多工具
];
```

**优化点**:

- 工具描述越精确，LLM 调用越准确
- 参数类型约束，减少 LLM 返回错误格式
- 多轮对话上下文，减少重复查询

### 3.6.3 未来进阶方案

#### 方案 A: 本地向量数据库 (语义检索)

```
当前: 关键词匹配 (规则引擎)
未来: 语义相似度匹配 (向量数据库)

用户输入: "中午吃了碗面"  →  向量化  →  与历史记录向量比较  →  找到最相似记录
```


| 技术            | 方案           | 适用场景           |
| --------------- | -------------- | ------------------ |
| **SQLite FTS5** | 全文搜索扩展   | 关键词检索，零依赖 |
| **sqlite-vss**  | SQLite向量扩展 | 语义检索，轻量     |
| **Hive + 嵌入** | 本地向量存储   | 大规模语义检索     |

**推荐**: SQLite FTS5 (零依赖，够用)

#### 方案 B: 本地小模型 (离线AI)

```
当前: 规则引擎 (关键词匹配)
未来: 本地小模型 (语义理解)

用户输入: "中午吃了碗面"  →  本地ML模型  →  分类: 餐饮/午餐, 金额: 25
```


| 技术                | 方案       | 模型大小 | 准确率 |
| ------------------- | ---------- | -------- | ------ |
| **TensorFlow Lite** | 轻量ML框架 | 5-20MB   | 80%+   |
| **ONNX Runtime**    | 跨平台推理 | 10-30MB  | 85%+   |
| **Core ML**         | Apple原生  | 5-15MB   | 85%+   |

**推荐**: TensorFlow Lite (跨平台，社区活跃)

#### 方案 C: 微调模型 (个性化)

```
用户修正数据 → 训练数据集 → 微调小模型 → 部署到本地
```


| 阶段   | 数据量    | 时间  | 效果            |
| ------ | --------- | ----- | --------------- |
| 冷启动 | 0-100条   | 0     | 规则引擎 60-70% |
| 初期   | 100-500条 | 1-2周 | 规则学习 80-90% |
| 成熟   | 500+条    | 1-3月 | 本地模型 90%+   |

### 3.6.4 优化路线图

```
Phase 1 (当前)          Phase 2 (3个月后)        Phase 3 (6个月后)
┌─────────────┐        ┌─────────────────┐      ┌─────────────────┐
│ 规则引擎     │  ──▶   │ + 用户规则学习   │ ──▶  │ + SQLite FTS5   │
│ LLM API     │        │ + 本地缓存      │      │ + 本地小模型    │
│ RAG检索      │        │ + RAG优化       │      │ + 微调模型      │
└─────────────┘        └─────────────────┘      └─────────────────┘
准确率: 60-70%          准确率: 80-90%            准确率: 90%+
响应: <1s (在线)        响应: <500ms (缓存命中)   响应: <100ms (本地)
```

## 3.7 后端服务说明

当前阶段**无后端服务**。所有数据存储在本地 SQLite，AI 功能通过 Dio 直接调用通义千问 API。

**选择: 当前无后端，未来 Supabase**

### 3.6.1 未来扩展: Supabase 集成方案

基于 02 竞品分析，Actual Budget 的本地优先+CRDT同步方案验证了"本地优先+可选云同步"的可行性。

**扩展触发条件**:

- 用户需要多设备同步
- 用户量增长需要后端支持
- 需要银行账单自动导入

**扩展步骤**:


| 步骤 | 内容                              | 影响范围        |
| ---- | --------------------------------- | --------------- |
| 1    | 添加`supabase_flutter` 依赖       | pubspec.yaml    |
| 2    | 实现`RemoteDataSource` 接口       | data层          |
| 3    | 添加`SyncService` (本地→云端)    | shared/services |
| 4    | 添加`AuthService` (Supabase Auth) | features/auth   |
| 5    | 配置 RLS (Row Level Security)     | Supabase 控制台 |
| 6    | 业务逻辑层**零改动**              | 无影响          |

**Repository 层扩展示例**:

```dart
// 当前: 仅本地
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource _localDataSource;
  // ...
}

// 未来: 本地+云端
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource _localDataSource;
  final TransactionRemoteDataSource? _remoteDataSource;  // 新增

  @override
  Future<Transaction> addTransaction(Transaction transaction) async {
    final local = await _localDataSource.addTransaction(transaction);
    _remoteDataSource?.syncTransaction(local).catchError((e) {
      // 同步失败，稍后重试
    });
    return local;
  }
}
```

### 3.6.2 未来扩展: 银行同步

基于 02 竞品分析，YNAB/Monarch/Copilot 的银行同步是核心差异点。

**方案**:

- 海外: Plaid / MX / Finicity (多聚合器)
- 国内: 微信/支付宝账单导入 (CSV解析)
- 开源: SimpleFIN / GoCardless

**实现**: 添加 `BankSyncService`，通过 CSV/OFX 导入银行账单，AI 自动分类。

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

## 3.8 监控说明

当前阶段**无 Firebase 监控**。通过以下方式保障质量：

- **开发阶段**: 单元测试 + 集成测试 + 手动真机测试
- **错误处理**: 应用内全局错误捕获 + 本地日志记录
- **AI 质量**: 内置训练数据表记录用户修正，用于评估准确率

**未来扩展**: 用户量增长后可接入 Firebase Crashlytics + Analytics。

## 3.9 性能优化策略

### 3.9.1 前端优化


| 优化点       | 技术方案                    | 预期效果            |
| ------------ | --------------------------- | ------------------- |
| **懒加载**   | 按需加载页面和数据          | 首屏加载 < 1s       |
| **虚拟列表** | ListView.builder + 离屏渲染 | 1000+列表流畅       |
| **图片缓存** | cached_network_image        | 图片加载 < 200ms    |
| **代码分割** | go_router lazy loading      | 包体积减小          |
| **状态优化** | Riverpod select             | 减少不必要的rebuild |

### 3.9.2 数据库优化


| 优化点       | 技术方案            | 预期效果         |
| ------------ | ------------------- | ---------------- |
| **索引**     | 关键字段添加索引    | 查询 < 50ms      |
| **分页**     | LIMIT + OFFSET      | 大数据量查询     |
| **缓存**     | 内存缓存热点数据    | 重复查询 < 10ms  |
| **批量操作** | batch insert/update | 批量操作性能提升 |

### 3.9.3 AI优化


| 优化点       | 技术方案           | 预期效果        |
| ------------ | ------------------ | --------------- |
| **规则缓存** | 缓存规则匹配结果   | 相同输入 < 10ms |
| **结果缓存** | 缓存相似输入的解析 | 相似输入 < 50ms |
| **异步处理** | AI解析异步执行     | UI不阻塞        |
| **降级策略** | 规则引擎兜底       | 网络异常可用    |

## 3.10 安全策略

### 3.10.1 数据安全


| 层级       | 措施          | 实现方式               |
| ---------- | ------------- | ---------------------- |
| **传输层** | HTTPS/TLS 1.3 | LLM API 调用强制 HTTPS |
| **存储层** | 本地存储      | 数据仅存本机 SQLite    |
| **应用层** | 输入校验      | 防止 SQL 注入          |

> 当前阶段无用户认证、无云端数据，安全风险集中在 LLM API Key 保护和本地数据完整性。API Key 通过 `--dart-define` 注入，不硬编码在代码中。

## 3.11 技术风险评估

基于 01 需求分析的风险评估和 02 竞品分析的技术壁垒，更新风险矩阵：


| 风险            | 概率 | 影响 | 应对策略                           | 竞品参考                      |
| --------------- | ---- | ---- | ---------------------------------- | ----------------------------- |
| Flutter版本兼容 | 低   | 中   | 锁定版本，及时更新                 | 02: 微力记账用Flutter验证可行 |
| LLM API不稳定   | 中   | 高   | 多服务商fallback，规则引擎兜底     | 01: 风险评估"中"              |
| 本地数据丢失    | 低   | 高   | 定期CSV导出备份，SQLite事务保证    | 02: 钱迹本地优先已验证        |
| 数据库性能瓶颈  | 低   | 中   | 索引优化，分页查询，虚拟列表       | 01: 性能需求<2s               |
| 国内网络问题    | 中   | 高   | 规则引擎离线可用，通义千问国内直连 | 01: 风险评估"中"              |
| 包体积过大      | 中   | 低   | Tree Shaking，代码分割             | 02: 简单记账轻量化验证        |
| AI准确率不达标  | 中   | 高   | 规则引擎兜底，用户反馈学习         | 01: 风险评估"中"              |
| LLM API成本     | 低   | 低   | 规则引擎减少调用，缓存相似输入     | 01: 个人用量极小              |
