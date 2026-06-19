import 'package:drift/drift.dart';
import '../../../../config/database/app_database.dart';
import '../../domain/repositories/ac_coin_repository.dart';

/// AC 币 Repository 实现（Data 层）
class AcCoinRepositoryImpl implements AcCoinRepository {
  final AppDatabase _db;

  AcCoinRepositoryImpl(this._db);

  @override
  Future<int> getBalance() async {
    final balances = await _db.select(_db.acCoinBalances).get();
    return balances.isNotEmpty ? balances.first.balance : 0;
  }

  @override
  Future<List<AcCoinTransaction>> getAllTransactions() async {
    return (_db.select(_db.acCoinTransactions)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  @override
  Future<void> addCoins(int amount, String type, int? relatedDate) async {
    await _db.into(_db.acCoinTransactions).insert(AcCoinTransactionsCompanion.insert(
      userId: const Value(1),
      amount: amount,
      type: type,
      description: Value(type), // store type as l10nKey; resolved at display time
      relatedDate: Value(relatedDate),
    ));

    final balances = await _db.select(_db.acCoinBalances).get();
    if (balances.isNotEmpty) {
      await (_db.update(_db.acCoinBalances)..where((t) => t.id.equals(balances.first.id)))
          .write(AcCoinBalancesCompanion(balance: Value(balances.first.balance + amount)));
    }
  }

  @override
  Future<void> deductCoins(int amount, String type, int? relatedDate) async {
    await addCoins(-amount, type, relatedDate);
  }

  @override
  Future<Set<String>> getClaimedStreakTypes() async {
    final allTxns = await _db.select(_db.acCoinTransactions).get();
    return allTxns
        .where((t) => t.type.startsWith('streak_'))
        .map((t) => t.type)
        .toSet();
  }
}
