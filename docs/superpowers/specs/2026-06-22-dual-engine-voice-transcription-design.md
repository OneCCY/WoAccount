# 双引擎语音记账架构设计

> **日期**: 2026-06-22
> **状态**: 设计完成，待实现
> **范围**: 语音输入从录音到保存交易的全链路重构

## 背景与问题

当前语音记账架构存在三个核心问题：

1. **管线层不感知语音模式**：`TransactionPipeline` 只持有 `VoiceRecognitionService`（Whisper 云端），`processVoice()` 和 `transcribeOnly()` 只能走 Whisper API，无法利用设备原生 STT。
2. **三个入口点各自为政**：首页 `AiInputBar` 和浮动按钮 `MainShell` 始终走录音→Whisper 路径，聊天页 `ChatInputBar` 是唯一正确实现平台原生 STT 的入口。行为不一致，用户设置形同虚设。
3. **枚举重复、设置无效**：`VoiceInputMode` 和 `SttMode` 两个枚举做同一件事；`VoiceModeSetting` 只被聊天页读取。

## 设计目标

- **双引擎并行识别**：录音时同时启动设备原生 STT 和 Whisper API，两路结果合并获得更高精度。
- **LLM 交叉校验**：双引擎文本有差异时，两段文本同时送 LLM，一次调用完成校验合并 + 交易解析。
- **自动降级**：只有一个引擎可用时自动降级为单引擎；无引擎可用时提示用户。
- **入口点统一**：三个入口点（首页、浮动按钮、聊天页）共享同一套转写和管线逻辑。

## 架构概览

```
┌─ UI 层（三个入口点）─────────────────────────────────────────┐
│                                                               │
│  ① AiInputBar  ② MainShell/VoiceOverlay  ③ ChatInputBar     │
│                                                               │
│  统一行为：                                                    │
│  - 长按：启动 AudioRecorder + PlatformSttService              │
│  - 实时显示 partialText                                       │
│  - 松手：停止录音+STT，得到 filePath + platformText            │
│  - 调用 orchestrator.transcribe(...)                          │
│                                                               │
│  action=transcribeOnly → 填入输入框                           │
│  action=send           → pipeline.processVoiceResult(...)     │
└───────────────────────┬───────────────────────────────────────┘
                        │
                        ▼
┌─ 转写编排层 ─────────────────────────────────────────────────┐
│                                                               │
│  VoiceTranscriptionOrchestrator (新增)                        │
│                                                               │
│  transcribe(audioPath, platformText, provider)                │
│    ├─ 检测引擎可用性                                          │
│    ├─ 保存音频文件                                            │
│    ├─ 双引擎：并行等待 Whisper，组合结果                       │
│    ├─ 单引擎：直接返回                                        │
│    └─ 返回 DualTranscriptionResult                            │
│                                                               │
│  canTranscribe() → bool  (UI 层用于决定是否显示录音按钮)       │
│                                                               │
└───────────────────────┬───────────────────────────────────────┘
                        │
                        ▼
┌─ 管线层 ─────────────────────────────────────────────────────┐
│                                                               │
│  TransactionPipeline (调整)                                   │
│                                                               │
│  processVoiceResult(transcription, provider, ...)             │
│    ├─ 构建 prompt（双引擎交叉校验 或 单引擎直接解析）          │
│    ├─ _resolveReference()                                     │
│    ├─ _buildEnrichedContext()                                  │
│    ├─ LlmRepository.parseTransaction()                        │
│    └─ 返回 PipelineResult                                     │
│                                                               │
│  processText(text) — 不变                                     │
│  processVoice(audioPath, provider) — 废弃                     │
│  transcribeOnly(audioPath, provider) — 废弃                   │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

## 组件详设

### DualTranscriptionResult

编排层的输出，管线层的输入——两个世界的桥梁。

```dart
class DualTranscriptionResult {
  /// 设备原生引擎转写文本（引擎不可用时为 null）
  final String? platformText;

  /// Whisper 云端引擎转写文本（引擎不可用时为 null）
  final String? whisperText;

  /// 保存后的音频文件路径
  final String? audioPath;

  /// 合并后的推荐文本（一致时直接取，不一致时取较长/较完整的那个）
  ///
  /// 注意：此字段用于"快速取值"（如填入输入框、显示 normalizedText）。
  /// 双引擎有差异时，LLM 会收到两段原始文本做交叉校验，不依赖此字段。
  String get mergedText {
    if (platformText != null && whisperText != null) {
      return platformText == whisperText
          ? platformText!
          : _pickBetter(platformText!, whisperText!);
    }
    return platformText ?? whisperText ?? '';
  }

