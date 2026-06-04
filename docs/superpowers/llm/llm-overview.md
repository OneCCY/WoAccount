# WoAccount LLM架构设计

> **版本**: v1.0 | **创建日期**: 2026-06-04

---

## 1. 整体架构

```
┌─────────────────────────────────────────────────────────┐
│                      Flutter App                          │
│  ┌─────────────────────────────────────────────────────┐│
│  │                  Riverpod状态管理                    ││
│  └───────────────────────────┬─────────────────────────┘│
│                              │                           │
│  ┌───────────────────────────▼─────────────────────────┐│
│  │                  LLM服务层                           ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ ││
│  │  │ LLM配置管理  │  │ Prompt模板  │  │ 结果解析器  │ ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘ ││
│  └───────────────────────────┬─────────────────────────┘│
│                              │                           │
│  ┌───────────────────────────▼─────────────────────────┐│
│  │                  网络请求层                          ││
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ ││
│  │  │   Dio客户端  │  │  重试机制   │  │  错误处理   │ ││
│  │  └─────────────┘  └─────────────┘  └─────────────┘ ││
│  └───────────────────────────┬─────────────────────────┘│
│                              │                           │
└──────────────────────────────┼───────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────┐
│                    LLM API服务                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │  通义千问    │  │  DeepSeek   │  │  智谱AI     │    │
│  └─────────────┘  └─────────────┘  └─────────────┘    │
└─────────────────────────────────────────────────────────┘
```

---

## 2. 核心组件

### 2.1 LLM配置管理

```dart
// lib/features/ai/data/models/llm_config.dart

class LlmConfig {
  final String providerId;      // 提供商ID
  final String apiKey;          // API Key
  final String baseUrl;         // 请求地址
  final String model;           // 模型名称
  final double temperature;     // 温度参数
  final int maxTokens;          // 最大token数
  final int timeoutSeconds;     // 超时时间
  
  const LlmConfig({
    required this.providerId,
    required this.apiKey,
    required this.baseUrl,
    required this.model,
    this.temperature = 0.0,
    this.maxTokens = 1000,
    this.timeoutSeconds = 30,
  });
  
  // 从数据库加载
  factory LlmConfig.fromSettings(Map<String, String> settings) {
    return LlmConfig(
      providerId: settings['llm_provider'] ?? 'qwen',
      apiKey: settings['llm_api_key'] ?? '',
      baseUrl: settings['llm_base_url'] ?? '',
      model: settings['llm_model'] ?? '',
      temperature: double.tryParse(settings['llm_temperature'] ?? '0') ?? 0.0,
      maxTokens: int.tryParse(settings['llm_max_tokens'] ?? '1000') ?? 1000,
      timeoutSeconds: int.tryParse(settings['llm_timeout'] ?? '30') ?? 30,
    );
  }
}
```

### 2.2 提供商定义

```dart
// lib/features/ai/data/models/llm_provider.dart

class LlmProvider {
  final String id;
  final String name;
  final String defaultBaseUrl;
  final String defaultModel;
  final List<String> availableModels;
  
  const LlmProvider({
    required this.id,
    required this.name,
    required this.defaultBaseUrl,
    required this.defaultModel,
    required this.availableModels,
  });
}

// 预设提供商
class LlmProviders {
  static const qwen = LlmProvider(
    id: 'qwen',
    name: '通义千问',
    defaultBaseUrl: 'https://dashscope.aliyuncs.com/api/v1',
    defaultModel: 'qwen-turbo',
    availableModels: ['qwen-turbo', 'qwen-plus', 'qwen-max'],
  );
  
  static const deepseek = LlmProvider(
    id: 'deepseek',
    name: 'DeepSeek',
    defaultBaseUrl: 'https://api.deepseek.com/v1',
    defaultModel: 'deepseek-chat',
    availableModels: ['deepseek-chat', 'deepseek-coder'],
  );
  
  static const zhipu = LlmProvider(
    id: 'zhipu',
    name: '智谱AI',
    defaultBaseUrl: 'https://open.bigmodel.cn/api/paas/v4',
    defaultModel: 'glm-4-flash',
    availableModels: ['glm-4-flash', 'glm-4', 'glm-4v'],
  );
  
  static const moonshot = LlmProvider(
    id: 'moonshot',
    name: '月之暗面',
    defaultBaseUrl: 'https://api.moonshot.cn/v1',
    defaultModel: 'moonshot-v1-8k',
    availableModels: ['moonshot-v1-8k', 'moonshot-v1-32k', 'moonshot-v1-128k'],
  );
  
  static const xunfei = LlmProvider(
    id: 'xunfei',
    name: '讯飞星火',
    defaultBaseUrl: 'https://spark-api-open.xf-yun.com/v1',
    defaultModel: 'generalv3.5',
    availableModels: ['generalv3.5', 'generalv3', 'pro-128k'],
  );
  
  // 所有提供商
  static const List<LlmProvider> all = [
    qwen,
    deepseek,
    zhipu,
    moonshot,
    xunfei,
  ];
  
  // 根据ID获取提供商
  static LlmProvider? getById(String id) {
    return all.where((p) => p.id == id).firstOrNull;
  }
}
```

