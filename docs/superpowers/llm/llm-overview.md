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

## 6. 离线策略

### 6.1 整体方案

WoAccount采用**本地OCR + 规则引擎**的离线方案，确保无网络时仍可使用核心功能。

```
用户输入
    │
    ▼
┌─────────────────┐
│  检查网络状态   │
└────────┬────────┘
         │
    有网络？├─ 是 → 调用LLM API
         │
    否   ▼
┌─────────────────┐
│  检查缓存       │
└────────┬────────┘
         │
    命中？├─ 是 → 返回缓存结果
         │
    否   ▼
┌─────────────────┐
│  规则引擎       │
│  关键词匹配     │
└────────┬────────┘
         │
    命中？├─ 是 → 返回结果（置信度较低）
         │
    否   ▼
┌─────────────────┐
│  延迟同步模式   │
│  保存原始输入   │
│  提示用户       │
└─────────────────┘
```

### 6.2 离线能力矩阵

| 功能 | 在线 | 离线 | 降级方案 |
|------|------|------|----------|
| 自然语言记账 | LLM解析 | 规则引擎 | 置信度降低 |
| 语音记账 | 语音识别+LLM | 不可用 | 提示需要网络 |
| 图片识别 | 本地OCR+LLM | 本地OCR+规则 | 准确率降低 |
| AI对话 | LLM对话 | 不可用 | 提示需要网络 |
| 消费洞察 | LLM分析 | 统计计算 | 简单统计 |

### 6.3 网络状态检测

```dart
// lib/core/network/network_info.dart

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkInfo {
  final Connectivity _connectivity;
  
  NetworkInfo(this._connectivity);
  
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
  
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map(
      (result) => result != ConnectivityResult.none,
    );
  }
}
```

### 6.4 规则引擎

```dart
// lib/core/ai/rule_engine.dart

class RuleEngine {
  // 关键词→分类映射表
  static final Map<String, CategoryRule> _rules = {
    // 餐饮
    '饭': CategoryRule('餐饮', '餐食', 0.8),
    '面': CategoryRule('餐饮', '面食', 0.8),
    '火锅': CategoryRule('餐饮', '火锅', 0.9),
    '烧烤': CategoryRule('餐饮', '烧烤', 0.9),
    '奶茶': CategoryRule('餐饮', '饮料', 0.9),
    '咖啡': CategoryRule('餐饮', '饮料', 0.9),
    '外卖': CategoryRule('餐饮', '外卖', 0.9),
    '早餐': CategoryRule('餐饮', '早餐', 0.9),
    '午餐': CategoryRule('餐饮', '午餐', 0.9),
    '晚餐': CategoryRule('餐饮', '晚餐', 0.9),
    
    // 交通
    '打车': CategoryRule('交通', '打车', 0.9),
    '滴滴': CategoryRule('交通', '打车', 0.9),
    '地铁': CategoryRule('交通', '公交地铁', 0.9),
    '公交': CategoryRule('交通', '公交地铁', 0.9),
    '加油': CategoryRule('交通', '加油', 0.9),
    '停车': CategoryRule('交通', '停车', 0.9),
    
    // 购物
    '超市': CategoryRule('购物', '日用品', 0.8),
    '淘宝': CategoryRule('购物', '网购', 0.9),
    '京东': CategoryRule('购物', '网购', 0.9),
    '衣服': CategoryRule('购物', '衣物', 0.9),
    
    // 住房
    '房租': CategoryRule('住房', '房租', 0.95),
    '水电': CategoryRule('住房', '水电燃气', 0.9),
    '物业': CategoryRule('住房', '物业', 0.9),
    
    // 娱乐
    '电影': CategoryRule('娱乐', '电影', 0.9),
    '游戏': CategoryRule('娱乐', '游戏', 0.9),
    '旅游': CategoryRule('娱乐', '旅游', 0.9),
    
    // 医疗
    '医院': CategoryRule('医疗', '看病', 0.9),
    '药': CategoryRule('医疗', '药品', 0.8),
    
    // 社交
    '红包': CategoryRule('社交', '红包', 0.9),
    '礼物': CategoryRule('社交', '礼物', 0.9),
    '份子钱': CategoryRule('社交', '份子钱', 0.9),
    
    // 收入
    '工资': CategoryRule('工资', null, 0.95, type: 'income'),
    '发工资': CategoryRule('工资', null, 0.95, type: 'income'),
    '奖金': CategoryRule('奖金', null, 0.9, type: 'income'),
    '退款': CategoryRule('退款', null, 0.9, type: 'income'),
  };
  
  /// 规则引擎解析
  static TransactionParseResult? parse(String input) {
    // 1. 提取金额
    final amount = _extractAmount(input);
    if (amount == null) return null;
    
    // 2. 匹配分类
    CategoryRule? matchedRule;
    for (final entry in _rules.entries) {
      if (input.contains(entry.key)) {
        if (matchedRule == null || entry.value.confidence > matchedRule.confidence) {
          matchedRule = entry.value;
        }
      }
    }
    
    if (matchedRule == null) return null;
    
    // 3. 解析时间
    DateTime? date;
    for (final entry in _timeWords.entries) {
      if (input.contains(entry.key)) {
        date = entry.value();
        break;
      }
    }
    
    // 4. 返回结果
    return TransactionParseResult(
      amount: amount,
      category: matchedRule.category,
      subcategory: matchedRule.subcategory,
      description: _cleanDescription(input),
      confidence: matchedRule.confidence,
      date: date?.toIso8601String().split('T')[0],
      type: matchedRule.type ?? 'expense',
    );
  }
  
  /// 添加用户自定义规则
  static void addRule(String keyword, CategoryRule rule) {
    _rules[keyword] = rule;
    // 可以持久化到数据库
  }
}

class CategoryRule {
  final String category;
  final String? subcategory;
  final double confidence;
  final String? type;
  
  const CategoryRule(this.category, this.subcategory, this.confidence, {this.type});
}
```

