import 'dart:io' show File;
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'category_seed_data.dart';

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
  TextColumn get mediaFilePath => text().nullable()();
  TextColumn get mediaType => text().withLength(max: 10).nullable()();
  RealColumn get aiConfidence => real().nullable()();
  TextColumn get aiSource => text().withLength(max: 20).withDefault(const Constant('manual'))();
  BoolColumn get userConfirmed => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// 所属账本
  IntColumn get accountBookId => integer().references(AccountBooks, #id)();
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

  /// 所属账本
  IntColumn get accountBookId => integer().references(AccountBooks, #id)();

  @override
  List<Set<Column>> get uniqueKeys => [{accountBookId, categoryId, year, month}];
}

/// 账本表
@DataClassName('AccountBook')
class AccountBooks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get type => text().withLength(min: 1, max: 20)();  // personal/family/travel/business/other
  TextColumn get description => text().nullable()();
  TextColumn get icon => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
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

  /// 所属账本
  IntColumn get accountBookId => integer().references(AccountBooks, #id)();
}

/// 对话历史表
@DataClassName('ConversationMessage')
class ConversationMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get conversationId => text().withLength(max: 50)();
  TextColumn get role => text().withLength(max: 20)();
  TextColumn get content => text()();
  TextColumn get mediaType => text().withLength(max: 10).nullable()();
  TextColumn get mediaFilePath => text().nullable()();
  TextColumn get functionName => text().nullable()();
  TextColumn get functionArgs => text().nullable()();
  TextColumn get functionResult => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 所属账本
  IntColumn get accountBookId => integer().references(AccountBooks, #id)();
}

/// 用户资料表
@DataClassName('UserProfile')
class UserProfiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nickname => text().withLength(min: 1, max: 50).withDefault(const Constant('用户'))();
  TextColumn get avatarPath => text().nullable()();
  TextColumn get gender => text().withLength(max: 10).nullable()();
  TextColumn get email => text().withLength(max: 100).nullable()();
  TextColumn get phone => text().withLength(max: 20).nullable()();
  TextColumn get uid => text().withLength(max: 50).withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// 打卡记录表
@DataClassName('CheckInRecord')
class CheckInRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().withDefault(const Constant(1))();
  DateTimeColumn get checkInDate => dateTime()();
  BoolColumn get isMakeup => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [{checkInDate}];
}

/// AC币余额表（每个用户一行）
@DataClassName('AcCoinBalance')
class AcCoinBalances extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().withDefault(const Constant(1))();
  IntColumn get balance => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// AC币流水记录表