---

## 3. LLM服务实现

### 3.1 服务接口

```dart
// lib/features/ai/domain/repositories/llm_repository.dart

abstract class LlmRepository {
  // 发送聊天请求
  Future<LlmResponse> chat(LlmRequest request);
  
  // 解析记账输入
  Future<TransactionParseResult> parseTransaction(String input);
  
  // AI对话
  Future<String> chatWithAi(String message, List<ChatMessage> history);
  
  // 获取当前配置
  Future<LlmConfig> getConfig();
  
  // 更新配置
  Future<void> updateConfig(LlmConfig config);
  
  // 测试连接
  Future<bool> testConnection();
}

// 请求模型
class LlmRequest {
  final List<ChatMessage> messages;
  final String? model;
  final double? temperature;
  final int? maxTokens;
  
  const LlmRequest({
    required this.messages,
    this.model,
    this.temperature,
    this.maxTokens,
  });
}

// 响应模型
class LlmResponse {
  final String content;
  final String model;
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;
  
  const LlmResponse({
    required this.content,
    required this.model,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });
}

// 聊天消息
class ChatMessage {
  final String role; // system/user/assistant
  final String content;
  
  const ChatMessage({
    required this.role,
    required this.content,
  });
}

// 解析结果
class TransactionParseResult {
  final double amount;
  final String category;
  final String? subcategory;
  final String description;
  final double confidence;
  final String? date;
  final String? note;
  
  const TransactionParseResult({
    required this.amount,
    required this.category,
    this.subcategory,
    required this.description,
    required this.confidence,
    this.date,
    this.note,
  });
}
```

### 3.2 服务实现

```dart
// lib/features/ai/data/repositories/llm_repository_impl.dart

import 'package:dio/dio.dart';

class LlmRepositoryImpl implements LlmRepository {
  final Dio _dio;
  final UserSettingsRepository _settingsRepository;
  LlmConfig? _currentConfig;
  
  LlmRepositoryImpl(this._dio, this._settingsRepository);
  
  @override
  Future<LlmConfig> getConfig() async {
    if (_currentConfig != null) return _currentConfig!;
    
    final settings = await _settingsRepository.getSettings([
      'llm_provider',
      'llm_api_key',
      'llm_base_url',
      'llm_model',
      'llm_temperature',
      'llm_max_tokens',
      'llm_timeout',
    ]);
    
    _currentConfig = LlmConfig.fromSettings(settings);
    return _currentConfig!;
  }
  
  @override
  Future<void> updateConfig(LlmConfig config) async {
    await _settingsRepository.updateSettings({
      'llm_provider': config.providerId,
      'llm_api_key': config.apiKey,
      'llm_base_url': config.baseUrl,
      'llm_model': config.model,
      'llm_temperature': config.temperature.toString(),
      'llm_max_tokens': config.maxTokens.toString(),
      'llm_timeout': config.timeoutSeconds.toString(),
    });
    
    _currentConfig = config;
  }
  
  @override
  Future<LlmResponse> chat(LlmRequest request) async {
    final config = await getConfig();
    
    if (config.apiKey.isEmpty) {
      throw LlmException('请先配置API Key');
    }
    
    try {
      final response = await _dio.post(
        '${config.baseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${config.apiKey}',
            'Content-Type': 'application/json',
          },
          sendTimeout: Duration(seconds: config.timeoutSeconds),
          receiveTimeout: Duration(seconds: config.timeoutSeconds),
        ),
        data: {
          'model': request.model ?? config.model,
          'messages': request.messages.map((m) => {
            'role': m.role,
            'content': m.content,
          }).toList(),
          'temperature': request.temperature ?? config.temperature,
          'max_tokens': request.maxTokens ?? config.maxTokens,
        },
      );
      
      final data = response.data;
      final usage = data['usage'] ?? {};
      
      return LlmResponse(
        content: data['choices'][0]['message']['content'],
        model: data['model'],
        promptTokens: usage['prompt_tokens'] ?? 0,
        completionTokens: usage['completion_tokens'] ?? 0,
        totalTokens: usage['total_tokens'] ?? 0,
      );
    } on DioException catch (e) {
      throw LlmException(_parseDioError(e));
    }
  }
  
  @override
  Future<TransactionParseResult> parseTransaction(String input) async {
    final prompt = PromptTemplates.parseTransaction(input);
    
    final response = await chat(LlmRequest(
      messages: [
        ChatMessage(role: 'system', content: prompt.system),
        ChatMessage(role: 'user', content: prompt.user),
      ],
      temperature: 0.0, // 记账解析用低温度，确保稳定性
    ));
    
    return _parseTransactionResponse(response.content);
  }
  
  @override
  Future<String> chatWithAi(String message, List<ChatMessage> history) async {
    final response = await chat(LlmRequest(
      messages: [
        ChatMessage(role: 'system', content: PromptTemplates.aiAssistant),
        ...history,
        ChatMessage(role: 'user', content: message),
      ],
      temperature: 0.7, // 对话用稍高温度，更自然
    ));
    
    return response.content;
  }
  
  @override
  Future<bool> testConnection() async {
    try {
      final response = await chat(LlmRequest(
        messages: [
          ChatMessage(role: 'user', content: 'Hello'),
        ],
        maxTokens: 10,
      ));
      return response.content.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
  
  // 解析交易响应
  TransactionParseResult _parseTransactionResponse(String content) {
    try {
      // 尝试提取JSON
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      if (jsonMatch == null) {
        throw LlmException('无法解析AI响应');
      }
      
      final json = jsonDecode(jsonMatch.group(0)!);
      
      return TransactionParseResult(
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String,
        subcategory: json['subcategory'] as String?,
        description: json['description'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        date: json['date'] as String?,
        note: json['note'] as String?,
      );
    } catch (e) {
      throw LlmException('解析AI响应失败: $e');
    }
  }
  
  // 解析Dio错误
  String _parseDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return '请求超时，请检查网络连接';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) return 'API Key无效';
        if (statusCode == 429) return '请求过于频繁，请稍后再试';
        return '请求失败: $statusCode';
      case DioExceptionType.connectionError:
        return '网络连接失败，请检查网络';
      default:
        return '请求失败: ${e.message}';
    }
  }
}

// LLM异常
class LlmException implements Exception {
  final String message;
  const LlmException(this.message);
  
  @override
  String toString() => 'LlmException: $message';
}
```

