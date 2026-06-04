# WoAccount 后端架构设计（数据层）

> **版本**: v1.0 | **创建日期**: 2026-06-04 | **技术栈**: Drift (SQLite) + Repository模式

---

## 1. 整体架构

WoAccount采用**无后端架构**，所有数据存储在本地SQLite数据库中。

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App                            │
│  ┌─────────────────────────────────────────────────────┐│
│  │              Riverpod状态管理                        ││
│  └───────────────────────────┬─────────────────────────┘│
│                              │                           │
│  ┌───────────────────────────▼─────────────────────────┐│
│  │              Repository层（抽象）                     ││
│  │  TransactionRepository / CategoryRepository / ...    ││
│  └───────────────────────────┬─────────────────────────┘│
│                              │                           │
│  ┌───────────────────────────▼─────────────────────────┐│
│  │              Drift（SQLite ORM）                      ││
│  │  AppDatabase → Tables → Queries                      ││
│  └───────────────────────────┬─────────────────────────┘│
│                              │                           │
│  ┌───────────────────────────▼─────────────────────────┐│
│  │              SQLite数据库文件                         ││
│  │  woaccount.db（存储在应用沙盒内）                     ││
│  └─────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────┘
```

---

## 2. 数据库设计（Drift）

### 2.1 为什么选择Drift？

| 特性 | 说明 |
|------|------|
| **类型安全** | 编译时检查SQL语句 |
| **响应式** | 支持Stream监听数据变化 |
| **迁移支持** | 自动数据库版本迁移 |
| **代码生成** | 减少手写样板代码 |

### 2.2 数据表设计

#### 分类表（categories）

```dart
// lib/config/database/tables/categories.dart

@DataClassName('Category')
class Categories extends Table {
  // 主键
  IntColumn get id => integer().autoIncrement()();
  
  // 分类名称
  TextColumn get name => text().withLength(min: 1, max: 50)();
  
  // 图标（emoji）
  TextColumn get icon => text().nullable()();
  
  // 颜色（hex值）
  TextColumn get color => text().withDefault(const Constant('#607D8B'))();
  
  // 类型：expense/income/other
  TextColumn get type => text().withLength(min: 1, max: 20)();
  
