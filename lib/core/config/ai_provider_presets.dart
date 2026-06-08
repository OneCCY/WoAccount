/// AI 服务商预设配置
///
/// 独立配置文件，支持用户数据导出。
/// 每个服务商预设包含名称、默认请求地址、预设模型列表等信息。
library;

/// 服务商预设
class AiProviderPreset {
  /// 唯一标识，如 'deepseek', 'openai'
  final String key;

  /// 显示名称
  final String name;

  /// 默认请求地址（base_url）
  final String baseUrl;

  /// 预设模型列表（API 获取失败时的 fallback）
  final List<String> defaultModels;

  /// 备注说明
  final String note;

  /// 图标（Emoji）
  final String icon;

  const AiProviderPreset({
    required this.key,
    required this.name,
    required this.baseUrl,
    this.defaultModels = const [],
    this.note = '',
    this.icon = '🤖',
  });
}

/// 内置服务商预设列表
const List<AiProviderPreset> aiProviderPresets = [
  AiProviderPreset(
    key: 'deepseek',
    name: 'DeepSeek',
    baseUrl: 'https://api.deepseek.com',
    defaultModels: ['deepseek-chat', 'deepseek-reasoner'],
    note: '高性价比国产大模型',
    icon: '🐋',
  ),
  AiProviderPreset(
    key: 'openai',
    name: 'OpenAI',
    baseUrl: 'https://api.openai.com/v1',
    defaultModels: ['gpt-4o', 'gpt-4o-mini', 'gpt-4.1', 'gpt-4.1-mini', 'o3-mini', 'o4-mini'],
    note: '需海外网络访问',
    icon: '🟢',
  ),
  AiProviderPreset(
    key: 'qwen',
    name: '通义千问 (阿里)',
    baseUrl: 'https://dashscope.aliyuncs.com/compatible-mode/v1',
    defaultModels: ['qwen-max', 'qwen-plus', 'qwen-turbo', 'qwen-long'],
    note: '使用兼容模式地址',
    icon: '☁️',
  ),
  AiProviderPreset(
    key: 'doubao',
    name: '豆包 (字节)',
    baseUrl: 'https://ark.cn-beijing.volces.com/api/v3',
    defaultModels: [],
    note: '需在火山方舟创建推理接入点，模型名使用接入点 ID',
    icon: '🫘',
  ),
  AiProviderPreset(
    key: 'zhipu',
    name: '智谱AI',
    baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
    defaultModels: ['glm-4-flash', 'glm-4-air', 'glm-4', 'glm-4-long', 'glm-3-turbo'],
    note: 'glm-4-flash 有免费额度',
    icon: '🔷',
  ),
  AiProviderPreset(
    key: 'kimi',
    name: '月之暗面 (Kimi)',
    baseUrl: 'https://api.moonshot.cn/v1',
    defaultModels: ['moonshot-v1-8k', 'moonshot-v1-32k', 'moonshot-v1-128k'],
    note: '擅长长文本理解',
    icon: '🌙',
  ),
  AiProviderPreset(
    key: 'claude',
    name: 'Anthropic (Claude)',
    baseUrl: 'https://api.anthropic.com/v1',
    defaultModels: ['claude-sonnet-4-20250514', 'claude-haiku-3-5-20241022', 'claude-opus-4-20250514'],
    note: 'API 格式与 OpenAI 不兼容，需额外适配',
    icon: '🟠',
  ),
  AiProviderPreset(
    key: 'ollama',
    name: 'Ollama (本地)',
    baseUrl: 'http://localhost:11434/v1',
    defaultModels: [],
    note: '需本地运行 Ollama 服务，模型名取决于本地安装',
    icon: '🦙',
  ),
];

/// 自定义服务商标识
const String kCustomProviderKey = 'custom';

/// 根据 key 获取预设，未找到返回 null
AiProviderPreset? getPresetByKey(String key) {
  for (final p in aiProviderPresets) {
    if (p.key == key) return p;
  }
  return null;
}
