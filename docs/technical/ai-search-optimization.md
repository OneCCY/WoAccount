# AI 搜索优化方案

> 目标：提升搜索准确度、降低延迟、优化大数据量性能、增强用户体验
> 涉及文件：`prompt_templates.dart`、`llm_repository_impl.dart`、`transaction_search_page.dart`、`transaction_repository_impl.dart`、`transaction_repository.dart`

---

## 优化项 1：搜索 Prompt 注入日期上下文修复

**问题**: `prompt_templates.dart:136` 的 system prompt 写了 `以今天的日期为基准计算`，但实际日期只在 `searchQueryParseUser`（第 165-169 行）的 user message 中提供。部分弱推理模型（如 qwen-turbo、glm-3-turbo）可能无法正确关联两条消息中的日期信息，导致"本月"、"上周"等时间词解析错误。

**文件**: `lib/core/ai/prompt_templates.dart:106-161`、`:165-169`

**方案**:
- 在 `searchQueryParseSystem` 中将 `以今天的日期为基准计算` 改为明确指令，告知日期在 user message 中：
  ```dart
  static String searchQueryParseSystem(String categoryTaxonomy, {String locale = 'zh'}) {
    return '''
  你是一个账单搜索助手。用户会用自然语言描述想查找的账单，你需要将其解析为结构化查询条件。
  
  ## 今天的日期
  
  Today's date will be provided in the user message. Use it as the reference for all relative date calculations.
  今天日期会在 user message 中提供，请以此为基准计算所有相对日期。
  
  ## 分类体系
  ...
  ```
- 同步让 `searchQueryParseUser` 格式与 `parseTransactionUser` 保持一致（当前两者格式略不同）

**验证**: 搜索"本月餐饮" → `startDate` 应为当月 1 日，`endDate` 应为今天

---

## 优化项 2：同义词扩展改为数据驱动

**问题**: `prompt_templates.dart:148-152` 的同义词扩展完全依赖 LLM 基于示例"脑补"。LLM 生成的同义词（如搜"奶茶"→["喜茶","奈雪","蜜雪冰城"]）可能与用户实际记录完全对不上，消耗 token 但不提升召回率。更严重的是，LLM 可能过度扩展（如"咖啡"→["星巴克","瑞幸","Manner","库迪","Costa","太平洋咖啡","%Arabica"...]），每个同义词都触发一条 `LIKE` 查询，拖慢 SQLite。

**文件**: `lib/features/transaction/presentation/pages/transaction_search_page.dart:151-169`、`lib/core/ai/prompt_templates.dart:146-152`

**方案分两层**:

### 2a. 本地同义词表（高频、零成本）
- 从用户历史数据中提取高频关键词，构建本地同义词映射：
  ```dart
  /// 从用户历史交易中构建关键词关联表
  Future<Map<String, List<String>>> buildSynonymMap(int bookId) async {
    // 1. 取最近 500 笔交易的 description + note + originalInput
    // 2. 分词（简单按空格/标点分割）
    // 3. 统计共现关系：如果"喜茶"和"奶茶"经常出现在同类交易中，互为同义词
    // 4. 缓存到内存，定期刷新
  }
  ```
- 新增 `TransactionRepository.getRecentForSynonyms(bookId, limit: 500)` 方法
- 在 `_executeAiSearch` 调用 LLM 之前，先用本地同义词表扩展
- 将本地扩展的同义词作为"参考"传给 LLM prompt，而非让 LLM 从零生成

### 2b. LLM 同义词约束
- 修改 `searchQueryParseSystem` 的同义词扩展规则：
  ```
  ## 关键词扩展规则
  
  当用户搜索品牌或品类时，可扩展同义词，但限制在 5 个以内。
  优先使用以下用户历史中出现过的关联词（如果提供）：
  {localSynonyms}
  
  如果没有用户历史数据，再基于常识扩展。
  ```
- 将本地同义词表注入 prompt，让 LLM 在已有基础上筛选而非从零生成

**验证**: 用户历史中有 "喜茶" 3 次、"奈雪" 1 次 → 搜 "奶茶" 时自动带上 ["喜茶", "奈雪"]，不多不少

---

## 优化项 3：searchWithStats 消除重复查询