  // 父分类ID（支持二级分类）
  IntColumn get parentId => integer().nullable().references(Categories, #id)();
  
  // 层级：1=一级，2=二级
  IntColumn get level => integer().withDefault(const Constant(1))();
  
  // 是否系统预设
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  
  // 排序顺序
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  
  // 是否已删除（软删除）
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  // 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

#### 交易记录表（transactions）

```dart
// lib/config/database/tables/transactions.dart

@DataClassName('Transaction')
class Transactions extends Table {
  // 主键
  IntColumn get id => integer().autoIncrement()();
  
  // 金额
  RealColumn get amount => real()();
  
  // 描述
  TextColumn get description => text().nullable()();
  
  // 备注
  TextColumn get note => text().nullable()();
  
  // 分类ID
  IntColumn get categoryId => integer().references(Categories, #id)();
  
  // 子分类ID
  IntColumn get subcategoryId => integer().nullable().references(Categories, #id)();
  
  // 交易日期
  DateTimeColumn get transactionDate => dateTime()();
  
  // 类型：expense/income/other
  TextColumn get type => text().withLength(min: 1, max: 20)();
  
  // 账本ID
  IntColumn get accountBookId => integer().nullable().references(AccountBooks, #id)();
  
  // AI解析相关
  TextColumn get originalInput => text().nullable()();  // 原始输入
  RealColumn get aiConfidence => real().nullable()();    // AI置信度
  TextColumn get aiSource => text().nullable()();        // AI来源（manual/ai/voice）
  
  // 是否已确认
  BoolColumn get isConfirmed => boolean().withDefault(const Constant(true))();
  
  // 是否已删除（软删除）
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  // 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

#### 账本表（account_books）

```dart
// lib/config/database/tables/account_books.dart

@DataClassName('AccountBook')
class AccountBooks extends Table {
  // 主键
  IntColumn get id => integer().autoIncrement()();
  
  // 账本名称
  TextColumn get name => text().withLength(min: 1, max: 50)();
  
  // 账本类型：personal/family/travel/business
  TextColumn get type => text().withLength(min: 1, max: 20)();
  
  // 描述
  TextColumn get description => text().nullable()();
  
  // 图标
  TextColumn get icon => text().nullable()();
  
  // 是否默认账本
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  
  // 是否已删除
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  // 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

#### 预算表（budgets）

```dart
// lib/config/database/tables/budgets.dart

@DataClassName('Budget')
class Budgets extends Table {
  // 主键
  IntColumn get id => integer().autoIncrement()();
  
  // 预算金额
  RealColumn get amount => real()();
  
  // 预算类型：month/week/day
  TextColumn get type => text().withLength(min: 1, max: 20)();
  
  // 分类ID（null表示总预算）
  IntColumn get categoryId => integer().nullable().references(Categories, #id)();
  
  // 账本ID
  IntColumn get accountBookId => integer().nullable().references(AccountBooks, #id)();
  
  // 开始日期
  DateTimeColumn get startDate => dateTime()();
  
  // 结束日期
  DateTimeColumn get endDate => dateTime()();
  
  // 是否已删除
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  
  // 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

#### AI学习记录表（ai_training_data）

```dart
// lib/config/database/tables/ai_training_data.dart

@DataClassName('AiTrainingData')
class AiTrainingData extends Table {
  // 主键
  IntColumn get id => integer().autoIncrement()();
  
  // 用户输入
  TextColumn get inputText => text()();
  
  // AI预测的分类ID
  IntColumn get predictedCategoryId => integer().nullable()();
  
  // 用户实际选择的分类ID
  IntColumn get actualCategoryId => integer().nullable()();
  
  // 预测是否正确
  BoolColumn get wasCorrect => boolean().nullable()();
  
  // AI置信度
  RealColumn get aiConfidence => real().nullable()();
  
  // AI来源
  TextColumn get aiSource => text().nullable()();
  
  // 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

#### 用户设置表（user_settings）

```dart
// lib/config/database/tables/user_settings.dart

@DataClassName('UserSetting')
class UserSettings extends Table {
  // 主键
  TextColumn get key => text()();
  
  // 值
  TextColumn get value => text()();
  
  // 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {key};
}
```

### 2.3 数据库配置

```dart
// lib/config/database/app_database.dart

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Categories,
  Transactions,
  AccountBooks,
  Budgets,
  AiTrainingData,
  UserSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _seedDefaultData();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // 数据库升级逻辑
    },
  );
  
  // 插入默认数据
  Future<void> _seedDefaultData() async {
    // 插入默认分类
    await into(categories).insert(Category(
      id: 1,
      name: '餐饮',
      icon: '🍜',
      color: '#FF9800',
      type: 'expense',
      level: 1,
      isSystem: true,
      sortOrder: 1,
    ));
    // ... 更多默认分类
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'woaccount.db'));
    return NativeDatabase(file);
  });
}
```

---

## 3. Repository模式

### 3.1 Repository接口（Domain层）

```dart
// lib/features/transaction/domain/repositories/transaction_repository.dart

abstract class TransactionRepository {
  // 获取所有交易
  Future<List<Transaction>> getAll();
  
  // 根据ID获取
  Future<Transaction?> getById(int id);
  
  // 根据日期范围获取
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end);
  
  // 根据分类获取
  Future<List<Transaction>> getByCategoryId(int categoryId);
  
  // 获取今日交易
  Future<List<Transaction>> getToday();
  
  // 获取本周交易
  Future<List<Transaction>> getThisWeek();
  
  // 获取本月交易
  Future<List<Transaction>> getThisMonth();
  
  // 插入交易
  Future<int> insert(TransactionsCompanion transaction);
  
  // 更新交易
  Future<bool> update(TransactionsCompanion transaction);
  
  // 删除交易（软删除）
  Future<bool> delete(int id);
  
  // 监听交易变化
  Stream<List<Transaction>> watchAll();
  
  // 监听今日交易
  Stream<List<Transaction>> watchToday();
  
  // 获取统计
  Future<TransactionStats> getStats(DateTime start, DateTime end);
}

// 统计数据类
class TransactionStats {
  final double totalExpense;
  final double totalIncome;
  final double balance;
  final int count;
  
  const TransactionStats({
    required this.totalExpense,
    required this.totalIncome,
    required this.balance,
    required this.count,
  });
}
```

### 3.2 Repository实现（Data层）

```dart
// lib/features/transaction/data/repositories/transaction_repository_impl.dart

class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase _database;
  
  TransactionRepositoryImpl(this._database);
  
  @override
  Future<List<Transaction>> getAll() async {
    return await (_database.select(_database.transactions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }
  
  @override
  Future<Transaction?> getById(int id) async {
    return await (_database.select(_database.transactions)
          ..where((t) => t.id.equals(id) & t.isDeleted.equals(false)))
        .getSingleOrNull();
  }
  
  @override
  Future<List<Transaction>> getByDateRange(DateTime start, DateTime end) async {
    return await (_database.select(_database.transactions)
          ..where((t) => 
              t.transactionDate.isBetweenValues(start, end) &
              t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }
  
  @override
  Future<List<Transaction>> getToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return await getByDateRange(startOfDay, endOfDay);
  }
  
  @override
  Future<List<Transaction>> getThisWeek() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfDay = startOfDay.add(const Duration(days: 7));
    return await getByDateRange(startOfDay, endOfDay);
  }
  
  @override
  Future<List<Transaction>> getThisMonth() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);
    return await getByDateRange(startOfMonth, endOfMonth);
  }
  
  @override
  Future<int> insert(TransactionsCompanion transaction) async {
    return await _database.into(_database.transactions).insert(transaction);
  }
  
  @override
  Future<bool> update(TransactionsCompanion transaction) async {
    return await _database.update(_database.transactions).replace(transaction);
  }
  
  @override
  Future<bool> delete(int id) async {
    final result = await (_database.update(_database.transactions)
          ..where((t) => t.id.equals(id)))
        .write(TransactionsCompanion(
      isDeleted: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
    return result > 0;
  }
  
  @override
  Stream<List<Transaction>> watchAll() {
    return (_database.select(_database.transactions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .watch();
  }
  
  @override
  Stream<List<Transaction>> watchToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return (_database.select(_database.transactions)
          ..where((t) => 
              t.transactionDate.isBetweenValues(startOfDay, endOfDay) &
              t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .watch();
  }
  
  @override
  Future<TransactionStats> getStats(DateTime start, DateTime end) async {
    final transactions = await getByDateRange(start, end);
    
    double totalExpense = 0;
    double totalIncome = 0;
    
    for (final t in transactions) {
      if (t.type == 'expense') {
        totalExpense += t.amount;
      } else if (t.type == 'income') {
        totalIncome += t.amount;
      }
    }
    
    return TransactionStats(
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      balance: totalIncome - totalExpense,
      count: transactions.length,
    );
  }
}
```

---

## 4. Provider配置（依赖注入）

```dart
// lib/config/di/providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

// 数据库Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
});

// Repository Providers
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return TransactionRepositoryImpl(database);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return CategoryRepositoryImpl(database);
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return BudgetRepositoryImpl(database);
});

final accountBookRepositoryProvider = Provider<AccountBookRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return AccountBookRepositoryImpl(database);
});

// UseCase Providers
final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return AddTransactionUseCase(repository);
});

final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return GetTransactionsUseCase(repository);
});
```

---

## 5. 数据模型（Model）

### 5.1 Model vs Entity

| 概念 | 位置 | 用途 |
|------|------|------|
| **Entity** | Domain层 | 业务对象，不依赖外部 |
| **Model** | Data层 | 数据传输对象，可能包含序列化逻辑 |

### 5.2 Drift自动生成Model

Drift会自动生成数据类（如`Transaction`），可以直接作为Model使用。

### 5.3 自定义Model（如果需要）

```dart
// lib/features/transaction/data/models/transaction_model.dart

class TransactionModel {
  final int id;
  final double amount;
  final String? description;
  final String? note;
  final int categoryId;
  final int? subcategoryId;
  final DateTime transactionDate;
  final String type;
  final String? originalInput;
  final double? aiConfidence;
  final String? aiSource;
  
  const TransactionModel({
    required this.id,
    required this.amount,
    this.description,
    this.note,
    required this.categoryId,
    this.subcategoryId,
    required this.transactionDate,
    required this.type,
    this.originalInput,
    this.aiConfidence,
    this.aiSource,
  });
  
  // 从Drift对象转换
  factory TransactionModel.fromDrift(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      description: transaction.description,
      note: transaction.note,
      categoryId: transaction.categoryId,
      subcategoryId: transaction.subcategoryId,
      transactionDate: transaction.transactionDate,
      type: transaction.type,
      originalInput: transaction.originalInput,
      aiConfidence: transaction.aiConfidence,
      aiSource: transaction.aiSource,
    );
  }
  
  // 转换为Entity
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      amount: amount,
      description: description,
      note: note,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      transactionDate: transactionDate,
      type: type,
    );
  }
}
```

---

## 6. 错误处理

### 6.1 异常定义

```dart
// lib/core/error/exceptions.dart

class DatabaseException implements Exception {
  final String message;
  final dynamic originalError;
  
  const DatabaseException({
    required this.message,
    this.originalError,
  });
  
  @override
  String toString() => 'DatabaseException: $message';
}

class NotFoundException extends DatabaseException {
  const NotFoundException({required String message})
      : super(message: message);
}
```

### 6.2 错误类型

```dart
// lib/core/error/failures.dart

abstract class Failure {
  final String message;
  const Failure({required this.message});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required String message})
      : super(message: message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required String message})
      : super(message: message);
}
```

### 6.3 在Repository中处理错误

```dart
@override
Future<Transaction?> getById(int id) async {
  try {
    return await (_database.select(_database.transactions)
          ..where((t) => t.id.equals(id) & t.isDeleted.equals(false)))
        .getSingleOrNull();
  } catch (e) {
    throw DatabaseException(
      message: 'Failed to get transaction by id: $id',
      originalError: e,
    );
  }
}
```

---

## 7. 数据迁移策略

### 7.1 版本管理

```dart
@override
int get schemaVersion => 2; // 当前版本

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (Migrator m) async {
    await m.createAll();
    await _seedDefaultData();
  },
  onUpgrade: (Migrator m, int from, int to) async {
    if (from < 2) {
      // 从版本1升级到版本2
      await m.addColumn(transactions, transactions.note);
    }
  },
);
```

### 7.2 迁移检查清单

- [ ] 添加新表
- [ ] 添加新列
- [ ] 修改列类型
- [ ] 添加索引
- [ ] 数据迁移脚本

---

## 8. 总结

### 关键点

| 方面 | 方案 |
|------|------|
| 数据库 | SQLite（通过Drift ORM） |
| 数据访问 | Repository模式 |
| 依赖注入 | Riverpod Providers |
| 错误处理 | 自定义异常 + Failure类型 |
| 数据迁移 | Drift MigrationStrategy |
| 实时监听 | Stream（Drift watch） |

### 文件结构

```
lib/config/database/
├── app_database.dart           # 数据库定义
├── app_database.g.dart         # 自动生成
└── tables/
    ├── categories.dart
    ├── transactions.dart
    ├── account_books.dart
    ├── budgets.dart
    ├── ai_training_data.dart
    └── user_settings.dart

lib/features/*/data/
├── models/
│   └── xxx_model.dart
└── repositories/
    └── xxx_repository_impl.dart

lib/features/*/domain/
├── entities/
│   └── xxx.dart
└── repositories/
    └── xxx_repository.dart
```
