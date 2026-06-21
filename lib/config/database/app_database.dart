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
  TextColumn get type => text().withLength(max: 10).withDefault(const Constant('expense'))(); // expense/income/other
  TextColumn get description => text().withLength(min: 1, max: 500)();
  TextColumn get note => text().withLength(max: 500).nullable()(); // 补充备注（区别于核心描述）
  IntColumn get categoryId => integer().references(Categories, #id)();
  IntColumn get parentCategoryId => integer().nullable().references(Categories, #id)(); // 父分类ID（原subcategoryId）
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get payMethod => text().withLength(max: 20).nullable()(); // 支付方式: cash/wechat/alipay/card/other
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

/// 交易媒体关联表（支持多张小票/发票）
@DataClassName('TransactionMedium')
class TransactionMedia extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId => integer().references(Transactions, #id)();
  TextColumn get filePath => text()();
  TextColumn get mediaType => text().withLength(max: 10)(); // image/audio
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
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
  TextColumn get l10nKey => text().withLength(max: 50).nullable()();
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
  TextColumn get nickname => text().withLength(min: 0, max: 50).withDefault(const Constant(''))();
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
  TransactionMedia,
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
  int get schemaVersion => 10;

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
        await into(acCoinBalances).insert(AcCoinBalancesCompanion.insert(
          userId: const Value(1),
          balance: const Value(100),
        ));
        await into(acCoinTransactions).insert(AcCoinTransactionsCompanion.insert(
          userId: const Value(1),
          amount: 100,
          type: 'initial_gift',
          description: const Value('acCoinInitialGiftDesc'),
        ));
      }
      if (from < 5) {
        await m.createTable(accountBooks);
        await into(accountBooks).insert(AccountBooksCompanion.insert(
          name: '默认账本',
          type: 'personal',
          isDefault: const Value(true),
        ));
        await m.addColumn(transactions, transactions.accountBookId);
        await m.addColumn(budgets, budgets.accountBookId);
        await m.addColumn(aiTrainingRecords, aiTrainingRecords.accountBookId);
        await m.addColumn(conversationMessages, conversationMessages.accountBookId);
        await customStatement('UPDATE transactions SET account_book_id = 1 WHERE account_book_id IS NULL');
        await customStatement('UPDATE budgets SET account_book_id = 1 WHERE account_book_id IS NULL');
        await customStatement('UPDATE ai_training_records SET account_book_id = 1 WHERE account_book_id IS NULL');
        await customStatement('UPDATE conversation_messages SET account_book_id = 1 WHERE account_book_id IS NULL');
      }
      if (from < 6) {
        await m.addColumn(transactions, transactions.mediaFilePath);
        await m.addColumn(transactions, transactions.mediaType);
        await m.addColumn(conversationMessages, conversationMessages.mediaType);
        await m.addColumn(conversationMessages, conversationMessages.mediaFilePath);
      }
      if (from < 7) {
        await m.addColumn(categories, categories.l10nKey);
        final l10nMap = {
          '餐饮美食': 'catExpenseFood', '交通出行': 'catExpenseTransport',
          '居住': 'catExpenseHousing', '服饰美容': 'catExpenseClothing',
          '日用百货': 'catExpenseDaily', '数码科技': 'catExpenseTech',
          '医疗健康': 'catExpenseMedical', '教育学习': 'catExpenseEducation',
          '休闲娱乐': 'catExpenseEntertainment', '社交人情': 'catExpenseSocial',
          '子女养育': 'catExpenseChildren', '赡养长辈': 'catExpenseElderly',
          '宠物': 'catExpensePet', '工作办公': 'catExpenseWork',
          '金融保险': 'catExpenseFinance', '其他支出': 'catExpenseOther',
          '工资薪酬': 'catIncomeSalary', '投资理财': 'catIncomeInvestment',
          '副业兼职': 'catIncomeSideJob', '红包馈赠': 'catIncomeGift',
          '报销退款': 'catIncomeRefund', '租金资产': 'catIncomeAsset',
          '转账收入': 'catIncomeTransferIn', '其他收入': 'catIncomeOther',
          '转账': 'catOtherTransfer', '还款': 'catOtherRepayment',
          '人情往来': 'catOtherSocial',
        };
        for (final entry in l10nMap.entries) {
          await customStatement(
            "UPDATE categories SET l10n_key = '${entry.value}' WHERE name = '${entry.key}' AND is_system = 1",
          );
        }
      }
      if (from < 8) {
        await customStatement("UPDATE user_profiles SET gender = 'male' WHERE gender = '男'");
        await customStatement("UPDATE user_profiles SET gender = 'female' WHERE gender = '女'");
        await customStatement("UPDATE user_profiles SET gender = 'secret' WHERE gender = '保密'");
        await customStatement("UPDATE user_profiles SET nickname = '' WHERE nickname = '用户'");
      }
      if (from < 9) {
        // 新增字段: type, note, payMethod
        await m.addColumn(transactions, transactions.type);
        await m.addColumn(transactions, transactions.note);
        await m.addColumn(transactions, transactions.payMethod);
        // 回填 type：根据分类的 isExpense 字段推断
        await customStatement(
          "UPDATE transactions SET type = CASE "
          "WHEN (SELECT is_expense FROM categories WHERE id = transactions.category_id) = 1 THEN 'expense' "
          "WHEN (SELECT l10n_key FROM categories WHERE id = transactions.category_id) IN "
          "('catOtherTransfer','catOtherRepayment','catOtherSocial') THEN 'other' "
          "ELSE 'income' END",
        );
        // 重命名 subcategoryId → parentCategoryId
        // SQLite 不支持 RENAME COLUMN（< 3.25.0），用新建列+复制数据的方式
        await m.addColumn(transactions, transactions.parentCategoryId);
        await customStatement(
          'UPDATE transactions SET parent_category_id = subcategory_id WHERE subcategory_id IS NOT NULL',
        );
        // 创建新表
        await m.createTable(transactionMedia);
      }
      if (from < 10) {
        // 修复 v9 迁移数据：旧 schema 中 categoryId=父分类, subcategoryId=子分类
        // 迁移后 parentCategoryId 存的是子分类ID，需要交换
        // 正确语义：categoryId=叶子分类(子分类), parentCategoryId=父分类
        await customStatement(
          "UPDATE transactions SET "
          "parent_category_id = category_id, "
          "category_id = parent_category_id "
          "WHERE parent_category_id IS NOT NULL",
        );
      }
    },
  );

  /// 初始化默认用户
  Future<void> _seedDefaultUser() async {
    await into(userProfiles).insert(UserProfilesCompanion.insert(
      nickname: Value(''),
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
      description: const Value('acCoinInitialGiftDesc'),
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
        l10nKey: Value(parent.l10nKey),
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
    // ignore: avoid_print
    assert(() { print('[DB] Opening database at: ${file.path} (exists: ${file.existsSync()})'); return true; }());
    return NativeDatabase.createInBackground(file);
  });
}