**问题**: `transaction_repository_impl.dart:280-310` 的 `searchWithStats` 内部调用了 `search()` 获取全部结果，然后在内存中遍历计算统计。这意味着 AI 搜索流程中：
1. `repo.search(bookId, searchQuery)` → 查询 1（第 169 行）
2. `repo.searchWithStats(bookId, searchQuery)` → 内部再调一次 `search()` → 查询 2（第 177 行）

同一组数据查了两遍。

**文件**: `lib/features/transaction/data/repositories/transaction_repository_impl.dart:280-310`

**方案**:
- 方案 A（推荐）：在 `search` 方法中同时返回结果和统计，避免二次查询：
  ```dart
  /// 搜索结果 + 统计的复合返回
  class SearchResultWithStats {
    final List<Transaction> transactions;
    final SearchResultStats stats;
    const SearchResultWithStats(this.transactions, this.stats);
  }
  
  Future<SearchResultWithStats> searchWithResults(int bookId, SearchQuery query) async {
    final results = await search(bookId, query);
    // 在同一方法中计算统计，只遍历一次
    ...
    return SearchResultWithStats(results, stats);
  }
  ```
- 方案 B：使用 SQL 聚合函数直接在数据库层计算统计（参考 `getStats` 方法第 163-197 行的模式），避免把所有记录加载到内存
- 修改 `transaction_search_page.dart:168-178` 从两次调用改为一次

**验证**: AI 搜索只触发一次 SQL 查询，搜索 1000 条记录时内存占用减半

---

## 优化项 4：AI 搜索降级通知用户

**问题**: `transaction_search_page.dart:211-219` 中 AI 搜索失败时静默切换为关键词搜索，用户完全不知道搜索质量已经降级。

**文件**: `lib/features/transaction/presentation/pages/transaction_search_page.dart:211-219`

**方案**:
- 降级时显示轻量 Toast 提示：
  ```dart
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _isAiParsing = false;
      _isSearching = false;
    });
    
    // 🔧 新增：通知用户降级
    Toast.show(
      context,
      l10n.searchAiFallbackMessage,  // "AI 搜索暂时不可用，已切换为关键词搜索"
      type: ToastType.warning,
    );
    
    _searchMode = SearchMode.keyword;
    _executeKeywordSearch();
  }
  ```
- 同步在 AI banner 区域显示降级状态（区别于"正在解析"和"AI 意图"的第三种状态）

**新增 l10n key**: `searchAiFallbackMessage`

**验证**: 模拟 LLM 超时 → 页面显示"AI 搜索暂时不可用"Toast + 结果仍正常展示

---

## 优化项 5：搜索结果分页

**问题**: `transaction_repository_impl.dart:200-277` 的 `search` 方法一次性返回所有匹配结果。当用户有数千笔记录搜"本月"时，可能返回 100+ 条结果全部加载到内存。

**文件**: `lib/features/transaction/domain/repositories/transaction_repository.dart:153`、`lib/features/transaction/data/repositories/transaction_repository_impl.dart:200-277`、`lib/features/transaction/presentation/pages/transaction_search_page.dart:779`

**方案**:
- `SearchQuery` 增加分页参数：
  ```dart
  class SearchQuery {
    ...
    final int limit;    // 每页条数，默认 50
    final int offset;   // 偏移量，默认 0
  }
  ```
- `TransactionRepository` 接口增加分页搜索方法：
  ```dart
  Future<List<Transaction>> searchPaged(int bookId, SearchQuery query, {int limit = 50, int offset = 0});
  ```
- `search` 实现中增加 `.limit(limit, offset: offset)`（Drift 已支持，参考 `getPaged` 方法第 139-145 行）
- `transaction_search_page.dart` 中 `_results` 改为懒加载模式：
  - 初始加载 50 条
  - `ListView.builder` 滚动到底部时加载下一页
  - 统计栏的 count/sum/avg 仍通过独立的 `searchWithStats` SQL 聚合获取（不依赖全量数据）

**注意**: 分页与 `searchWithStats` 的聚合是独立的——stats 需要全量数据计算，但列表展示可以分页。如果实施了优化项 3 的 SQL 聚合方案，stats 不需要加载全部记录。

**验证**: 搜"今年"返回 500+ 条 → 初始只加载 50 条，滚动加载更多，无卡顿

---

## 优化项 6：搜索建议数据化

**问题**: `transaction_search_page.dart:655-719` 的搜索建议是硬编码的 4 条（"上个月的消费"、"本月餐饮消费"等），不基于用户实际数据。

