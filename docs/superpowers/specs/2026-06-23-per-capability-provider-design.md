# 独立供应商 + URL 自动探测设计

> **日期**: 2026-06-23
> **状态**: 设计完成，待实现
> **范围**: AI 模型配置架构改造 + Whisper API URL 修复

## 背景与问题

### 问题 1：供应商绑定

当前架构中所有能力（文本/视觉/音频）共享一个"活跃供应商"。当用户为其中一个能力切换供应商时，其他能力的模型配置丢失——因为所有配置都存在同一个 `LlmProvider.models` map 里。

### 问题 2：Whisper 404

`VoiceRecognitionService` 构建 URL 为 `{baseUrl}/audio/transcriptions`。当用户配置的 `baseUrl` 为 `https://api.example.com`（不含 `/v1`）时，实际请求路径为 `https://api.example.com/audio/transcriptions` → 404。而聊天接口 `{baseUrl}/chat/completions` 不报错是因为用户恰好在 baseUrl 中包含了 `/v1`。

## 设计目标

- 每个能力（文本/视觉/音频）可独立选择供应商（不同的 baseUrl + apiKey）
- 切换某能力的供应商不影响其他能力的配置
- Whisper API URL 自动探测，解决 404
- 旧数据自动兼容，无需迁移

## 设计 §1：数据模型改造

### ModelConfig 增加 providerId

```dart
class ModelConfig {
  final String modelName;
  final String? providerId;  // 新增：该能力使用的供应商 ID

  const ModelConfig({required this.modelName, this.providerId});

  // JSON 序列化兼容旧数据（providerId 可空）
  factory ModelConfig.fromJson(Map<String, dynamic> json) {
    return ModelConfig(
      modelName: json['modelName'] as String,
      providerId: json['providerId'] as String?,
    );
  }
}
```

### 按能力解析供应商

新增全局辅助方法：

```dart
/// 根据能力解析对应的供应商
///
/// 优先使用 ModelConfig.providerId 指定的供应商。
/// 降级使用活跃供应商（兼容旧数据）。
Future<LlmProvider?> resolveProviderForCapability(
  ModelCapability capability,
) async {
  final providers = await LlmConfigManager.loadProviders();

  // 1. 查找该能力配置了的供应商
  for (final p in providers) {
    final model = p.models[capability.name];
    if (model != null &&
        model.providerId != null &&
        model.modelName.isNotEmpty) {
      final target = providers.where((x) => x.id == model.providerId).firstOrNull;
      if (target != null && target.isComplete) return target;
    }
  }

  // 2. 降级：用活跃供应商（兼容旧数据）
  return await LlmConfigManager.getActiveProvider();
}

/// 获取某能力对应的供应商和模型名
Future<(LlmProvider?, String?)> resolveCapabilityConfig(
  ModelCapability capability,
) async {
  final providers = await LlmConfigManager.loadProviders();

  // 1. 优先：从配置了该能力的供应商中取
  for (final p in providers) {
    final model = p.models[capability.name];
    if (model != null &&
        model.providerId != null &&
        model.modelName.isNotEmpty) {
      final target = providers.where((x) => x.id == model.providerId).firstOrNull;
      if (target != null && target.isComplete) {
        return (target, model.modelName);
      }
    }
  }

  // 2. 降级：用活跃供应商
  final active = await LlmConfigManager.getActiveProvider();
  final modelName = active?.getModelForCapability(capability);
  return (active, modelName);
}
```

### 旧数据兼容

- `ModelConfig.providerId` 为可空字段，旧数据没有此字段时自动降级为活跃供应商
- `LlmConfigManager.getActiveProvider()` 保留，作为降级兜底
- `activeProviderId` 保留，用户仍可在供应商管理页设置"默认供应商"

## 设计 §2：服务层改造

### 2.1 调用点改为按能力获取供应商

| 调用点 | 现在 | 改后 |
|-------|------|------|
| `VoiceTranscriptionOrchestrator.transcribe()` | 接收 `provider` 参数 | 内部调 `resolveProviderForCapability(ModelCapability.audio)` |
| `TransactionPipeline.processVoiceResult()` | 不涉及 provider | 不变 |
| `TransactionPipeline.processText()` | 不涉及 provider | 需要 provider 用于 LLM 调用 |
| `ImageRecognitionService.recognize()` | 接收 `provider` 参数 | 内部调 `resolveProviderForCapability(ModelCapability.vision)` |
| `LlmRepositoryImpl.parseTransaction()` | 使用活跃 provider | 改为接收 `provider` 参数或内部解析 |
| `AiChatPage._processInput()` | `getActiveProvider()` | `resolveProviderForCapability(source)` |
| `HomePage._handleVoiceRecorded()` | `getActiveProvider()` | `resolveProviderForCapability(ModelCapability.audio)` |
| `MainShell._handleVoiceResult()` | `getActiveProvider()` | `resolveProviderForCapability(ModelCapability.audio)` |

### 2.2 Orchestrator 改造

