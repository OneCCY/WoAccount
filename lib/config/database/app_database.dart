import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

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

/// AI 训练数据表
@DataClassName('AiTrainingRecord')
class AiTrainingRecords extends Table {
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
  TextColumn get role => text().withLength(max: 20)();
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
  AiTrainingRecords,
  ConversationMessages,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 测试用构造函数，接受自定义 QueryExecutor（如内存数据库）
  AppDatabase.forTesting(super.e);

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
      CategoriesCompanion.insert(name: '餐饮', icon: const Value('🍜'), color: const Value('#FF9800'), level: const Value(1), isSystem: const Value(true), sortOrder: const Value(1)),
      CategoriesCompanion.insert(name: '交通', icon: const Value('🚗'), color: const Value('#2196F3'), level: const Value(1), isSystem: const Value(true), sortOrder: const Value(2)),
      CategoriesCompanion.insert(name: '购物', icon: const Value('🛒'), color: const Value('#E91E63'), level: const Value(1), isSystem: const Value(true), sortOrder: const Value(3)),
      CategoriesCompanion.insert(name: '住房', icon: const Value('🏠'), color: const Value('#9C27B0'), level: const Value(1), isSystem: const Value(true), sortOrder: const Value(4)),
      CategoriesCompanion.insert(name: '娱乐', icon: const Value('🎮'), color: const Value('#4CAF50'), level: const Value(1), isSystem: const Value(true), sortOrder: const Value(5)),
      CategoriesCompanion.insert(name: '教育', icon: const Value('📚'), color: const Value('#00BCD4'), level: const Value(1), isSystem: const Value(true), sortOrder: const Value(6)),
      CategoriesCompanion.insert(name: '医疗', icon: const Value('💊'), color: const Value('#F44336'), level: const Value(1), isSystem: const Value(true), sortOrder: const Value(7)),
      CategoriesCompanion.insert(name: '社交', icon: const Value('👤'), color: const Value('#FF5722'), level: const Value(1), isSystem: const Value(true), sortOrder: const Value(8)),
      CategoriesCompanion.insert(name: '其他', icon: const Value('💰'), color: const Value('#607D8B'), level: const Value(1), isSystem: const Value(true), sortOrder: const Value(9)),
    ];

    for (final category in categories) {
      await into(this.categories).insert(category);
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
