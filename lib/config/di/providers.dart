import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../database/app_database.dart';
import '../../features/transaction/domain/repositories/transaction_repository.dart';
import '../../features/transaction/data/repositories/transaction_repository_impl.dart';
import '../../features/category/domain/repositories/category_repository.dart';
import '../../features/category/data/repositories/category_repository_impl.dart';
import '../../features/budget/domain/repositories/budget_repository.dart';
import '../../features/budget/data/repositories/budget_repository_impl.dart';
import '../../features/chat/domain/repositories/chat_repository.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';

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
