# AI 语音识别优化方案

> 目标：支持多 provider 语音识别、降低延迟、优化音频参数
> 涉及文件：`voice_recognition_service.dart`、`transaction_pipeline.dart`、`chat_input_bar.dart`、`ai_provider_presets.dart`、`ai_chat_page.dart`

---

## 优化项 1：多 Provider 语音识别适配

**问题**: `voice_recognition_service.dart` 硬编码 Whisper API 格式（`/audio/transcriptions` + Bearer token）。当用户主 provider 是 Anthropic 时语音功能完全不可用；Qwen 的 SenseVoice/Paraformer 使用不同 API 路径。

**文件**: `lib/features/text_ai/data/services/voice_recognition_service.dart:45-55`

**方案**:
- 将 `transcribe` 方法改为根据 provider 类型分发到不同的实现：
  ```dart
  Future<String> transcribe(LlmProvider provider, String audioFilePath, {String language = 'zh'}) async {
    final format = _resolveAudioApiFormat(provider);
    switch (format) {
      case AudioApiFormat.whisper:
        return _transcribeWhisper(provider, audioFilePath, language);
      case AudioApiFormat.qwenAsr:
        return _transcribeQwenAsr(provider, audioFilePath, language);
      default:
        throw LlmException('该服务商不支持语音识别', errorCode: 'voiceErrorUnsupportedProvider');
    }
  }
  ```
- 新增 `AudioApiFormat` 枚举：`whisper`、`qwenAsr`
- 新增 `_transcribeQwenAsr` 方法，适配阿里云 SenseVoice API：
  - Endpoint: `{baseUrl}/services/audio/asr/transcription`
  - 支持 `model: sensevoice-v1` 或 `paraformer-v2`
  - 返回格式与 Whisper 类似但字段名不同

**新增文件**: 无（在现有 `voice_recognition_service.dart` 中扩展）

**改动文件**:
- `voice_recognition_service.dart`: 增加分发逻辑和 Qwen 实现
- `ai_provider_presets.dart`: 在 preset 中增加 `AudioApiFormat` 标记

**降级策略**: 如果当前 provider 不支持音频，检查是否有其他已配置的 provider 支持，自动切换。如果都没有，提示用户配置。

**验证**: 配置 Qwen 为主 provider → 录音 → 使用 SenseVoice 转写成功

---

## 优化项 2：音频编码参数优化

**问题**: 录音使用 AAC-LC 128kbps/44.1kHz stereo，10 秒语音约 160KB。Whisper 只需 16kHz mono 即可，多出的数据是浪费的带宽。

**文件**: `lib/features/chat/presentation/widgets/chat_input_bar.dart`（录音配置部分）

**方案**:
- 修改 `AudioRecorder` 配置：
  ```
  编码: AAC-LC
  码率: 64kbps（从 128kbps 降低）
  采样率: 16000Hz（从 44100Hz 降低）
  声道: mono（从 stereo 降低）
  ```
- 预期效果：10 秒语音从 ~160KB 降至 ~50KB，上传速度提升 3x
- 同步修改 `voice_recording_overlay.dart` 中的录音配置，保持一致

**验证**: 录音 10 秒，文件大小 < 60KB，Whisper 转写准确度不下降

---

## 优化项 3：语音管线 UI 流式反馈

**问题**: 语音录入后用户只看到"正在处理…"占位符，要等 Whisper 转写（1-3s）+ LLM 解析（2-5s）全部完成后才看到结果。总等待 3-8 秒无任何反馈。

**文件**: `lib/features/chat/presentation/pages/ai_chat_page.dart:310-341`、`lib/core/ai/transaction_pipeline.dart:108-133`

**方案**:
- 将 `_processInput` 中语音的处理从单次 `processVoice` 拆分为两步：
  ```dart
  case InputSource.voice:
    // Step 1: 转写（1-3s）→ 立即更新 UI 显示转写文本
    final transcribedText = await _pipeline.transcribeOnly(
      audioTempPath: voicePath!,
      provider: provider,
    );
    // 更新用户消息从占位符 → 转写文本
    _updateUserMessageContent(userMsgId, transcribedText);
    
    // Step 2: 解析（2-5s）→ 显示确认卡片
    final results = await _llmRepo.parseTransaction(transcribedText, ...);
    // ... 生成 ConfirmCard
    break;
  ```