  /// 从两段有差异的文本中选取"更可能正确"的那个
  ///
  /// 策略：
  /// 1. 优先取更长的文本（通常包含更多有效信息）
  /// 2. 长度接近时取 Whisper 结果（云端模型精度通常更高）
  static String _pickBetter(String platform, String whisper) {
    // 长度差异 > 20% 时取更长的
    final lenDiff = (platform.length - whisper.length).abs();
    final avgLen = (platform.length + whisper.length) / 2;
    if (avgLen > 0 && lenDiff / avgLen > 0.2) {
      return platform.length > whisper.length ? platform : whisper;
    }
    // 长度接近时取 Whisper（精度更高）
    return whisper;
  }

  /// 参与转写的引擎数量
  int get engineCount =>
      (platformText != null ? 1 : 0) + (whisperText != null ? 1 : 0);

  /// 两引擎文本是否完全一致
  bool get isIdentical => platformText != null && whisperText != null
      && platformText == whisperText;
}
```

### VoiceTranscriptionOrchestrator

```dart
class VoiceTranscriptionOrchestrator {
  final PlatformSttService _platformStt;
  final VoiceRecognitionService _whisperService;
  final MediaStorageService _mediaStorage;

  /// 检测是否有至少一个引擎可用（UI 层调用，决定是否显示录音按钮）
  Future<bool> canTranscribe(LlmProvider? provider) async {
    final hasPlatform = await _platformStt.isAvailable();
    final hasWhisper = provider?.getModelForCapability(ModelCapability.audio) != null;
    return hasPlatform || hasWhisper;
  }

  /// 执行转写
  ///
  /// [audioPath] 录音文件路径
  /// [platformText] PlatformSttService 的实时识别结果（可能为 null）
  /// [provider] 当前 LLM 服务商配置
  Future<DualTranscriptionResult> transcribe({
    required String audioPath,
    String? platformText,
    required LlmProvider provider,
  }) async {
    // 1. 保存音频
    final savedPath = await _mediaStorage.saveAudio(audioPath);

    // 2. 检测引擎可用性
    final hasPlatform = platformText != null && platformText.trim().isNotEmpty;
    final hasWhisper = provider.getModelForCapability(ModelCapability.audio) != null;

    if (!hasPlatform && !hasWhisper) {
      throw LlmException('未配置语音识别引擎', errorCode: 'voiceErrorNoEngineAvailable');
    }

    // 3. 单引擎快速返回
    if (hasPlatform && !hasWhisper) {
      return DualTranscriptionResult(
        platformText: platformText,
        audioPath: savedPath,
      );
    }

    // 4. Whisper 引擎（单引擎或双引擎）
    final whisperText = await _whisperService.transcribe(provider, savedPath);

    return DualTranscriptionResult(
      platformText: hasPlatform ? platformText : null,
      whisperText: whisperText,
      audioPath: savedPath,
    );
  }
}
```

### PlatformSttService 新增方法

```dart
// PlatformSttService 中新增
Future<bool> isAvailable() async {
  if (!_initialized) {
    return await initialize();
  }
  return _initialized;
}
```

### TransactionPipeline 新增方法

```dart
Future<PipelineResult> processVoiceResult({
  required DualTranscriptionResult transcription,
  required LlmProvider provider,
  String? categoryTaxonomy,
  String locale = 'zh',
  int? bookId,
}) async {
  // 构建输入文本
  String inputForLlm;

  if (transcription.engineCount >= 2 && !transcription.isIdentical) {
    // 双引擎有差异 → 交叉校验 prompt
    inputForLlm = _buildCrossValidationPrompt(
      transcription.platformText!,
      transcription.whisperText!,
    );
  } else {
    // 单引擎或双引擎一致 → 直接用合并文本
    inputForLlm = transcription.mergedText;
  }

  if (inputForLlm.trim().isEmpty) {
    throw LlmException('语音识别结果为空', errorCode: 'pipelineErrorEmptyVoiceResult');
  }

  // 后续：引用检测 → RAG → LLM 解析（与现有 processText 逻辑一致）
  final resolved = await _resolveReference(inputForLlm, bookId);
  final context = await _buildEnrichedContext(resolved, bookId);
  final results = await _llmRepo.parseTransaction(
    resolved,
    categoryTaxonomy: categoryTaxonomy,
    locale: locale,
    fewShotExamples: context.fewShotExamples,
    similarTransactions: context.similarTransactions,
  );

  return PipelineResult(
    normalizedText: transcription.mergedText,
    transactions: results,
    source: InputSource.voice,
    mediaFilePath: transcription.audioPath,
  );
}