```dart
class VoiceTranscriptionOrchestrator {
  // ... 不变 ...

  Future<DualTranscriptionResult> transcribe({
    required String audioPath,
    String? platformText,
  }) async {
    // 不再接收 provider 参数，内部解析
    final provider = await resolveProviderForCapability(ModelCapability.audio);

    if (provider == null || !provider.isComplete) {
      // Whisper 不可用，只有 Platform
      if (platformText != null && platformText.trim().isNotEmpty) {
        final savedPath = await _saveAudio(audioPath);
        return DualTranscriptionResult(
          platformText: platformText,
          audioPath: savedPath,
        );
      }
      throw const LlmException(
        'No voice recognition engine available',
        errorCode: 'voiceErrorNoEngineAvailable',
      );
    }

    // ... 后续逻辑不变 ...
  }
}
```

### 2.3 URL 自动探测

在 `VoiceRecognitionService.transcribe()` 中：

```dart
Future<String> transcribe(LlmProvider provider, String audioFilePath, {
  String language = 'zh',
}) async {
  final model = provider.getModelForCapability(ModelCapability.audio);
  if (model == null || model.isEmpty) {
    throw const LlmException('未配置语音识别模型', errorCode: 'voiceErrorNoModelConfigured');
  }

  final file = File(audioFilePath);
  if (!file.existsSync()) {
    throw const LlmException('音频文件不存在', errorCode: 'voiceErrorAudioNotFound');
  }

  final formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(audioFilePath, filename: 'recording.m4a'),
    'model': model,
    'language': language,
  });

  // 尝试两个 URL 路径
  final urls = _buildCandidateUrls(provider.baseUrl);

  DioException? lastError;
  for (final url in urls) {
    try {
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer ${provider.apiKey}'},
          sendTimeout: Duration(seconds: provider.timeoutSeconds),
          receiveTimeout: Duration(seconds: provider.timeoutSeconds),
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('text')) {
        return data['text'] as String;
      }
      if (data is String) return data;

      throw const LlmException('语音识别返回格式异常',
          errorCode: 'voiceErrorInvalidResponseFormat');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        lastError = e;
        continue;  // 404 → 尝试下一个 URL
      }
      if (e.response?.statusCode == 401) {
        throw const LlmException('API Key 无效',
            errorCode: 'llmErrorInvalidApiKey');
      }
      throw LlmException('语音识别失败: ${e.message}',
          errorCode: 'voiceErrorTranscriptionFailed');
    }
  }

  // 所有 URL 都 404
  throw LlmException(
    'Whisper API 端点未找到，请检查供应商 Base URL 配置',
    errorCode: 'voiceErrorEndpointNotFound',
  );
}

/// 构建候选 URL 列表
List<String> _buildCandidateUrls(String baseUrl) {
  // 如果 baseUrl 已经包含 /v1，只试一个
  if (baseUrl.endsWith('/v1')) {
    return ['$baseUrl/audio/transcriptions'];
  }
  // 否则先试原始路径，再试加 /v1
  return [
    '$baseUrl/audio/transcriptions',
    '$baseUrl/v1/audio/transcriptions',
  ];
}
```

## 设计 §3：UI 改造

### 3.1 模型管理页

每个能力显示 "供应商名 · 模型名"：

```
┌─ 模型管理 ──────────────────────────────┐
│                                         │
│  📝 文本模型                             │
│     DeepSeek · deepseek-chat        ▸   │
│                                         │
│  🖼️ 视觉模型                            │
│     OpenAI · gpt-4o                 ▸   │
│                                         │
│  🎤 音频模型                             │
│     未配置                           ▸   │
│                                         │
└─────────────────────────────────────────┘
```

从 `resolveCapabilityConfig(capability)` 获取供应商名和模型名。

### 3.2 能力配置页

两步选择：先选供应商，再选模型。

- 供应商列表显示所有已配置（有 apiKey + baseUrl）的供应商
- 选中供应商后，从该供应商的 API 获取模型列表（带能力过滤关键词）
- 选中模型后，保存到该供应商的 `models[capability.name]`，包含 `providerId`

### 3.3 _selectModel 逻辑

```dart
Future<void> _selectModel(LlmProvider selectedProvider, String? model) async {
  if (model == null) return;

  final providers = await LlmConfigManager.loadProviders();
  final newModels = Map<String, ModelConfig>.from(selectedProvider.models);
  newModels[widget.capability.name] = ModelConfig(
    modelName: model,
    providerId: selectedProvider.id,
  );
  await LlmConfigManager.updateProvider(
    selectedProvider.copyWith(models: newModels),
  );

  // 清除旧供应商中该能力的配置
  for (final p in providers) {
    if (p.id == selectedProvider.id) continue;
    if (p.models.containsKey(widget.capability.name)) {
      final cleaned = Map<String, ModelConfig>.from(p.models);
      cleaned.remove(widget.capability.name);
      await LlmConfigManager.updateProvider(p.copyWith(models: cleaned));
    }
  }

  // 刷新 UI
}
```

## 新增 L10n key

| Key | zh | en |
|-----|----|----|
| `voiceErrorEndpointNotFound` | Whisper API 端点未找到，请检查供应商 Base URL 配置 | Whisper API endpoint not found. Please check supplier Base URL |

## 错误处理

| 场景 | 处理 |
|------|------|
| 能力未配置任何供应商+模型 | 该能力不可用，UI 显示"未配置" |
| 配置的供应商被删除 | 降级到活跃供应商 |
| Whisper URL 404 | 自动尝试 /v1 前缀，都失败则提示检查 URL |
| Whisper API Key 无效 | 现有 401 处理不变 |
