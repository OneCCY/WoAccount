import '../../data/models/llm_config.dart';

/// LLM 服务接口（Domain 层）
abstract class LlmRepository {
  /// 获取当前配置
  Future<LlmConfig> getConfig();

  /// 更新配置
  Future<void> updateConfig(LlmConfig config);

  /// 发送聊天请求
  Future<LlmResponse> chat(LlmRequest request);

  /// 解析记账输入（带降级策略：LLM → 规则引擎）
  Future<TransactionParseResult> parseTransaction(String input);

  /// 测试连接
  Future<bool> testConnection();
}
