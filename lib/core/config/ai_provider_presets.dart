/// AI 服务商预设配置
///
/// 独立配置文件，支持用户数据导出。
/// 每个服务商预设包含名称、默认请求地址、按能力分组的预设模型列表等信息。
library;

import 'package:wo_account/l10n/app_localizations.dart';

/// API 格式类型
enum ApiFormat {
  /// OpenAI 兼容格式（/v1/chat/completions）
  openai,

  /// Anthropic Messages API 格式（/messages）
  anthropic,
}

/// 服务商预设
class AiProviderPreset {
  /// 唯一标识，如 'deepseek', 'openai'
  final String key;

  /// 显示名称（中文默认值，作为 fallback）
  final String name;

  /// 默认请求地址（base_url）
  final String baseUrl;

  /// 预设模型列表（API 获取失败时的 fallback，保持向后兼容）
  final List<String> defaultModels;

  /// 按能力分组的默认模型列表
  /// key: 能力名称 ('text', 'vision', 'audio')
  /// value: 该能力下的默认模型列表
  final Map<String, List<String>> defaultModelsByCapability;

  /// 备注说明（中文默认值，作为 fallback）
  final String note;

  /// 图标（Emoji）
  final String icon;

  /// API 格式（默认 OpenAI 兼容）
  final ApiFormat apiFormat;

  /// 自定义模型列表获取地址（为空时使用智能候选策略）
  final String? modelsUrl;

  const AiProviderPreset({
    required this.key,
    required this.name,
    required this.baseUrl,
    this.defaultModels = const [],
    this.defaultModelsByCapability = const {},
    this.note = '',
    this.icon = '🤖',
    this.apiFormat = ApiFormat.openai,
    this.modelsUrl,
  });

  /// 获取本地化名称
  String getLocalizedName(AppLocalizations l10n) {
    return _nameMap[key]?.call(l10n) ?? name;
  }

  /// 获取本地化备注
  String getLocalizedNote(AppLocalizations l10n) {
    return _noteMap[key]?.call(l10n) ?? note;
  }

  static final Map<String, String Function(AppLocalizations)> _nameMap = {
    'qwen': (l) => l.aiPresetQwenName,
    'doubao': (l) => l.aiPresetDoubaoName,
    'zhipu': (l) => l.aiPresetZhipuName,
    'kimi': (l) => l.aiPresetKimiName,
    'mimo': (l) => l.aiPresetMimoName,
    'ollama': (l) => l.aiPresetOllamaName,
  };

  static final Map<String, String Function(AppLocalizations)> _noteMap = {
    'deepseek': (l) => l.aiPresetDeepseekNote,
    'openai': (l) => l.aiPresetOpenaiNote,
    'qwen': (l) => l.aiPresetQwenNote,
    'doubao': (l) => l.aiPresetDoubaoNote,
    'zhipu': (l) => l.aiPresetZhipuNote,
    'kimi': (l) => l.aiPresetKimiNote,
    'claude': (l) => l.aiPresetClaudeNote,
    'mimo': (l) => l.aiPresetMimoNote,
    'ollama': (l) => l.aiPresetOllamaNote,
  };
}

