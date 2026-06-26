import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wo_account/l10n/app_localizations.dart';
import '../../../../config/database/app_database.dart';
import '../../../../config/di/ai_providers.dart';
import '../../../../config/di/providers.dart';
import '../../../../core/locale/locale_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/toast.dart';
import '../../domain/repositories/transaction_repository.dart';

/// 搜索模式
enum SearchMode { keyword, ai }

/// 账单搜索页
class TransactionSearchPage extends ConsumerStatefulWidget {
  const TransactionSearchPage({super.key});

  @override
  ConsumerState<TransactionSearchPage> createState() => _TransactionSearchPageState();
}

class _TransactionSearchPageState extends ConsumerState<TransactionSearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  SearchMode _searchMode = SearchMode.ai;
  bool _isSearching = false;
  bool _isAiParsing = false;
  String? _aiIntent;

  // 搜索结果
  List<Transaction> _results = [];
  SearchResultStats? _resultStats;
  Map<int, Category> _categoryMap = {};
  String? _aiSummary;

  // 筛选状态
  String? _filterType; // null=全部, 'expense', 'income'
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  // 防抖
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _loadCategories();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceController();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _debounceController() {
    _debounceTimer?.cancel();
  }

  void _loadCategories() async {
    final catRepo = ref.read(categoryRepositoryProvider);
    final cats = await catRepo.getAll();
    if (mounted) {
      setState(() {
        _categoryMap = {for (final c in cats) c.id: c};
      });
    }
  }

  void _onSearchChanged() {
    if (_searchMode == SearchMode.keyword) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        _executeKeywordSearch();
      });
    }
  }

  /// 执行关键词搜索（本地 SQLite）
  Future<void> _executeKeywordSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _resultStats = null;
        _aiSummary = null;
        _aiIntent = null;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final repo = ref.read(transactionRepositoryProvider);
      final bookId = ref.read(currentBookProvider);

      final searchQuery = SearchQuery(
        keyword: query,
        type: _filterType,
        startDate: _filterStartDate,
        endDate: _filterEndDate,
        limit: 50,  // 每次最多加载 50 条
      );

      final results = await repo.search(bookId, searchQuery);
      if (!mounted) return;
      setState(() {
        _results = results;
        _isSearching = false;
        _aiSummary = null;
        _aiIntent = null;
      });

      // 异步获取统计
      final stats = await repo.searchWithStats(bookId, searchQuery);
      if (mounted) {
        setState(() => _resultStats = stats);
      }
    } catch (e) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  /// 执行 AI 搜索（LLM 理解自然语言后搜索）
  Future<void> _executeAiSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isAiParsing = true;
      _isSearching = true;
      _results = [];
      _resultStats = null;
      _aiSummary = null;
      _aiIntent = null;
    });

    try {
      final llmRepo = ref.read(llmRepositoryProvider);
      final repo = ref.read(transactionRepositoryProvider);
      final bookId = ref.read(currentBookProvider);

      // 1. LLM 解析搜索意图
      final parsed = await llmRepo.parseSearchQuery(query);

      if (!mounted) return;
      setState(() {
        _aiIntent = parsed['intent'] as String?;
        _isAiParsing = false;
      });

      // 2. 将 LLM 解析结果转换为 SearchQuery
      final searchQuery = _buildSearchQueryFromParsed(parsed);

      // 3. 一次查询同时获取结果和统计（避免重复查询）
      final combined = await repo.searchWithResults(bookId, searchQuery);
      if (!mounted) return;
      setState(() {
        _results = combined.transactions;
        _resultStats = combined.stats;
        _isSearching = false;
      });

      // 4. 计算分类分布
      final categoryTotals = <String, double>{};
      for (final t in combined.transactions) {
        final cat = _categoryMap[t.parentCategoryId ?? t.categoryId];
        final catName = cat?.name ?? '未分类';
        categoryTotals[catName] = (categoryTotals[catName] ?? 0) + t.amount;
      }

      final sortedCategories = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final statsMap = <String, dynamic>{
        'count': combined.stats.count,
        'totalExpense': combined.stats.totalExpense,
        'totalIncome': combined.stats.totalIncome,
        'average': combined.stats.average,
        'maxAmount': combined.stats.maxAmount,
        'maxDescription': combined.stats.maxTransaction?.description,
        'topCategories': sortedCategories.take(5).toList(),
      };

      // 5. 如果有聚合需求或结果较多，生成 AI 摘要（传入分类体系）
      final aggregation = parsed['aggregation'] as String? ?? 'none';
      if (aggregation != 'none' || combined.transactions.length > 5) {
        final catRepo = ref.read(categoryRepositoryProvider);
        final allCats = await catRepo.getAll();
        final taxonomy = _buildTaxonomyText(allCats);

        final summary = await llmRepo.generateSearchSummary(
          query, statsMap,
          categoryTaxonomy: taxonomy.isNotEmpty ? taxonomy : null,
        );
        if (mounted) {
          setState(() => _aiSummary = summary);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAiParsing = false;
        _isSearching = false;
      });
      // AI 失败时降级为关键词搜索，通知用户
      _searchMode = SearchMode.keyword;
      if (mounted) {
        AppToast.show(context, AppLocalizations.of(context)!.searchLlmError);
      }
      _executeKeywordSearch();
    }
  }

  /// 将 LLM 解析的 JSON 转换为 SearchQuery
  SearchQuery _buildSearchQueryFromParsed(Map<String, dynamic> parsed) {
    DateTime? startDate;
    DateTime? endDate;

    // 解析日期
    final startStr = parsed['startDate'] as String?;
    final endStr = parsed['endDate'] as String?;
    if (startStr != null) {
      try { startDate = DateTime.parse(startStr); } catch (_) {}
    }
    if (endStr != null) {
      try { endDate = DateTime.parse(endStr).add(const Duration(days: 1)); } catch (_) {}
    }

    // 解析分类（精确匹配 → 包含匹配）
    int? parentCategoryId;
    int? categoryId;
    final parentCatName = parsed['parentCategory'] as String?;
    final subCatName = parsed['subcategory'] as String?;

    if (subCatName != null) {
      // 精确匹配
      for (final c in _categoryMap.values) {
        if (c.name == subCatName && c.level == 2) {
          categoryId = c.id;
          break;
        }
      }
      // 包含匹配 fallback
      if (categoryId == null) {
        for (final c in _categoryMap.values) {
          if (c.level == 2 && (c.name.contains(subCatName) || subCatName.contains(c.name))) {
            categoryId = c.id;
            break;
          }
        }
      }
    }
    if (parentCatName != null && categoryId == null) {
      // 精确匹配
      for (final c in _categoryMap.values) {
        if (c.name == parentCatName && c.level == 1) {
          parentCategoryId = c.id;
          break;
        }
      }
      // 包含匹配 fallback
      if (parentCategoryId == null) {
        for (final c in _categoryMap.values) {
          if (c.level == 1 && (c.name.contains(parentCatName) || parentCatName.contains(c.name))) {
            parentCategoryId = c.id;
            break;
          }
        }
      }
    }

    // 排序方式
    final sortByStr = parsed['sortBy'] as String? ?? 'time';
    final sortBy = sortByStr == 'amount' ? SearchSortBy.amount : SearchSortBy.time;

    return SearchQuery(
      keyword: parsed['keyword'] as String?,
      keywordSynonyms: (parsed['keywordSynonyms'] as List<dynamic>?)?.cast<String>() ?? [],
      type: parsed['type'] as String? ?? _filterType,
      minAmount: (parsed['minAmount'] as num?)?.toDouble(),
      maxAmount: (parsed['maxAmount'] as num?)?.toDouble(),
      startDate: startDate ?? _filterStartDate,
      endDate: endDate ?? _filterEndDate,
      parentCategoryId: parentCategoryId,
      categoryId: categoryId,
      payMethod: parsed['payMethod'] as String?,
      sortBy: sortBy,
      intent: parsed['intent'] as String?,
    );
  }

  /// 从分类列表构建分类体系文本（用于 AI 摘要 prompt）
  String _buildTaxonomyText(List<Category> allCats) {
    final childrenMap = <int, List<Category>>{};
    for (final c in allCats) {
      if (c.parentId != null) {
        childrenMap.putIfAbsent(c.parentId!, () => []).add(c);
      }
    }
    final parents = allCats.where((c) => c.parentId == null).toList();
    if (parents.isEmpty) return '';

    final buffer = StringBuffer();
    for (final cat in parents) {
      final children = childrenMap[cat.id] ?? [];
      if (children.isNotEmpty) {
        buffer.writeln('- ${cat.name}（${children.map((c) => c.name).join('、')}）');
      } else {
        buffer.writeln('- ${cat.name}');
      }
    }
    return buffer.toString().trim();
  }

  void _onSearchSubmitted(String value) {
    if (_searchMode == SearchMode.ai) {
      _executeAiSearch();
    } else {
      _executeKeywordSearch();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _focusNode.requestFocus();
    setState(() {
      _results = [];
      _resultStats = null;
      _aiSummary = null;
      _aiIntent = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          _buildSearchHeader(l10n),
          if (_searchMode == SearchMode.ai) _buildAiBanner(l10n),
          _buildFilterChips(l10n),
          Expanded(child: _buildBody(l10n)),
        ],
      ),
    );
  }

  // ==================== 搜索头部 ====================

  Widget _buildSearchHeader(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.s(context, AppDimensions.md),
        vertical: Responsive.s(context, 8),
      ),
      color: context.colors.surface,
      child: Row(
        children: [
          // 返回按钮
          GestureDetector(
            onTap: () => context.pop(),
            child: Icon(Icons.arrow_back_ios, size: 20, color: context.colors.textPrimary),
          ),
          SizedBox(width: Responsive.s(context, 8)),
          // 搜索输入框
          Expanded(
            child: Container(
              height: Responsive.s(context, 40),
              decoration: BoxDecoration(
                color: context.colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(Responsive.s(context, 10)),
              ),
              child: Row(
                children: [
                  SizedBox(width: Responsive.s(context, 10)),
                  Icon(
                    _searchMode == SearchMode.ai ? Icons.auto_awesome : Icons.search,
                    size: 18,
                    color: _searchMode == SearchMode.ai
                        ? context.colors.primary
                        : context.colors.textTertiary,
                  ),
                  SizedBox(width: Responsive.s(context, 6)),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      style: context.textStyles.body.copyWith(fontSize: Responsive.fs(context, 15)),
                      decoration: InputDecoration(
                        hintText: _searchMode == SearchMode.ai
                            ? l10n.searchHint
                            : l10n.searchKeywordPlaceholder,
                        hintStyle: context.textStyles.footnote.copyWith(
                          color: context.colors.textTertiary,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: Responsive.s(context, 10),
                        ),
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: _onSearchSubmitted,
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: Responsive.s(context, 8)),
                        child: Icon(Icons.cancel, size: 18, color: context.colors.textTertiary),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: Responsive.s(context, 8)),
          // 搜索模式切换
          _buildModeToggle(l10n),
        ],
      ),
    );
  }

  Widget _buildModeToggle(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _searchMode = _searchMode == SearchMode.keyword
              ? SearchMode.ai
              : SearchMode.keyword;
        });
        // 如果已有输入，切换模式后自动搜索
        if (_searchController.text.trim().isNotEmpty) {
          if (_searchMode == SearchMode.ai) {
            _executeAiSearch();
          } else {
            _executeKeywordSearch();
          }
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.s(context, 10),
          vertical: Responsive.s(context, 8),
        ),
        decoration: BoxDecoration(
          color: _searchMode == SearchMode.ai
              ? context.colors.primary.withValues(alpha: 0.1)
              : context.colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(Responsive.s(context, 8)),
          border: _searchMode == SearchMode.ai
              ? Border.all(color: context.colors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _searchMode == SearchMode.ai ? Icons.auto_awesome : Icons.text_fields,
              size: 14,
              color: _searchMode == SearchMode.ai
                  ? context.colors.primary
                  : context.colors.textSecondary,
            ),
            SizedBox(width: Responsive.s(context, 4)),
            Text(
              _searchMode == SearchMode.ai ? l10n.searchModeAi : l10n.searchModeKeyword,
              style: context.textStyles.caption.copyWith(
                color: _searchMode == SearchMode.ai
                    ? context.colors.primary
                    : context.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== AI 意图横幅 ====================

  Widget _buildAiBanner(AppLocalizations l10n) {
    if (_aiIntent == null && !_isAiParsing) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.s(context, AppDimensions.md),
        vertical: Responsive.s(context, 8),
      ),
      color: context.colors.primarySurface,
      child: Row(
        children: [
          if (_isAiParsing) ...[
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colors.primary,
              ),
            ),
            SizedBox(width: Responsive.s(context, 8)),
            Text(
              l10n.searchAiParsing,
              style: context.textStyles.caption.copyWith(color: context.colors.primary),
            ),
          ] else if (_aiIntent != null) ...[
            Icon(Icons.auto_awesome, size: 14, color: context.colors.primary),
            SizedBox(width: Responsive.s(context, 6)),
            Expanded(
              child: Text(
                _aiIntent!,
                style: context.textStyles.caption.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== 筛选 Chips ====================

  Widget _buildFilterChips(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.s(context, AppDimensions.md),
        vertical: Responsive.s(context, 6),
      ),
      color: context.colors.surface,
      child: Row(
        children: [
          _buildFilterChip(
            label: l10n.searchFilterAll,
            isSelected: _filterType == null,
            onTap: () {
              setState(() => _filterType = null);
              _reSearch();
            },
          ),
          SizedBox(width: Responsive.s(context, 6)),
          _buildFilterChip(
            label: l10n.searchFilterExpense,
            isSelected: _filterType == 'expense',
            color: context.colors.expense,
            onTap: () {
              setState(() => _filterType = 'expense');
              _reSearch();
            },
          ),
          SizedBox(width: Responsive.s(context, 6)),
          _buildFilterChip(
            label: l10n.searchFilterIncome,
            isSelected: _filterType == 'income',
            color: context.colors.income,
            onTap: () {
              setState(() => _filterType = 'income');
              _reSearch();
            },
          ),
          const Spacer(),
          if (_filterType != null || _filterStartDate != null || _filterEndDate != null)
            GestureDetector(
              onTap: () {
                setState(() {
                  _filterType = null;
                  _filterStartDate = null;
                  _filterEndDate = null;
                });
                _reSearch();
              },
              child: Text(
                l10n.searchFilterClear,
                style: context.textStyles.caption.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    Color? color,
    required VoidCallback onTap,
  }) {
    final chipColor = color ?? context.colors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.s(context, 12),
          vertical: Responsive.s(context, 5),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.1)
              : context.colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(Responsive.s(context, 14)),
          border: isSelected
              ? Border.all(color: chipColor.withValues(alpha: 0.4), width: 1)
              : null,
        ),
        child: Text(
          label,
          style: context.textStyles.caption.copyWith(
            color: isSelected ? chipColor : context.colors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  void _reSearch() {
    if (_searchController.text.trim().isEmpty) return;
    if (_searchMode == SearchMode.ai) {
      _executeAiSearch();
    } else {
      _executeKeywordSearch();
    }
  }

  // ==================== 内容区域 ====================

  Widget _buildBody(AppLocalizations l10n) {
    // 无搜索时显示建议
    if (_searchController.text.trim().isEmpty) {
      return _buildSuggestions(l10n);
    }

    // 搜索中
    if (_isSearching && _results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: context.colors.primary),
            SizedBox(height: Responsive.s(context, AppDimensions.md)),
            Text(
              _isAiParsing ? l10n.searchAiParsing : '',
              style: context.textStyles.caption.copyWith(color: context.colors.textTertiary),
            ),
          ],
        ),
      );
    }

    // 无结果
    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: Responsive.s(context, 48), color: context.colors.textTertiary),
            SizedBox(height: Responsive.s(context, AppDimensions.md)),
            Text(l10n.searchNoResults,
                style: context.textStyles.callout.copyWith(color: context.colors.textSecondary)),
            SizedBox(height: Responsive.s(context, 4)),
            Text(l10n.searchNoResultsHint,
                style: context.textStyles.caption.copyWith(color: context.colors.textTertiary)),
          ],
        ),
      );
    }

    // 结果列表
    return _buildResultList(l10n);
  }

  // ==================== 搜索建议 ====================

  Widget _buildSuggestions(AppLocalizations l10n) {
    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.s(context, AppDimensions.md),
        vertical: Responsive.s(context, 16),
      ),
      children: [
        Text(
          l10n.searchQuickSuggestions,
          style: context.textStyles.footnote.copyWith(
            fontWeight: FontWeight.w600,
            color: context.colors.textSecondary,
          ),
        ),
        SizedBox(height: Responsive.s(context, 12)),
        _buildSuggestionItem(
          icon: Icons.calendar_month,
          text: l10n.searchSuggestionLastMonthExpense,
          onTap: () {
            _searchController.text = '上个月的消费';
            if (_searchMode == SearchMode.ai) {
              _executeAiSearch();
            } else {
              _executeKeywordSearch();
            }
          },
        ),
        _buildSuggestionItem(
          icon: Icons.restaurant,
          text: l10n.searchSuggestionThisMonthFood,
          onTap: () {
            _searchController.text = '本月餐饮消费';
            if (_searchMode == SearchMode.ai) {
              _executeAiSearch();
            } else {
              _executeKeywordSearch();
            }
          },
        ),
        _buildSuggestionItem(
          icon: Icons.trending_up,
          text: l10n.searchSuggestionRecentLarge,
          onTap: () {
            _searchController.text = '最近大额消费';
            if (_searchMode == SearchMode.ai) {
              _executeAiSearch();
            } else {
              _executeKeywordSearch();
            }
          },
        ),
        _buildSuggestionItem(
          icon: Icons.date_range,
          text: l10n.searchSuggestionRecentWeek,
          onTap: () {
            _searchController.text = '最近一周账单';
            if (_searchMode == SearchMode.ai) {
              _executeAiSearch();
            } else {
              _executeKeywordSearch();
            }
          },
        ),
      ],
    );
  }

  Widget _buildSuggestionItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: Responsive.s(context, 8)),
      child: Material(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(Responsive.s(context, AppDimensions.radiusSm)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Responsive.s(context, AppDimensions.radiusSm)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.s(context, 14),
              vertical: Responsive.s(context, 12),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: context.colors.primary),
                SizedBox(width: Responsive.s(context, 10)),
                Expanded(
                  child: Text(
                    text,
                    style: context.textStyles.body.copyWith(fontSize: Responsive.fs(context, 14)),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 12, color: context.colors.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== 结果列表 ====================

  Widget _buildResultList(AppLocalizations l10n) {
    // 按日期分组
    final grouped = <DateTime, List<Transaction>>{};
    for (final t in _results) {
      final dateKey = DateTime(t.transactionDate.year, t.transactionDate.month, t.transactionDate.day);
      grouped.putIfAbsent(dateKey, () => []).add(t);
    }
    final groupEntries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return Column(
      children: [
        // 统计栏
        if (_resultStats != null) _buildResultStats(l10n),
        // AI 摘要
        if (_aiSummary != null) _buildAiSummary(l10n),
        // 结果列表
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: Responsive.s(context, 16)),
            itemCount: groupEntries.length,
            itemBuilder: (context, index) {
              final entry = groupEntries[index];
              return _buildTransactionGroup(entry.key, entry.value, l10n);
            },
          ),
        ),
      ],
    );
  }

  // ==================== 统计栏 ====================

  Widget _buildResultStats(AppLocalizations l10n) {
    final stats = _resultStats!;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.s(context, AppDimensions.md),
        vertical: Responsive.s(context, 8),
      ),
      color: context.colors.surface,
      child: Row(
        children: [
          Text(
            l10n.searchResultCount('${stats.count}'),
            style: context.textStyles.caption.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (stats.totalExpense > 0) ...[
            SizedBox(width: Responsive.s(context, 12)),
            Text(
              '${l10n.searchTotalExpense}: ${context.localeProvider.currency.formatAmount(stats.totalExpense)}',
              style: context.textStyles.caption.copyWith(color: context.colors.expense),
            ),
          ],
          if (stats.totalIncome > 0) ...[
            SizedBox(width: Responsive.s(context, 12)),
            Text(
              '${l10n.searchTotalIncome}: ${context.localeProvider.currency.formatAmount(stats.totalIncome)}',
              style: context.textStyles.caption.copyWith(color: context.colors.income),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== AI 摘要 ====================

  Widget _buildAiSummary(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        horizontal: Responsive.s(context, AppDimensions.md),
        vertical: Responsive.s(context, 6),
      ),
      padding: EdgeInsets.all(Responsive.s(context, 12)),
      decoration: BoxDecoration(
        gradient: context.colors.aiEntryGradient,
        borderRadius: BorderRadius.circular(Responsive.s(context, AppDimensions.radiusSm)),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 14, color: context.colors.primary),
              SizedBox(width: Responsive.s(context, 6)),
              Text(
                l10n.searchAiSummaryTitle,
                style: context.textStyles.footnote.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: Responsive.s(context, 6)),
          Text(
            _aiSummary!,
            style: context.textStyles.body.copyWith(
              fontSize: Responsive.fs(context, 13),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 交易分组 ====================

  Widget _buildTransactionGroup(DateTime date, List<Transaction> transactions, AppLocalizations l10n) {
    double totalExpense = 0;
    double totalIncome = 0;
    for (final t in transactions) {
      if (t.type == 'expense') {
        totalExpense += t.amount;
      } else {
        totalIncome += t.amount;
      }
    }

    final weekdays = [
      l10n.weekMonFull, l10n.weekTueFull, l10n.weekWedFull,
      l10n.weekThuFull, l10n.weekFriFull, l10n.weekSatFull, l10n.weekSunFull,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 日期头
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.s(context, AppDimensions.md),
            vertical: Responsive.s(context, 8),
          ),
          color: context.colors.surfaceSecondary,
          child: Row(
            children: [
              Text(
                '${DateFormat(l10n.txnDayFormat).format(date)} ${weekdays[date.weekday - 1]}',
                style: context.textStyles.footnote.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              if (totalExpense > 0)
                Text(
                  l10n.txnGroupExpenseLabel(context.localeProvider.currency.formatAmount(totalExpense)),
                  style: context.textStyles.caption.copyWith(color: context.colors.expense),
                ),
              if (totalExpense > 0 && totalIncome > 0) const SizedBox(width: 8),
              if (totalIncome > 0)
                Text(
                  l10n.txnGroupIncomeLabel(context.localeProvider.currency.formatAmount(totalIncome)),
                  style: context.textStyles.caption.copyWith(color: context.colors.income),
                ),
            ],
          ),
        ),
        // 交易列表
        ...transactions.map((t) => _buildTransactionItem(t, l10n)),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction t, AppLocalizations l10n) {
    final cat = _categoryMap[t.categoryId];
    final parentCat = t.parentCategoryId != null ? _categoryMap[t.parentCategoryId] : null;
    final catName = cat?.name ?? l10n.txnGroupUncategorized;
    final parentCatName = parentCat?.name;
    final catDisplay = parentCatName != null ? '$parentCatName > $catName' : catName;
    final isExpense = t.type == 'expense';
    final amountColor = isExpense ? context.colors.expense : context.colors.income;

    return GestureDetector(
      onTap: () => context.push('/transactions/${t.id}'),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.s(context, AppDimensions.md),
          vertical: Responsive.s(context, 10),
        ),
        decoration: BoxDecoration(
          color: context.colors.surface,
          border: Border(bottom: BorderSide(color: context.colors.separatorOpaque, width: 0.5)),
        ),
        child: Row(
          children: [
            // 分类图标
            Container(
              width: AppDimensions.categoryIconSize,
              height: AppDimensions.categoryIconSize,
              decoration: BoxDecoration(
                color: context.colors.surfaceSecondary,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              child: Center(
                child: cat?.icon != null
                    ? Text(cat!.icon!, style: const TextStyle(fontSize: 20))
                    : Icon(Icons.receipt_long, size: 20, color: context.colors.textSecondary),
              ),
            ),
            SizedBox(width: Responsive.s(context, 12)),
            // 信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    t.note?.isNotEmpty == true ? t.note! : t.description,
                    style: context.textStyles.body.copyWith(
                      fontWeight: t.note?.isNotEmpty == true ? FontWeight.w500 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: Responsive.s(context, 2)),
                  Text(
                    '${DateFormat('HH:mm').format(t.transactionDate)} · $catDisplay',
                    style: context.textStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // 金额
            Text(
              context.localeProvider.currency.formatWithSign(t.amount, isExpense),
              style: context.textStyles.amountList.copyWith(color: amountColor),
            ),
          ],
        ),
      ),
    );
  }
}