**文件**: `lib/features/transaction/presentation/pages/transaction_search_page.dart:655-719`

**方案**:
- 增加基于用户数据的智能建议：
  ```dart
  Future<List<SearchSuggestion>> _buildSmartSuggestions() async {
    final repo = ref.read(transactionRepositoryProvider);
    final bookId = ref.read(currentBookProvider);
    final suggestions = <SearchSuggestion>[];
    
    // 1. 高频消费分类（最近 30 天的 top 3 分类）
    final recent = await repo.getByDateRange(bookId, thirtyDaysAgo, now);
    final catCount = <int, int>{};
    for (final t in recent) { catCount[t.parentCategoryId] = (catCount[t.parentCategoryId] ?? 0) + 1; }
    final topCats = catCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    for (final entry in topCats.take(2)) {
      final cat = _categoryMap[entry.key];
      if (cat != null) suggestions.add(SearchSuggestion(
        icon: cat.icon ?? '📦',
        text: '本月${cat.name}消费',
        query: '本月${cat.name}消费',
      ));
    }
    
    // 2. 最近一笔大额交易
    final bigTxns = recent.where((t) => t.amount > 200).toList();
    if (bigTxns.isNotEmpty) {
      bigTxns.sort((a, b) => b.amount.compareTo(a.amount));
      suggestions.add(SearchSuggestion(
        icon: '💰',
        text: '最近大额: ${bigTxns.first.description}',
        query: '大于200的消费',
      ));
    }
    
    // 3. 保留原有的通用建议作为兜底
    ...
    return suggestions;
  }
  ```
- 建议列表在页面 `initState` 时异步加载，加载完成前显示骨架屏或通用建议
- 最多展示 5 条建议

**验证**: 用户本月点了 10 次外卖 → 搜索页建议区显示"本月餐饮美食消费" + 自定义建议

---

## 优化项 7：分类名称模糊匹配（对齐文本记账）

**问题**: `transaction_search_page.dart:244-259` 的 `_buildSearchQueryFromParsed` 中，分类名匹配只做精确比较（`c.name == subCatName`），不像文本记账流程中有 `contains` 模糊匹配。如果 LLM 返回 "餐饮" 而数据库中是 "餐饮美食"，搜索分类筛选直接失效。

**文件**: `lib/features/transaction/presentation/pages/transaction_search_page.dart:239-259`

**方案**:
- 引入与 `ai_chat_page.dart:456-467` 相同的三层匹配策略（精确 → 包含 → null）：
  ```dart
  if (parentCatName != null) {
    // 1. 精确匹配
    for (final c in _categoryMap.values) {
      if (c.name == parentCatName && c.level == 1) {
        parentCategoryId = c.id;
        break;
      }
    }
    // 2. 包含匹配
    if (parentCategoryId == null) {
      for (final c in _categoryMap.values) {
        if (c.level == 1 && (c.name.contains(parentCatName) || parentCatName.contains(c.name))) {
          parentCategoryId = c.id;
          break;
        }
      }
    }
  }
  ```
- 对 `subcategory` 同理处理（第 244-251 行）

**验证**: 搜"餐饮花了多少" → LLM 返回 `parentCategory: "餐饮"` → 模糊匹配到 "餐饮美食" → 正确筛选

---

## 优化项 8：搜索结果中分类分布计算下沉到 Repository

**问题**: `transaction_search_page.dart:181-199` 在 UI 层（Presentation）遍历所有搜索结果计算分类分布。这属于业务逻辑，不应在 UI 层处理，且当结果数量大时会阻塞 UI 线程。

**文件**: `lib/features/transaction/presentation/pages/transaction_search_page.dart:181-199`

**方案**:
- 将分类分布计算移入 `SearchResultStats`：
  ```dart
  class SearchResultStats {
    ...
    final Map<String, double> categoryDistribution;  // 新增
  }
  ```
- 在 `TransactionRepositoryImpl.searchWithStats` 中计算（或在优化项 3 的新方法中一并计算）
- `transaction_search_page.dart` 直接使用 `stats.categoryDistribution`，不再在 UI 层遍历

**验证**: 搜索 500 条结果 → 分类分布计算在 Repository 层完成 → UI 无卡顿

---

## 优化项 9：AI 搜索摘要 Prompt 增加分类体系上下文