/// 内置服务商预设列表
const List<AiProviderPreset> aiProviderPresets = [
  AiProviderPreset(
    key: 'deepseek',
    name: 'DeepSeek',
    baseUrl: 'https://api.deepseek.com',
    defaultModels: ['deepseek-chat', 'deepseek-reasoner'],
    defaultModelsByCapability: {
      'text': ['deepseek-chat', 'deepseek-reasoner'],
    },
    note: '高性价比国产大模型',
    icon: '🐋',
  ),
  AiProviderPreset(
    key: 'openai',
    name: 'OpenAI',
    baseUrl: 'https://api.openai.com/v1',
    defaultModels: ['gpt-4o', 'gpt-4o-mini', 'gpt-4.1', 'gpt-4.1-mini', 'o3-mini', 'o4-mini'],
    defaultModelsByCapability: {
      'text': ['gpt-4o-mini', 'gpt-4.1-mini', 'o3-mini', 'o4-mini'],
      'vision': ['gpt-4o', 'gpt-4.1'],
      'audio': ['whisper-1'],
    },
    note: '需海外网络访问',
    icon: '🟢',
  ),
  AiProviderPreset(
    key: 'qwen',
    name: '通义千问 (阿里)',
    baseUrl: 'https://dashscope.aliyuncs.com/compatible-mode/v1',
    defaultModels: ['qwen-max', 'qwen-plus', 'qwen-turbo', 'qwen-long'],
    defaultModelsByCapability: {
      'text': ['qwen-max', 'qwen-plus', 'qwen-turbo', 'qwen-long'],
      'vision': ['qwen-vl-max', 'qwen-vl-plus'],
      'audio': ['paraformer-v2', 'sense-voice-v1'],
    },
    note: '使用兼容模式地址',
    icon: '☁️',
  ),
  AiProviderPreset(
    key: 'doubao',
    name: '豆包 (字节)',
    baseUrl: 'https://ark.cn-beijing.volces.com/api/v3',
    defaultModels: [],
    defaultModelsByCapability: {
      'text': [],
    },
    note: '需在火山方舟创建推理接入点，模型名使用接入点 ID',
    icon: '🫘',
  ),
  AiProviderPreset(
    key: 'zhipu',
    name: '智谱AI',
    baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
    defaultModels: ['glm-4-flash', 'glm-4-air', 'glm-4', 'glm-4-long', 'glm-3-turbo'],
    defaultModelsByCapability: {
      'text': ['glm-4-flash', 'glm-4-air', 'glm-4', 'glm-4-long', 'glm-3-turbo'],
      'vision': ['glm-4v', 'glm-4v-plus'],
    },
    note: 'glm-4-flash 有免费额度',
    icon: '🔷',
  ),
  AiProviderPreset(
    key: 'kimi',
    name: '月之暗面 (Kimi)',
    baseUrl: 'https://api.moonshot.cn/v1',
    defaultModels: ['moonshot-v1-8k', 'moonshot-v1-32k', 'moonshot-v1-128k'],
    defaultModelsByCapability: {
      'text': ['moonshot-v1-8k', 'moonshot-v1-32k', 'moonshot-v1-128k'],
    },
    note: '擅长长文本理解',
    icon: '🌙',
  ),
  AiProviderPreset(
    key: 'claude',
    name: 'Anthropic (Claude)',
    baseUrl: 'https://api.anthropic.com',
    defaultModels: [
      'claude-sonnet-4-20250514',
      'claude-haiku-3-5-20241022',
      'claude-opus-4-20250514',
    ],
    defaultModelsByCapability: {
      'text': ['claude-sonnet-4-20250514', 'claude-haiku-3-5-20241022', 'claude-opus-4-20250514'],
      'vision': ['claude-sonnet-4-20250514', 'claude-opus-4-20250514'],
    },
    note: '使用 Anthropic Messages API',
    icon: '🟠',
    apiFormat: ApiFormat.anthropic,
  ),
  AiProviderPreset(
    key: 'mimo',
    name: '小米 MiMo',
    baseUrl: 'https://token-plan-cn.xiaomimimo.com/v1',
    defaultModels: ['MiMo-7B-RL'],
    defaultModelsByCapability: {
      'text': ['MiMo-7B-RL'],
    },
    note: '支持 OpenAI/Anthropic 兼容协议，中国/新加坡/欧洲多集群',
    icon: '📱',
  ),
  AiProviderPreset(
    key: 'ollama',
    name: 'Ollama (本地)',
    baseUrl: 'http://localhost:11434/v1',
    defaultModels: [],
    defaultModelsByCapability: {
      'text': [],
    },
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