---

## 4. Provider配置

```dart
// lib/config/di/ai_providers.dart

// Dio客户端
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

// LLM Repository
final llmRepositoryProvider = Provider<LlmRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final settingsRepo = ref.watch(userSettingsRepositoryProvider);
  return LlmRepositoryImpl(dio, settingsRepo);
});

// LLM配置
final llmConfigProvider = FutureProvider<LlmConfig>((ref) async {
  final repo = ref.watch(llmRepositoryProvider);
  return await repo.getConfig();
});

// 记账解析用例
final parseTransactionUseCaseProvider = Provider<ParseTransactionUseCase>((ref) {
  final repo = ref.watch(llmRepositoryProvider);
  return ParseTransactionUseCase(repo);
});

// AI对话用例
final chatWithAiUseCaseProvider = Provider<ChatWithAiUseCase>((ref) {
  final repo = ref.watch(llmRepositoryProvider);
  return ChatWithAiUseCase(repo);
});
```

---

## 5. 错误处理策略

### 5.1 错误类型

| 错误类型 | 处理方式 |
|----------|----------|
| API Key未配置 | 提示用户配置 |
| API Key无效 | 提示用户检查 |
| 网络连接失败 | 使用规则引擎兜底 |
| 请求超时 | 重试1次，失败后用规则引擎 |
| 请求频率限制 | 提示用户稍后再试 |
| 响应解析失败 | 使用规则引擎兜底 |

### 5.2 降级策略

```
用户输入
    │
    ▼
┌─────────────────┐
│  LLM API调用    │
└────────┬────────┘
         │
    成功？├─ 是 → 返回结果
         │
    否   ▼
┌─────────────────┐
│  规则引擎兜底   │
│  关键词匹配     │
└────────┬────────┘
         │
         ▼
    返回结果（置信度较低）
```

---

## 6. 性能优化

### 6.1 缓存策略

```dart
// 相同输入缓存结果
class LlmCache {
  final Map<String, CacheEntry> _cache = {};
  final Duration _ttl = const Duration(hours: 24);
  
  String? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.createdAt) > _ttl) {
      _cache.remove(key);
      return null;
    }
    return entry.value;
  }
  
  void set(String key, String value) {
    _cache[key] = CacheEntry(value, DateTime.now());
  }
}

class CacheEntry {
  final String value;
  final DateTime createdAt;
  const CacheEntry(this.value, this.createdAt);
}
```

### 6.2 请求优化

| 策略 | 说明 |
|------|------|
| 低温度 | 记账解析用temperature=0，确保稳定性 |
| 限制token | 设置合理的max_tokens，减少响应时间 |
| 请求缓存 | 相同输入直接返回缓存结果 |
| 超时控制 | 设置合理的超时时间（30秒） |
| 重试机制 | 网络错误自动重试1次 |

---

## 7. 文件结构

```
lib/features/ai/
├── data/
│   ├── models/
│   │   ├── llm_config.dart
│   │   ├── llm_provider.dart
│   │   ├── llm_request.dart
│   │   └── llm_response.dart
│   └── repositories/
│       └── llm_repository_impl.dart
├── domain/
│   ├── repositories/
│   │   └── llm_repository.dart
│   └── usecases/
│       ├── parse_transaction_use_case.dart
│       └── chat_with_ai_use_case.dart
└── presentation/
    ├── providers/
    │   └── ai_providers.dart
    └── pages/
        └── ai_assistant_page.dart

lib/core/ai/
├── prompt_templates.dart
├── rule_engine.dart
└── llm_cache.dart
```
