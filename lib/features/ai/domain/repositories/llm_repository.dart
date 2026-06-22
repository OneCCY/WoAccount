import '../../data/models/llm_config.dart';

/// LLM 服务接口（Domain 层）
abstract class LlmRepository {
  /// 获取当前激活的服务商
  Future<LlmProvider?> getActiveProvider();

  /// 发送聊天请求
  Future<LlmResponse> chat(LlmRequest request);

  /// 解析记账输入（带降级策略：LLM → 规则引擎）
  /// 返回列表支持多笔交易（如 "吃饭24，洗衣服34"）
  /// [categoryTaxonomy] 可选的动态分类体系文本，用于替换默认硬编码分类
  /// [locale] 语言环境（zh/en/ja/ko），影响 LLM 回复语言
  /// [fewShotExamples] 用户历史修正记录（Episodic Memory，Phase 2）
  /// [similarTransactions] 相似历史交易文本（RAG 检索结果）
  Future<List<TransactionParseResult>> parseTransaction(
    String input, {
    String? categoryTaxonomy,
    String locale = 'zh',
    String? fewShotExamples,
    String? similarTransactions,
  });

  /// 测试指定服务商的连接
  Future<bool> testConnection(LlmProvider provider);

  /// 解析自然语言搜索查询为结构化搜索条件
  /// [categoryTaxonomy] 可选的动态分类体系文本
  /// [locale] 语言环境
  /// 返回 JSON Map，包含 keyword/type/dateRange 等字段
  Future<Map<String, dynamic>> parseSearchQuery(String input, {String? categoryTaxonomy, String locale = 'zh'});

  /// 根据搜索结果数据生成自然语言摘要
  /// [categoryTaxonomy] 可选的分类体系，用于更精准的分类分析
  Future<String> generateSearchSummary(String userQuery, Map<String, dynamic> stats, {String? categoryTaxonomy});
}
