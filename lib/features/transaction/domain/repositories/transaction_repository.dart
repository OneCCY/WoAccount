import '../../../../config/database/app_database.dart';

/// 搜索条件
class SearchQuery {
  /// 关键词（模糊匹配 description / note / originalInput）
  final String? keyword;

  /// 扩展同义词列表（LLM 生成，用于语义扩展搜索）
  final List<String> keywordSynonyms;

  /// 交易类型：expense / income / null(全部)
  final String? type;

  /// 最小金额
  final double? minAmount;

  /// 最大金额
  final double? maxAmount;

  /// 日期范围起始
  final DateTime? startDate;

  /// 日期范围结束
  final DateTime? endDate;

  /// 父分类 ID
  final int? parentCategoryId;

  /// 子分类 ID
  final int? categoryId;

  /// 支付方式
  final String? payMethod;

  /// 聚合类型
  final SearchAggregation aggregation;

  /// 排序方式
  final SearchSortBy sortBy;

  /// LLM 意图描述
  final String? intent;

  const SearchQuery({
    this.keyword,
    this.keywordSynonyms = const [],
    this.type,
    this.minAmount,
    this.maxAmount,
    this.startDate,
    this.endDate,
    this.parentCategoryId,
    this.categoryId,
    this.payMethod,
    this.aggregation = SearchAggregation.none,
    this.sortBy = SearchSortBy.time,
    this.intent,
  });
}

/// 搜索聚合类型
enum SearchAggregation {
  none,   // 返回列表
  count,  // 计数
  sum,    // 求和
  avg,    // 平均
  max,    // 最大值
  min,    // 最小值
}

/// 搜索排序
enum SearchSortBy {
  time,    // 按时间倒序
  amount,  // 按金额倒序
}

/// 搜索结果聚合数据
class SearchResultStats {
  final int count;
  final double totalExpense;
  final double totalIncome;
  final double? average;
  final double? maxAmount;
  final Transaction? maxTransaction;

  const SearchResultStats({
    required this.count,
    required this.totalExpense,
    required this.totalIncome,
    this.average,
    this.maxAmount,
    this.maxTransaction,
  });
}

/// 搜索结果 + 统计的复合返回（避免重复查询）
class SearchResultWithResults {
  final List<Transaction> transactions;
  final SearchResultStats stats;
  const SearchResultWithResults(this.transactions, this.stats);
}

/// 交易记录 Repository 接口（Domain 层）
abstract class TransactionRepository {
  /// 获取账本内所有交易（排除软删除）
  Future<List<Transaction>> getAll(int bookId);

  /// 根据 ID 获取
  Future<Transaction?> getById(int id);

  /// 根据日期范围获取
  Future<List<Transaction>> getByDateRange(int bookId, DateTime start, DateTime end);

  /// 根据分类获取
  Future<List<Transaction>> getByCategoryId(int bookId, int categoryId);

  /// 获取今日交易
  Future<List<Transaction>> getToday(int bookId);

  /// 获取本月交易
  Future<List<Transaction>> getThisMonth(int bookId);

  /// 插入交易
  Future<int> insert(TransactionsCompanion transaction);

  /// 更新交易
  Future<bool> update(TransactionsCompanion transaction);

  /// 软删除交易
  Future<bool> delete(int id);

  /// 恢复已软删除的交易
  Future<bool> restore(int id);

  /// 获取已软删除的交易列表
  Future<List<Transaction>> getDeleted(int bookId);

  /// 永久删除交易（硬删除）
  Future<bool> permanentDelete(int id);

  /// 批量恢复
  Future<int> restoreBatch(List<int> ids);

  /// 批量永久删除
  Future<int> permanentDeleteBatch(List<int> ids);

  /// 监听账本内所有交易变化（响应式）
  Stream<List<Transaction>> watchAll(int bookId);

  /// 监听账本内指定日期范围的交易变化（响应式，替代 watchAll 的高效版本）
  Stream<List<Transaction>> watchByDateRange(int bookId, DateTime start, DateTime end);

  /// 分页获取账本内所有交易（按时间倒序）
  Future<List<Transaction>> getPaged(int bookId, int limit, int offset);

  /// 监听账本内今日交易变化
  Stream<List<Transaction>> watchToday(int bookId);

  /// 获取日期范围内的统计
  Future<TransactionStats> getStats(int bookId, DateTime start, DateTime end);

  /// 搜索交易记录
  Future<List<Transaction>> search(int bookId, SearchQuery query);

  /// 搜索交易记录并返回聚合统计
  Future<SearchResultStats> searchWithStats(int bookId, SearchQuery query);

  /// 搜索交易记录，同时返回结果列表和聚合统计（避免重复查询）
  Future<SearchResultWithResults> searchWithResults(int bookId, SearchQuery query);
}

/// 交易统计数据
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
