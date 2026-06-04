# WoAccount LLM用户配置方案

> **版本**: v1.0 | **创建日期**: 2026-06-04

---

## 1. 功能概述

用户可以在设置页面中配置LLM服务，包括：
- 选择提供商
- 配置API Key
- 自定义请求地址
- 选择模型
- 调整参数

---

## 2. 配置项说明

| 配置项 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| 提供商 | 选择 | 是 | 从预设列表选择或自定义 |
| API Key | 文本 | 是 | 用户的API密钥 |
| 请求地址 | 文本 | 是 | API端点地址 |
| 模型名称 | 文本/选择 | 是 | 使用的模型 |
| 温度参数 | 滑块 | 否 | 0.0-1.0，默认0.0 |
| 最大Token | 数字 | 否 | 默认1000 |
| 超时时间 | 数字 | 否 | 默认30秒 |

---

## 3. 预设提供商

### 3.1 提供商列表

| ID | 名称 | 默认地址 | 默认模型 | 可用模型 |
|----|------|----------|----------|----------|
| qwen | 通义千问 | dashscope.aliyuncs.com/api/v1 | qwen-turbo | qwen-turbo, qwen-plus, qwen-max |
| deepseek | DeepSeek | api.deepseek.com/v1 | deepseek-chat | deepseek-chat, deepseek-coder |
| zhipu | 智谱AI | open.bigmodel.cn/api/paas/v4 | glm-4-flash | glm-4-flash, glm-4, glm-4v |
| moonshot | 月之暗面 | api.moonshot.cn/v1 | moonshot-v1-8k | moonshot-v1-8k, moonshot-v1-32k, moonshot-v1-128k |
| xunfei | 讯飞星火 | spark-api-open.xf-yun.com/v1 | generalv3.5 | generalv3.5, generalv3, pro-128k |
| custom | 自定义 | 用户填写 | 用户填写 | 用户填写 |

### 3.2 提供商详情

#### 通义千问（阿里云）

```
注册地址: https://dashscope.console.aliyun.com/
API文档: https://help.aliyun.com/zh/dashscope/
价格: qwen-turbo ¥0.008/千tokens
特点: 稳定，国内访问快
```

#### DeepSeek

```
注册地址: https://platform.deepseek.com/
API文档: https://platform.deepseek.com/api-docs
价格: deepseek-chat ¥1/百万tokens
特点: 性价比极高，推理能力强
```

#### 智谱AI

```
注册地址: https://open.bigmodel.cn/
API文档: https://open.bigmodel.cn/dev/api
价格: glm-4-flash 免费
特点: 有免费额度，适合测试
```

#### 月之暗面

```
注册地址: https://platform.moonshot.cn/
API文档: https://platform.moonshot.cn/docs
价格: moonshot-v1-8k ¥12/百万tokens
特点: 长文本能力强
```

#### 讯飞星火

```
注册地址: https://xinghuo.xfyun.cn/
API文档: https://www.xfyun.cn/doc/spark/Web.html
价格: 有免费额度
特点: 语音能力强
```

---

## 4. 配置页面设计

### 4.1 页面结构

```
┌─────────────────────────────────────┐
│  ← LLM配置                         │
├─────────────────────────────────────┤
│                                     │
│  提供商                             │
│  ┌─────────────────────────────────┐│
│  │ 通义千问                    ▾  ││
│  └─────────────────────────────────┘│
│                                     │
│  API Key                            │
│  ┌─────────────────────────────────┐│
│  │ sk-xxxx                    👁  ││
│  └─────────────────────────────────┘│
│                                     │
│  请求地址                           │
│  ┌─────────────────────────────────┐│
│  │ https://dashscope.aliyuncs.com ││
│  └─────────────────────────────────┘│
│                                     │
│  模型                               │
│  ┌─────────────────────────────────┐│
│  │ qwen-turbo                 ▾  ││
│  └─────────────────────────────────┘│
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  高级设置                           │
│                                     │
│  温度参数        0.0                │
│  ├────────────●────────────────┤   │
│                                     │
│  最大Token      1000                │
│  ┌─────────────────────────────────┐│
│  │ 1000                           ││
│  └─────────────────────────────────┘│
│                                     │
│  超时时间(秒)   30                  │
│  ┌─────────────────────────────────┐│
│  │ 30                             ││
│  └─────────────────────────────────┘│
│                                     │
├─────────────────────────────────────┤
│  [测试连接]                         │
│  [保存配置]                         │
└─────────────────────────────────────┘
```

### 4.2 交互逻辑

| 操作 | 响应 |
|------|------|
| 选择提供商 | 自动填充默认地址和模型 |
| 点击"测试连接" | 发送测试请求，显示结果 |
| 点击"保存配置" | 保存到数据库 |
| API Key输入 | 密码形式显示，可切换明文 |

---

## 5. 数据存储

### 5.1 存储位置

配置存储在本地SQLite数据库的`user_settings`表中。

### 5.2 配置键名

| 键名 | 类型 | 说明 |
|------|------|------|
| llm_provider | String | 提供商ID |
| llm_api_key | String | API Key |
| llm_base_url | String | 请求地址 |
| llm_model | String | 模型名称 |
| llm_temperature | String | 温度参数 |
| llm_max_tokens | String | 最大Token |
| llm_timeout | String | 超时时间 |