@DataClassName('AcCoinTransaction')
class AcCoinTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().withDefault(const Constant(1))();
  IntColumn get amount => integer()(); // 正数收入，负数支出
  TextColumn get type => text().withLength(max: 30)(); // daily_checkin, streak_7d, streak_30d, streak_180d, streak_365d, makeup_cost
  TextColumn get description => text().withLength(max: 200).withDefault(const Constant(''))();
  IntColumn get relatedDate => integer().nullable()(); // 关联的打卡日期（毫秒时间戳）
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [
  AccountBooks,
  Transactions,
  Categories,
  Budgets,
  AiTrainingRecords,
  ConversationMessages,
  UserProfiles,
  CheckInRecords,
  AcCoinBalances,
  AcCoinTransactions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// 测试用构造函数，接受自定义 QueryExecutor（如内存数据库）
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // 插入默认账本
      await into(accountBooks).insert(AccountBooksCompanion.insert(
        name: '默认账本',
        type: 'personal',
        isDefault: const Value(true),
      ));
      await _seedCategories();
      await _seedDefaultUser();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.deleteTable('categories');
        await m.createTable(categories);
        await _seedCategories();
      }
      if (from < 3) {
        await m.createTable(userProfiles);
        await m.createTable(checkInRecords);
        await _seedDefaultUser();
      }
      if (from < 4) {
        await m.createTable(acCoinBalances);
        await m.createTable(acCoinTransactions);
        // 为默认用户初始化 AC 币余额（新用户赠送 100 AC 币）
        await into(acCoinBalances).insert(AcCoinBalancesCompanion.insert(
          userId: const Value(1),
          balance: const Value(100),
        ));
        // 记录初始赠送 AC 币明细
        await into(acCoinTransactions).insert(AcCoinTransactionsCompanion.insert(
          userId: const Value(1),
          amount: 100,
          type: 'initial_gift',
          description: const Value('新用户注册赠送'),
        ));
      }
      if (from < 5) {
        // 创建账本表
        await m.createTable(accountBooks);
        // 插入默认账本
        await into(accountBooks).insert(AccountBooksCompanion.insert(
          name: '默认账本',
          type: 'personal',
          isDefault: const Value(true),
        ));
        // 给现有表加 accountBookId 列，默认关联到默认账本 (id=1)
        await m.addColumn(transactions, transactions.accountBookId);
        await m.addColumn(budgets, budgets.accountBookId);
        await m.addColumn(aiTrainingRecords, aiTrainingRecords.accountBookId);
        await m.addColumn(conversationMessages, conversationMessages.accountBookId);
        // 回填已有行的 accountBookId（addColumn 对已有行填 NULL，需手动更新）
        await customStatement('UPDATE transactions SET account_book_id = 1 WHERE account_book_id IS NULL');
        await customStatement('UPDATE budgets SET account_book_id = 1 WHERE account_book_id IS NULL');
        await customStatement('UPDATE ai_training_records SET account_book_id = 1 WHERE account_book_id IS NULL');
        await customStatement('UPDATE conversation_messages SET account_book_id = 1 WHERE account_book_id IS NULL');
      }
      if (from < 6) {
        // 给交易表添加媒体字段
        await m.addColumn(transactions, transactions.mediaFilePath);
        await m.addColumn(transactions, transactions.mediaType);
        // 给对话消息表添加媒体字段
        await m.addColumn(conversationMessages, conversationMessages.mediaType);
        await m.addColumn(conversationMessages, conversationMessages.mediaFilePath);
      }
    },
  );

  /// 初始化默认用户
  Future<void> _seedDefaultUser() async {
    await into(userProfiles).insert(UserProfilesCompanion.insert(
      nickname: Value('用户'),
      uid: Value('WO${100000 + DateTime.now().millisecondsSinceEpoch % 900000}'),
    ));
    // 初始化 AC 币余额（新用户赠送 100 AC 币）
    await into(acCoinBalances).insert(AcCoinBalancesCompanion.insert(
      userId: const Value(1),
      balance: const Value(100),
    ));
    // 记录初始赠送 AC 币明细
    await into(acCoinTransactions).insert(AcCoinTransactionsCompanion.insert(
      userId: const Value(1),
      amount: 100,
      type: 'initial_gift',
      description: const Value('新用户注册赠送'),
    ));
  }

  /// 初始化系统分类（从 category_seed_data.dart 读取）
  Future<void> _seedCategories() async {
    for (final parent in [...expenseCategories, ...incomeCategories, ...otherCategories]) {
      final parentId = await into(categories).insert(CategoriesCompanion.insert(
        name: parent.name,
        icon: Value(parent.icon),
        color: Value(parent.color),
        level: const Value(1),
        isSystem: const Value(true),
        isExpense: Value(parent.isExpense),
        sortOrder: Value(parent.sortOrder),
      ));

      for (final child in parent.children) {
        await into(categories).insert(CategoriesCompanion.insert(
          name: child.name,
          icon: Value(child.icon),
          color: Value(child.color),
          parentId: Value(parentId),
          level: const Value(2),
          isSystem: const Value(true),
          isExpense: Value(child.isExpense),
          sortOrder: Value(child.sortOrder),
        ));
      }
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