- `transcribeOnly` 方法已存在于 `transaction_pipeline.dart:87-102`，可直接复用
- 需要新增 `_updateUserMessageContent` 方法更新已插入的用户消息内容

**新增方法**:
```dart
/// 更新用户消息内容（从占位符更新为转写文本）
void _updateUserMessageContent(int msgId, String newContent) {
  setState(() {
    final idx = _items.indexWhere((i) => i.message?.id == msgId);
    if (idx != -1) {
      // 更新内存中的消息
      _items[idx] = _ChatItem.user(ConversationMessage(
        ..._items[idx].message!,
        content: newContent,
      ));
    }
  });
  // 同步更新数据库
  _chatRepo.updateMessageContent(msgId, newContent);
}
```

**改动文件**:
- `ai_chat_page.dart`: 拆分语音处理流程，新增 `_updateUserMessageContent`
- `chat_repository.dart` + `chat_repository_impl.dart`: 新增 `updateMessageContent` 方法

**验证**: 录音后 1-3 秒内看到转写文本，再等 2-5 秒看到解析结果

---

## 优化项 4：文件名 MIME 类型适配

**问题**: `voice_recognition_service.dart:38` 硬编码 `filename: 'recording.m4a'`，可能与实际格式不符。

**文件**: `lib/features/text_ai/data/services/voice_recognition_service.dart:37-39`

**方案**:
- 根据文件扩展名动态设置 filename：
  ```dart
  final ext = audioFilePath.split('.').last.toLowerCase();
  final filename = 'recording.$ext';  // 保留原始扩展名
  ```
- 同时增加 `contentType` 字段映射：
  ```dart
  final mimeMap = {'m4a': 'audio/mp4', 'aac': 'audio/aac', 'wav': 'audio/wav', 'mp3': 'audio/mpeg', 'ogg': 'audio/ogg'};
  final contentType = mimeMap[ext] ?? 'audio/mp4';
  ```

**验证**: 上传 .m4a 文件时 filename 和 contentType 一致

---

## 优化项 5：语音识别超时与重试

**问题**: 当前超时使用 provider 全局 `timeoutSeconds`（默认 30s），但音频上传通常需要更长时间（大文件 + ASR 处理）。且无重试机制。

**文件**: `lib/features/text_ai/data/services/voice_recognition_service.dart:48-53`

**方案**:
- 为语音识别设置独立的超时策略：
  ```dart
  // sendTimeout: 根据文件大小动态计算（每MB + 10s，最低 30s）
  // receiveTimeout: 固定 60s（ASR 处理时间不可预测）
  final fileSize = await file.length();
  final sendTimeout = Duration(seconds: max(30, (fileSize / 1024 / 1024 * 10).round() + 10));
  const receiveTimeout = Duration(seconds: 60);
  ```
- 增加单次自动重试（仅在超时和 5xx 错误时）：
  ```dart
  try {
    return await _doTranscribe(...);
  } on DioException catch (e) {
    if (_isRetryable(e)) {
      return await _doTranscribe(...);  // 重试一次
    }
    rethrow;
  }
  ```

**验证**: 网络抖动时自动重试成功；大文件（30s+）不误超时

---

## 优化项 6：连续录音防抖

**问题**: 用户快速多次触发录音（如长按松开后立刻再按），可能产生多个并发转写请求。

**文件**: `lib/features/chat/presentation/widgets/chat_input_bar.dart`

**方案**:
- 在 `ChatInputBar` 中增加 `_isRecording` 状态锁
- 录音开始时设为 `true`，转写完成后设为 `false`
- `onVoiceStart` 中检查 `_isRecording`，如果为 true 则忽略

**验证**: 快速双击录音按钮 → 只触发一次录音

---

## 执行顺序建议

| 顺序 | 优化项 | 难度 | 预期收益 |
|------|--------|------|----------|
| 1 | 音频编码参数优化 | ⭐ | 带宽减少 60% |
| 2 | 文件名 MIME 适配 | ⭐ | 兼容性提升 |
| 3 | 连续录音防抖 | ⭐ | 防止重复请求 |
| 4 | 超时与重试 | ⭐⭐ | 可靠性提升 |
| 5 | UI 流式反馈 | ⭐⭐ | 感知速度大幅提升 |
| 6 | 多 Provider 适配 | ⭐⭐⭐ | 功能覆盖度提升 |
