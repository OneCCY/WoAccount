import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import '../../features/transaction/domain/repositories/transaction_repository.dart';
import '../../features/transaction/data/repositories/transaction_repository_impl.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/category/data/repositories/category_repository_impl.dart';
import '../../features/budget/domain/repositories/budget_repository.dart';
import '../../features/budget/data/repositories/budget_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';
import '../../features/account_book/domain/repositories/account_book_repository.dart';
import '../../features/account_book/data/repositories/account_book_repository_impl.dart';
import '../../features/stats/domain/repositories/report_repository.dart';
import '../../features/stats/data/repositories/report_repository_impl.dart';
import '../../features/profile/domain/repositories/user_profile_repository.dart';
import '../../features/profile/data/repositories/user_profile_repository_impl.dart';
import '../../features/profile/domain/repositories/checkin_repository.dart';
import '../../features/profile/data/repositories/checkin_repository_impl.dart';
import '../../features/profile/domain/repositories/ac_coin_repository.dart';
import '../../features/profile/data/repositories/ac_coin_repository_impl.dart';
import '../../features/profile/data/services/excel_service.dart';
import '../../features/ai/data/repository/chat_history_repository.dart';
import '../../features/ai/data/repository/memory_repository.dart';
import '../../features/ai/data/repository/memory_extraction_queue.dart';
import '../../features/profile/data/services/backup_service.dart';

part 'providers.g.dart';

/// 全局数据库 Provider（keepAlive: 应用生命周期内单例，避免页面切换时数据库重建导致数据丢失）
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

/// 交易记录 Repository Provider
@riverpod
TransactionRepository transactionRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return TransactionRepositoryImpl(db);
}

/// 分类 Repository Provider
@riverpod
CategoryRepository categoryRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return CategoryRepositoryImpl(db);
}

/// 预算 Repository Provider
@riverpod
BudgetRepository budgetRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return BudgetRepositoryImpl(db);
}

/// 对话记录 Repository Provider
@riverpod
ChatRepository chatRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return ChatRepositoryImpl(db);
}

/// 账本 Repository Provider
@riverpod
AccountBookRepository accountBookRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return AccountBookRepositoryImpl(db);
}

/// 报表分析 Repository Provider
@riverpod
ReportRepository reportRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return ReportRepositoryImpl(db);
}

/// 用户资料 Repository Provider
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return UserProfileRepositoryImpl(db);
});

/// AC 币 Repository Provider
final acCoinRepositoryProvider = Provider<AcCoinRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return AcCoinRepositoryImpl(db);
});

/// 签到 Repository Provider
final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final acCoinRepo = ref.watch(acCoinRepositoryProvider);
  return CheckInRepositoryImpl(db, acCoinRepo);
});

/// 当前选中的账本 ID（持久化到 SharedPreferences，默认 1）
final currentBookProvider = StateProvider<int>((ref) => 1);

/// 切换当前账本并持久化
Future<void> switchCurrentBook(WidgetRef ref, int bookId) async {
  ref.read(currentBookProvider.notifier).state = bookId;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('current_book_id', bookId);
}

/// 账单页面滚动到顶部并刷新的回调（由 TransactionListPage 注册，MainShell 调用）
final scrollToTopProvider = StateProvider<void Function()?>((ref) => null);

/// Excel 导入导出服务 Provider
final excelServiceProvider = Provider<ExcelService>((ref) {
  final txnRepo = ref.watch(transactionRepositoryProvider);
  final catRepo = ref.watch(categoryRepositoryProvider);
  return ExcelService(txnRepo, catRepo);
});

/// 数据备份服务 Provider（单例）
final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});

/// 角色聊天记录仓库 Provider
final chatHistoryRepositoryProvider = Provider<ChatHistoryRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  return ChatHistoryRepository(db);
});

/// 语义记忆仓库 Provider
final memoryRepositoryProvider = Provider<MemoryRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  return MemoryRepository(db);
});

/// 异步记忆提取队列 Provider
final memoryExtractionQueueProvider = Provider<MemoryExtractionQueue>((ref) {
  final chatHistoryRepo = ref.read(chatHistoryRepositoryProvider);
  final memoryRepo = ref.read(memoryRepositoryProvider);
  return MemoryExtractionQueue(
    memoryRepo: memoryRepo,
    chatHistoryRepo: chatHistoryRepo,
  );
});