**问题**: `prompt_templates.dart:175-186` 的 `searchSummarySystem` 只告诉 LLM "你是账单分析助手"，没有注入用户分类体系。当统计数据中出现分类名时，LLM 无法给出分类级别的分析洞察。

**文件**: `lib/core/ai/prompt_templates.dart:175-186`、`lib/features/ai/data/repositories/llm_repository_impl.dart:367-405`

**方案**:
- `searchSummarySystem` 增加 `categoryTaxonomy` 参数：
  ```dart
  static String searchSummarySystem({String? categoryTaxonomy}) {
    return '''
  你是一个账单分析助手。根据用户查询和提供的交易数据，生成简洁的分析摘要。
  
  ${categoryTaxonomy != null ? '## 用户分类体系\n\n$categoryTaxonomy\n' : ''}
  
  ## 回复风格
  - 简洁明了，不啰嗦
  - 数据准确，有具体数字
  - 适当使用emoji，增加亲和力
  - 中文回复
  - 如果有统计数据，给出直观的结论
  - 如果有分类分布数据，分析消费结构是否合理
  ''';
  }
  ```
- `generateSearchSummary` 方法增加 `categoryTaxonomy` 参数透传
- `_executeAiSearch` 中传入 `_buildCategoryTaxonomy()` 的结果（可复用 `ai_chat_page.dart` 中的缓存逻辑，或提取为公共方法）

**验证**: 搜"本月消费" → AI 摘要中出现"餐饮占比 45%，建议适当控制外卖支出"等分类级洞察

---

## 优化项 10：关键词搜索的 LIKE 查询性能优化

**问题**: `transaction_repository_impl.dart:214-223` 中，每个关键词对 3 个字段（description、note、originalInput）做 `LIKE '%keyword%'` 查询，且同义词之间用 `OR` 连接。如果 LLM 返回 7 个同义词，实际 SQL 是 `WHERE (desc LIKE '%kw1%' OR note LIKE '%kw1%' OR orig LIKE '%kw1%') OR (desc LIKE '%kw2%' ...) OR ... × 7` = 21 个 LIKE 条件。SQLite 的 LIKE '%...%' 无法使用索引，全表扫描。

**文件**: `lib/features/transaction/data/repositories/transaction_repository_impl.dart:209-228`

**方案（短期）**:
- 限制同义词数量上限（prompt 端 + 代码端双重限制）：
  ```dart
  final allKeywords = [query.keyword!, ...query.keywordSynonyms.take(5)]  // 最多 6 个关键词
      .where((k) => k.isNotEmpty)
      .toList();
  ```

**方案（长期，可选）**:
- 为 description / note / originalInput 字段创建 SQLite FTS5 全文索引：
  ```sql
  CREATE VIRTUAL TABLE transactions_fts USING fts5(description, note, originalInput);
  ```
- 搜索时使用 FTS5 的 `MATCH` 语法替代 `LIKE`，性能提升 10-100x
- 需要处理 Drift 的 FTS5 支持（可能需要自定义 Query）

**验证**: 搜"奶茶" + 5 个同义词 → LIKE 条件从 21 个降为 18 个（短期）或使用 FTS5 毫秒级返回（长期）

---

## 执行顺序建议

| 顺序 | 优化项 | 难度 | 预期收益 |
|------|--------|------|----------|
| 1 | 搜索 Prompt 日期上下文修复 | ⭐ | 时间搜索准确度 |
| 2 | AI 搜索降级通知 | ⭐ | 用户体验透明度 |
| 3 | 分类名模糊匹配 | ⭐ | 分类筛选命中率 |
| 4 | 同义词数量限制 | ⭐ | SQL 性能 |
| 5 | searchWithStats 消除重复查询 | ⭐⭐ | 查询性能减半 |
| 6 | 搜索结果分页 | ⭐⭐ | 大数据量性能 |
| 7 | 分类分布计算下沉 | ⭐⭐ | 架构规范 |
| 8 | AI 摘要增加分类上下文 | ⭐⭐ | 摘要质量 |
| 9 | 搜索建议数据化 | ⭐⭐⭐ | 用户体验个性化 |
| 10 | 同义词数据驱动 | ⭐⭐⭐ | 搜索召回率 |
| 11 | FTS5 全文索引（长期） | ⭐⭐⭐ | 搜索性能 10-100x |