### 5.3 默认配置

```dart
final defaultLlmSettings = {
  'llm_provider': 'qwen',
  'llm_api_key': '',
  'llm_base_url': 'https://dashscope.aliyuncs.com/api/v1',
  'llm_model': 'qwen-turbo',
  'llm_temperature': '0.0',
  'llm_max_tokens': '1000',
  'llm_timeout': '30',
};
```

---

## 6. 安全考虑

### 6.1 API Key存储

| 方案 | 安全性 | 说明 |
|------|--------|------|
| 数据库明文 | 低 | 简单，但不安全 |
| flutter_secure_storage | 高 | 使用系统密钥链 |
| 加密存储 | 中 | 加密后存数据库 |

**推荐：** 使用`flutter_secure_storage`，调用系统原生安全存储。

### 6.2 实现示例

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureLlmStorage {
  final _storage = const FlutterSecureStorage();
  
  Future<void> saveApiKey(String apiKey) async {
    await _storage.write(key: 'llm_api_key', value: apiKey);
  }
  
  Future<String?> getApiKey() async {
    return await _storage.read(key: 'llm_api_key');
  }
  
  Future<void> deleteApiKey() async {
    await _storage.delete(key: 'llm_api_key');
  }
}
```

---

## 7. 配置验证

### 7.1 验证规则

| 配置项 | 验证规则 |
|--------|----------|
| API Key | 非空，长度>10 |
| 请求地址 | 非空，有效URL格式 |
| 模型名称 | 非空 |
| 温度参数 | 0.0-1.0之间 |
| 最大Token | 1-8000之间 |
| 超时时间 | 5-120之间 |

### 7.2 验证示例

```dart
class LlmConfigValidator {
  static String? validateApiKey(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入API Key';
    }
    if (value.length < 10) {
      return 'API Key格式不正确';
    }
    return null;
  }
  
  static String? validateBaseUrl(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入请求地址';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme) {
      return '请输入有效的URL';
    }
    return null;
  }
  
  static String? validateTemperature(double? value) {
    if (value == null) return null;
    if (value < 0 || value > 1) {
      return '温度参数必须在0-1之间';
    }
    return null;
  }
}
```

---

## 8. 测试连接

### 8.1 测试流程

```
用户点击"测试连接"
       │
       ▼
┌─────────────────┐
│  发送测试请求   │
│  "Hello"        │
└────────┬────────┘
         │
    成功？├─ 是 → 显示"连接成功"
         │
    否   ▼
       显示错误信息
       "API Key无效" / "网络连接失败"
```

### 8.2 实现示例

```dart
Future<bool> testConnection() async {
  try {
    final response = await chat(LlmRequest(
      messages: [
        ChatMessage(role: 'user', content: 'Hello'),
      ],
      maxTokens: 10,
    ));
    return response.content.isNotEmpty;
  } on LlmException catch (e) {
    // 显示错误信息
    return false;
  } catch (e) {
    return false;
  }
}
```

---

## 9. Provider实现

```dart
// lib/features/settings/presentation/providers/llm_config_provider.dart

// LLM配置状态
class LlmConfigState {
  final LlmConfig? config;
  final bool isLoading;
  final String? error;
  final bool isTestSuccess;
  
  const LlmConfigState({
    this.config,
    this.isLoading = false,
    this.error,
    this.isTestSuccess = false,
  });
  
  LlmConfigState copyWith({
    LlmConfig? config,
    bool? isLoading,
    String? error,
    bool? isTestSuccess,
  }) {
    return LlmConfigState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isTestSuccess: isTestSuccess ?? this.isTestSuccess,
    );
  }
}

// LLM配置Notifier
class LlmConfigNotifier extends StateNotifier<LlmConfigState> {
  final LlmRepository _repository;
  
  LlmConfigNotifier(this._repository) : super(const LlmConfigState()) {
    loadConfig();
  }
  
  Future<void> loadConfig() async {
    state = state.copyWith(isLoading: true);
    try {
      final config = await _repository.getConfig();
      state = state.copyWith(config: config, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  
  Future<void> updateConfig(LlmConfig config) async {
    state = state.copyWith(isLoading: true);
    try {
      await _repository.updateConfig(config);
      state = state.copyWith(config: config, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
  
  Future<void> testConnection() async {
    state = state.copyWith(isLoading: true, isTestSuccess: false);
    try {
      final success = await _repository.testConnection();
      state = state.copyWith(
        isLoading: false,
        isTestSuccess: success,
        error: success ? null : '连接失败',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Provider定义
final llmConfigProvider = StateNotifierProvider<
    LlmConfigNotifier, LlmConfigState>((ref) {
  final repository = ref.watch(llmRepositoryProvider);
  return LlmConfigNotifier(repository);
});
```

---

## 10. 配置页面代码结构

```
lib/features/settings/
├── data/
│   └── repositories/
│       └── user_settings_repository_impl.dart
├── domain/
│   └── repositories/
│       └── user_settings_repository.dart
└── presentation/
    ├── providers/
    │   └── llm_config_provider.dart
    ├── pages/
    │   └── llm_config_page.dart
    └── widgets/
        ├── provider_selector.dart
        ├── api_key_input.dart
        ├── model_selector.dart
        └── connection_test_button.dart
```