String _buildCrossValidationPrompt(String platformText, String whisperText) {
  return '''## 语音识别交叉校验
以下文字由两个不同的语音识别引擎转写，可能存在差异。请综合两段文本，判断用户的实际意图，然后解析为记账信息。

引擎A（设备原生）：「$platformText」
引擎B（云端Whisper）：「$whisperText」

请先判断最可能的正确文本，再提取记账信息。''';
}
```

## 降级策略

| Platform 可用 | Whisper 可用 | 行为 |
|:---:|:---:|------|
| ✅ | ✅ | 双引擎并行 → LLM 交叉校验 |
| ✅ | ❌ | 仅 Platform → 单引擎直接用文本 |
| ❌ | ✅ | 仅 Whisper → 单引擎云端转写 |
| ❌ | ❌ | 抛异常，提示用户检查 AI 设置或设备支持 |

LLM 交易解析始终需要 LLM provider 配置。引擎降级只影响"语音→文本"阶段。

## 入口点统一改造

### 三个入口点改动前后对比

**改动前**：

| 入口 | 行为 |
|------|------|
| 首页 AiInputBar | 录音 → `pipeline.processVoice(文件)` [只走 Whisper] |
| 浮动按钮 MainShell | 录音 → `pipeline.transcribeOnly(文件)` [只走 Whisper] |
| 聊天页 ChatInputBar | PlatformStt → `onSubmit(文本)` [只走 Platform] |

**改动后**：

| 入口 | 行为 |
|------|------|
| 首页 AiInputBar | 录音+PlatformStt → `orchestrator.transcribe(...)` → `pipeline.processVoiceResult(...)` |
| 浮动按钮 MainShell | 同上 |
| 聊天页 ChatInputBar | 同上（移除自管 PlatformStt 逻辑） |

### UI 层统一模式

```dart
// 所有入口点的录音逻辑统一为：
void _onLongPressStart() {
  _audioRecorder.start(...);              // 开始录音
  _platformStt.startListening();          // 同时启动原生 STT
}

void _onLongPressEnd() {
  final filePath = await _audioRecorder.stop();
  final platformText = await _platformStt.stopListening();
  
  // 交给编排层
  final result = await orchestrator.transcribe(
    audioPath: filePath,
    platformText: platformText,
    provider: provider,
  );
  
  // 后续根据 action 分支
  if (action == transcribeOnly) {
    inputController.text = result.mergedText;
  } else {
    pipeline.processVoiceResult(transcription: result, ...);
  }
}
```

## 清理清单

### 删除

- `VoiceModeSetting` (`lib/features/settings/data/services/voice_mode_setting.dart`)
- `VoiceInputMode` 枚举 (`lib/features/chat/presentation/widgets/chat_input_bar.dart`)
- `SttMode` 枚举 (`lib/features/text_ai/data/services/platform_stt_service.dart`)
- 设置页 `_buildVoiceModeCard` 切换 UI (`lib/features/settings/presentation/pages/llm_settings_page.dart`)
- `TransactionPipeline.processVoice()` 方法
- `TransactionPipeline.transcribeOnly()` 方法

### 新增

- `VoiceTranscriptionOrchestrator` (`lib/core/ai/voice_transcription_orchestrator.dart`)
- `DualTranscriptionResult` 数据类（同文件或独立文件）
- `PlatformSttService.isAvailable()` 方法
- `TransactionPipeline.processVoiceResult()` 方法
- `TransactionPipeline._buildCrossValidationPrompt()` 方法
- `voiceTranscriptionOrchestratorProvider` DI 注册 (`lib/config/di/ai_providers.dart`)

### 调整

- `AiInputBar`：onVoiceRecorded 回调增加 platformText 参数；录音时同时启动 PlatformStt
- `VoiceRecordingOverlay`：录音时同时启动 PlatformStt，结果包含 platformText
- `ChatInputBar`：移除自管 PlatformStt 逻辑，改为统一录音+编排路径；移除 voiceMode/sttService 属性
- `HomePage._handleVoiceRecorded`：使用 orchestrator + processVoiceResult
- `MainShell._handleVoiceResult`：同上
- `AiChatPage._processInput`：语音分支改为 orchestrator 路径
- `transactionPipelineProvider` DI：移除 voiceService 注入
- 新增 `voiceTranscriptionOrchestratorProvider` DI

## LLM 交叉校验 Prompt 策略

**单引擎或双引擎一致时**：不注入额外 prompt，直接用正常交易解析 prompt。省 token。

**双引擎有差异时**：

```
## 语音识别交叉校验
以下文字由两个不同的语音识别引擎转写，可能存在差异。请综合两段文本，
判断用户的实际意图，然后解析为记账信息。

引擎A（设备原生）：「{platformText}」
引擎B（云端Whisper）：「{whisperText}」

请先判断最可能的正确文本，再提取记账信息。
```

这段文本作为用户输入传给 `_llmRepo.parseTransaction()`，后续接正常的 system prompt（分类体系、RAG 上下文、few-shot examples）。LLM 一次调用同时完成校验合并和交易解析。

## 错误处理

| 场景 | 处理 |
|------|------|
| 两个引擎都不可用 | 抛 `LlmException('voiceErrorNoEngineAvailable')`，UI 提示检查设置 |
| Platform STT 返回空 + Whisper 失败 | 抛 `LlmException('pipelineErrorEmptyVoiceResult')` |
| Whisper API 超时/401 | 现有错误码不变，降级为仅 Platform 结果 |
| LLM 交叉校验解析失败 | 走通用错误处理 `resolveLlmError()` |
| 音频文件保存失败 | 编排层捕获，不阻塞（Platform 文本仍可用） |
