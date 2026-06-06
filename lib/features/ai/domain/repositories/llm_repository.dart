import '../../data/models/llm_config.dart';

/// LLM 服务接口（Domain 层）
abstract class LlmRepository {
  /// 获取当前激活的服务商
  Future<LlmProvider?> getActiveProvider();

  /// 发送聊天请求
  Future<LlmResponse> chat(LlmRequest request);

  /// 解析记账输入（带降级策略：LLM → 规则引擎）
  Future<TransactionParseResult> parseTransaction(String input);

  /// 测试指定服务商的连接
  Future<bool> testConnection(LlmProvider provider);
}