---

## 7. 图片识别方案

### 7.1 方案选择

采用**本地OCR + LLM**方案：

- 本地OCR：使用Google ML Kit（支持中文）
- LLM：有网络时调用云端LLM解析，无网络时用规则引擎

### 7.2 识别流程

```
拍照/选择图片
       │
       ▼
┌─────────────────┐
│  图片预处理     │
│  - 裁剪         │
│  - 旋转校正     │
│  - 增强对比度   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  本地OCR        │
│  (ML Kit)       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  检查网络状态   │
└────────┬────────┘
         │
    有网络？├─ 是 → LLM结构化解析
         │
    否   ▼
┌─────────────────┐
│  规则引擎解析   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  确认卡片       │
│  - 展示结果     │
│  - 用户修改     │
└─────────────────┘
```

### 7.3 本地OCR实现

```dart
// lib/features/scan/data/services/local_ocr_service.dart

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class LocalOcrService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.chinese);
  
  /// 识别图片中的文字
  Future<String> recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }
  
  /// 释放资源
  void dispose() {
    _textRecognizer.close();
  }
}
```

### 7.4 图片识别服务

```dart
// lib/features/scan/data/services/receipt_recognition_service.dart

class ReceiptRecognitionService {
  final LocalOcrService _ocrService;
  final LlmRepository _llmRepository;
  final NetworkInfo _networkInfo;
  
  ReceiptRecognitionService(
    this._ocrService,
    this._llmRepository,
    this._networkInfo,
  );
  
  /// 识别小票
  Future<TransactionParseResult> recognizeReceipt(String imagePath) async {
    // 1. 本地OCR识别文字
    final ocrText = await _ocrService.recognizeText(imagePath);
    
    if (ocrText.isEmpty) {
      throw RecognitionException('无法识别图片中的文字');
    }
    
    // 2. 检查网络
    final isConnected = await _networkInfo.isConnected;
    
    if (isConnected) {
      // 3a. 有网络：调用LLM解析
      return await _llmRepository.parseTransaction(ocrText);
    } else {
      // 3b. 无网络：使用规则引擎
      final result = RuleEngine.parse(ocrText);
      if (result != null) {
        return result;
      }
      throw RecognitionException('无网络且无法识别，请稍后重试');
    }
  }
  
  /// 识别发票
  Future<TransactionParseResult> recognizeInvoice(String imagePath) async {
    // 类似逻辑，但使用不同的Prompt
    final ocrText = await _ocrService.recognizeText(imagePath);
    
    if (ocrText.isEmpty) {
      throw RecognitionException('无法识别图片中的文字');
    }
    
    final isConnected = await _networkInfo.isConnected;
    
    if (isConnected) {
      return await _llmRepository.parseInvoice(ocrText);
    } else {
      final result = RuleEngine.parse(ocrText);
      if (result != null) {
        return result;
      }
      throw RecognitionException('无网络且无法识别，请稍后重试');
    }
  }
}

class RecognitionException implements Exception {
  final String message;
  const RecognitionException(this.message);
}
```

### 7.5 小票识别Prompt

```
你是一个小票/发票识别专家。请识别以下OCR文字中的消费信息。

## OCR文字内容

{ocr_text}

## 识别内容

1. 商家名称
2. 消费时间
3. 消费项目
4. 总金额
5. 支付方式

## 输出格式

{
  "type": "expense",
  "amount": 总金额,
  "category": "推断分类",
  "subcategory": "子分类",
  "description": "精简描述",
  "merchant": "商家名称",
  "datetime": "YYYY-MM-DD HH:MM",
  "payment_method": "支付方式",
  "confidence": 0.0-1.0
}

## 分类推断

根据商家名称推断分类：
- 餐厅/饭店/外卖/奶茶/咖啡 → 餐饮
- 超市/便利店/商场 → 购物
- 加油站/停车场 → 交通
- 药店/医院 → 医疗
- 电影院/游戏厅 → 娱乐
```

### 7.6 Provider配置

```dart
// lib/config/di/scan_providers.dart

// 本地OCR服务
final localOcrServiceProvider = Provider<LocalOcrService>((ref) {
  return LocalOcrService();
});

// 网络信息
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(Connectivity());
});

// 小票识别服务
final receiptRecognitionServiceProvider = Provider<ReceiptRecognitionService>((ref) {
  return ReceiptRecognitionService(
    ref.watch(localOcrServiceProvider),
    ref.watch(llmRepositoryProvider),
    ref.watch(networkInfoProvider),
  );
});
```

### 7.7 依赖配置

```yaml
# pubspec.yaml

dependencies:
  # 本地OCR
  google_mlkit_text_recognition: ^0.14.0
  
  # 网络状态检测
  connectivity_plus: ^6.0.0
  
  # 图片处理
  image_picker: ^1.0.0
  image: ^4.0.0
```

---

## 8. 性能优化

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

## 9. 文件结构

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

lib/features/scan/
├── data/
│   └── services/
│       ├── local_ocr_service.dart
│       └── receipt_recognition_service.dart
└── presentation/
    ├── providers/
    │   └── scan_providers.dart
    └── pages/
        └── scan_page.dart

lib/core/
├── ai/
│   ├── prompt_templates.dart
│   ├── rule_engine.dart
│   └── llm_cache.dart
└── network/
    └── network_info.dart
```
