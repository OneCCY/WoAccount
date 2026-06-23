# 双引擎语音记账 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将语音记账从"单引擎各自为政"重构为"双引擎并行 + LLM 交叉校验"，所有入口点统一走编排层。

**Architecture:** 新增 `VoiceTranscriptionOrchestrator` 封装双引擎转写编排，`TransactionPipeline` 新增 `processVoiceResult()` 接收双引擎结果并构建交叉校验 prompt。三个 UI 入口点统一为"录音 + PlatformStt 同时启动 → 编排层 → 管线层"的流程。

**Tech Stack:** Flutter, Riverpod, drift (DB), Dio (HTTP), speech_to_text (设备 STT), record (录音)

**Spec:** `docs/superpowers/specs/2026-06-22-dual-engine-voice-transcription-design.md`

## Global Constraints

- 所有 UI 文本使用 `AppLocalizations`（L10n），不硬编码中文字符串
- 每个 Task 结束后 `flutter build apk --debug` 编译通过
- 遵循 Conventional Commits：`feat(scope): ...` / `refactor(scope): ...`
- 语音相关 scope 统一用 `voice`

---

## File Map

| 操作 | 文件 | 职责 |
|------|------|------|
| **Create** | `lib/core/ai/voice_transcription_orchestrator.dart` | 双引擎编排 + DualTranscriptionResult + EngineAvailability |
| **Modify** | `lib/features/text_ai/data/services/platform_stt_service.dart` | 新增 `isAvailable()` 方法 |
| **Modify** | `lib/core/ai/transaction_pipeline.dart` | 新增 `processVoiceResult()` + `_buildCrossValidationPrompt()`；删除 `processVoice()` / `transcribeOnly()` |
| **Modify** | `lib/config/di/ai_providers.dart` | 新增 orchestrator DI；从 pipeline 移除 voiceService |
| **Modify** | `lib/core/widgets/voice/voice_recording_overlay.dart` | 录音时同时启动 PlatformStt；VoiceResult 增加 platformText |
| **Modify** | `lib/features/home/presentation/widgets/ai_input_bar.dart` | 录音时同时启动 PlatformStt；回调增加 platformText |
| **Modify** | `lib/core/widgets/navigation/main_shell.dart` | 使用 orchestrator + processVoiceResult |
| **Modify** | `lib/features/home/presentation/pages/home_page.dart` | 使用 orchestrator + processVoiceResult |
| **Modify** | `lib/features/chat/presentation/widgets/chat_input_bar.dart` | 移除 VoiceInputMode 逻辑；录音时同时启动 PlatformStt |
| **Modify** | `lib/features/chat/presentation/pages/ai_chat_page.dart` | 移除 VoiceModeSetting 读取；使用 orchestrator |
| **Delete** | `lib/features/settings/data/services/voice_mode_setting.dart` | 不再需要手动选择引擎 |
| **Modify** | `lib/features/settings/presentation/pages/llm_settings_page.dart` | 移除 `_buildVoiceModeCard` 和相关导入 |
| **Modify** | `lib/l10n/app_en.arb` (及其他 locale) | 新增错误提示 key（如有） |

---

### Task 1: Foundation — DualTranscriptionResult + Orchestrator + DI

**Files:**
- Create: `lib/core/ai/voice_transcription_orchestrator.dart`
- Modify: `lib/features/text_ai/data/services/platform_stt_service.dart:34-53`
- Modify: `lib/config/di/ai_providers.dart:48-56`

**Interfaces:**
- Consumes: `PlatformSttService`, `VoiceRecognitionService`, `MediaStorageService`, `LlmProvider`
- Produces: `DualTranscriptionResult`, `VoiceTranscriptionOrchestrator`, `voiceTranscriptionOrchestratorProvider`

- [ ] **Step 1: Add `isAvailable()` to PlatformSttService**

```dart
// platform_stt_service.dart — 在 initialize() 方法之后添加：

  /// 检查引擎是否可用（已初始化且设备支持）
  Future<bool> isAvailable() async {
    if (!_initialized) {
      return await initialize();
    }
    return _initialized;
  }
```

- [ ] **Step 2: Create voice_transcription_orchestrator.dart**

```dart
import 'dart:io';
import '../media/media_storage_service.dart';
import '../../features/ai/data/models/llm_config.dart';
import '../../features/text_ai/data/services/platform_stt_service.dart';
import '../../features/text_ai/data/services/voice_recognition_service.dart';

/// 引擎可用性检测结果
class EngineAvailability {
  final bool platform;
  final bool whisper;
  const EngineAvailability({required this.platform, required this.whisper});
  bool get none => !platform && !whisper;
  bool get both => platform && whisper;
}

/// 双引擎语音转写结果
class DualTranscriptionResult {
  /// 设备原生引擎转写文本（引擎不可用时为 null）
  final String? platformText;

  /// Whisper 云端引擎转写文本（引擎不可用时为 null）
  final String? whisperText;

  /// 保存后的音频文件路径
  final String? audioPath;

  const DualTranscriptionResult({
    this.platformText,
    this.whisperText,
    this.audioPath,
  });

  /// 合并后的推荐文本
  ///
  /// 此字段用于快速取值（填入输入框、显示 normalizedText）。
  /// 双引擎有差异时，LLM 会收到两段原始文本做交叉校验，不依赖此字段。
  String get mergedText {
    if (platformText != null && whisperText != null) {
      return platformText == whisperText
          ? platformText!
          : _pickBetter(platformText!, whisperText!);
    }
    return platformText ?? whisperText ?? '';
  }

  /// 参与转写的引擎数量
  int get engineCount =>
      (platformText != null && platformText!.trim().isNotEmpty ? 1 : 0) +
      (whisperText != null && whisperText!.trim().isNotEmpty ? 1 : 0);

  /// 两引擎文本是否完全一致
  bool get isIdentical =>
      platformText != null &&
      whisperText != null &&
      platformText!.trim() == whisperText!.trim();

  /// 从两段有差异的文本中选取更可能正确的那个
  ///
  /// 策略：长度差异 > 20% 时取更长的；长度接近时取 Whisper（精度更高）。
  static String _pickBetter(String platform, String whisper) {
    final lenDiff = (platform.length - whisper.length).abs();
    final avgLen = (platform.length + whisper.length) / 2;
    if (avgLen > 0 && lenDiff / avgLen > 0.2) {
      return platform.length > whisper.length ? platform : whisper;
    }
    return whisper;
  }
}

/// 双引擎语音转写编排器
///
/// 职责：接收录音文件和平台 STT 结果，协调双引擎转写，返回结构化结果。
/// 不负责录音（录音由 UI 层的 AudioRecorder 管理）。
class VoiceTranscriptionOrchestrator {
  final PlatformSttService _platformStt;
  final VoiceRecognitionService _whisperService;
  final MediaStorageService _mediaStorage;

  VoiceTranscriptionOrchestrator({
    required PlatformSttService platformStt,
    required VoiceRecognitionService whisperService,
    required MediaStorageService mediaStorage,
  })  : _platformStt = platformStt,
        _whisperService = whisperService,
        _mediaStorage = mediaStorage;

  /// 检测是否有至少一个引擎可用（UI 层调用，决定是否显示录音按钮）
  Future<bool> canTranscribe(LlmProvider? provider) async {
    final hasPlatform = await _platformStt.isAvailable();
    final hasWhisper =
        provider?.getModelForCapability(ModelCapability.audio) != null;
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
    // 1. 保存音频到永久存储
    String? savedPath;
    try {
      savedPath = await _mediaStorage.saveAudio(audioPath);
    } catch (_) {
      // 保存失败不阻塞——Platform 文本仍可用
    }

    // 2. 检测引擎可用性
    final hasPlatform =
        platformText != null && platformText.trim().isNotEmpty;
    final hasWhisper =
        provider.getModelForCapability(ModelCapability.audio) != null;

    if (!hasPlatform && !hasWhisper) {
      throw const LlmException(
        '未配置语音识别引擎，请检查 AI 设置或设备语音支持',
        errorCode: 'voiceErrorNoEngineAvailable',
      );
    }

    // 3. 仅 Platform 引擎
    if (hasPlatform && !hasWhisper) {
      return DualTranscriptionResult(
        platformText: platformText,
        audioPath: savedPath,
      );
    }

    // 4. Whisper 引擎（单引擎或双引擎）
    String? whisperText;
    try {
      whisperText = await _whisperService.transcribe(provider, savedPath ?? audioPath);
    } catch (e) {
      // Whisper 失败时，如果 Platform 有结果则降级
      if (hasPlatform) {
        return DualTranscriptionResult(
          platformText: platformText,
          audioPath: savedPath,
        );
      }
      rethrow; // 仅 Whisper 且失败 → 向上传播错误
    }

    return DualTranscriptionResult(
      platformText: hasPlatform ? platformText : null,
      whisperText: whisperText,
      audioPath: savedPath,
    );
  }
}
```

- [ ] **Step 3: Update DI — add orchestrator, adjust pipeline**

```dart
// ai_providers.dart — 在 platformSttServiceProvider 之后添加：

/// 双引擎语音转写编排器 Provider
final voiceTranscriptionOrchestratorProvider =
    Provider<VoiceTranscriptionOrchestrator>((ref) {
  return VoiceTranscriptionOrchestrator(
    platformStt: ref.watch(platformSttServiceProvider),
    whisperService: ref.watch(voiceRecognitionServiceProvider),
    mediaStorage: ref.watch(mediaStorageServiceProvider),
  );
});
```

暂时保留 `transactionPipelineProvider` 中的 `voiceService` 参数不变（Task 2 移除）。

- [ ] **Step 4: Verify compilation**

Run: `flutter build apk --debug`
Expected: BUILD SUCCESSFUL (新增代码无调用方，不影响现有逻辑)

- [ ] **Step 5: Commit**

```bash
git add lib/core/ai/voice_transcription_orchestrator.dart \
        lib/features/text_ai/data/services/platform_stt_service.dart \
        lib/config/di/ai_providers.dart
git commit -m "feat(voice): add DualTranscriptionResult and VoiceTranscriptionOrchestrator"
```

---

### Task 2: Pipeline Update + Remove Voice Mode Setting

**Files:**
- Modify: `lib/core/ai/transaction_pipeline.dart:114-174`
- Modify: `lib/config/di/ai_providers.dart:48-56`
- Delete: `lib/features/settings/data/services/voice_mode_setting.dart`
- Modify: `lib/features/settings/presentation/pages/llm_settings_page.dart:1-16,140-160,208-210,367-471`

**Interfaces:**
- Consumes: `DualTranscriptionResult` (from Task 1)
- Produces: `TransactionPipeline.processVoiceResult()` for Task 3

- [ ] **Step 1: Add processVoiceResult and _buildCrossValidationPrompt to TransactionPipeline**

在 `transaction_pipeline.dart` 中，`processText()` 方法之后添加：

```dart
  /// 处理双引擎语音转写结果
  ///
  /// 双引擎有差异时构建交叉校验 prompt，LLM 一次调用完成校验+解析。
  /// 单引擎或一致时直接用合并文本解析。
  Future<PipelineResult> processVoiceResult({
    required DualTranscriptionResult transcription,
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
      throw const LlmException(
        '语音识别结果为空，请重新录制',
        errorCode: 'pipelineErrorEmptyVoiceResult',
      );
    }

    // [Tool Use] 引用检测 + [RAG + Episodic Memory] 上下文构建
    final resolvedText = await _resolveReference(inputForLlm, bookId);
    final context = await _buildEnrichedContext(resolvedText, bookId);

    // 用文本走 AI 记账解析（带增强上下文）
    final results = await _llmRepo.parseTransaction(
      resolvedText,
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

  /// 构建双引擎交叉校验 prompt
  String _buildCrossValidationPrompt(String platformText, String whisperText) {
    return '## 语音识别交叉校验\n'
        '以下文字由两个不同的语音识别引擎转写，可能存在差异。'
        '请综合两段文本，判断用户的实际意图，然后解析为记账信息。\n\n'
        '引擎A（设备原生）：「$platformText」\n'
        '引擎B（云端Whisper）：「$whisperText」\n\n'
        '请先判断最可能的正确文本，再提取记账信息。';
  }
```

- [ ] **Step 2: Remove old processVoice and transcribeOnly from TransactionPipeline**

删除 `transaction_pipeline.dart` 中的以下两个方法：
- `transcribeOnly()` (lines 117-132)
- `processVoice()` (lines 134-174)

同时移除文件顶部不再需要的 import：
- `import '../../features/text_ai/data/services/voice_recognition_service.dart';`

从构造函数中移除 `VoiceRecognitionService` 参数：

```dart
class TransactionPipeline {
  final LlmRepository _llmRepo;
  final ImageRecognitionService _imageService;
  final MediaStorageService _mediaStorage;
  final AppDatabase _db;

  TransactionPipeline({
    required LlmRepository llmRepo,
    required ImageRecognitionService imageService,
    required MediaStorageService mediaStorage,
    required AppDatabase db,
  })  : _llmRepo = llmRepo,
        _imageService = imageService,
        _mediaStorage = mediaStorage,
        _db = db;
```

添加新的 import：

```dart
import 'voice_transcription_orchestrator.dart';
```

- [ ] **Step 3: Update DI — remove voiceService from pipeline**

```dart
// ai_providers.dart — transactionPipelineProvider 改为：
final transactionPipelineProvider = Provider<TransactionPipeline>((ref) {
  return TransactionPipeline(
    llmRepo: ref.watch(llmRepositoryProvider),
    imageService: ref.watch(imageRecognitionServiceProvider),
    mediaStorage: ref.watch(mediaStorageServiceProvider),
    db: ref.watch(appDatabaseProvider),
  );
});
```

移除顶部不再需要的 import：
- `import '../../features/text_ai/data/services/voice_recognition_service.dart';`

（保留 `platform_stt_service.dart` import 因为 orchestrator 还需要）

- [ ] **Step 4: Delete VoiceModeSetting**

删除文件：`lib/features/settings/data/services/voice_mode_setting.dart`

- [ ] **Step 5: Remove voice mode card from settings page**

在 `llm_settings_page.dart` 中：

移除 import：
```dart
// 删除这两行：
import '../../../chat/presentation/widgets/chat_input_bar.dart';
import '../../data/services/voice_mode_setting.dart';
```

移除 state 字段和加载逻辑：
```dart
// 删除字段：
VoiceInputMode _voiceMode = VoiceInputMode.platform;

// 在 _load() 中删除：
final voiceMode = await VoiceModeSetting.getMode();
// 以及：
_voiceMode = voiceMode;
```

移除 UI 中的语音模式卡片：
```dart
// 在 build 方法中删除：
_buildVoiceModeCard(l10n),
// 以及前面的注释和间距：
// 3. 语音输入模式
const SizedBox(height: 12),  // 如果卡片前面有间距
```

删除 `_buildVoiceModeCard` 和 `_buildVoiceModeOption` 两个方法（lines 367-471）。

- [ ] **Step 6: Verify compilation**

Run: `flutter build apk --debug`

预期：会编译失败，因为 Task 3 的入口点还在调用已删除的 `processVoice()` / `transcribeOnly()`。这是预期的——Task 2 和 Task 3 必须一起完成。

**跳过此步骤，直接进入 Task 3。**

- [ ] **Step 7: Commit（暂存到本地，与 Task 3 一起提交）**

不单独 commit，与 Task 3 合并提交。

---

### Task 3: UI Entry Points — Unified Voice Flow

**Files:**
- Modify: `lib/core/widgets/voice/voice_recording_overlay.dart:11-24,66-143,188-222`
- Modify: `lib/features/home/presentation/widgets/ai_input_bar.dart:30-31,86-135,169-207`
- Modify: `lib/core/widgets/navigation/main_shell.dart:37-65`
- Modify: `lib/features/home/presentation/pages/home_page.dart:73-177`
- Modify: `lib/features/chat/presentation/widgets/chat_input_bar.dart:1-18,29-49,55-198`
- Modify: `lib/features/chat/presentation/pages/ai_chat_page.dart:69,152-157,159-207,307-508,834-843`

**Interfaces:**
- Consumes: `VoiceTranscriptionOrchestrator.transcribe()`, `TransactionPipeline.processVoiceResult()` (from Tasks 1-2)
- Produces: 统一的语音入口点行为

- [ ] **Step 1: Update VoiceRecordingOverlay — add PlatformStt support**

在 `voice_recording_overlay.dart` 中：

更新 `VoiceResult` 类，增加 `platformText` 字段：

```dart
/// 语音录制结果数据
class VoiceResult {
  final VoiceResultAction action;
  final String? filePath;
  final String? platformText;  // 新增：PlatformStt 实时识别结果

  const VoiceResult({required this.action, this.filePath, this.platformText});
}
```

更新 `VoiceRecordingOverlay.show()` 签名，接受 `PlatformSttService` 参数：

```dart
class VoiceRecordingOverlay {
  static Future<VoiceResult?> show(
    BuildContext context, {
    PlatformSttService? sttService,
  }) async {
    return Navigator.of(context).push<VoiceResult>(
      _VoiceRecordingRoute(sttService: sttService),
    );
  }
}
```

更新 `_VoiceRecordingRoute` 和 `_VoiceRecordingPage` 传递 `sttService`：

```dart
class _VoiceRecordingRoute extends PageRouteBuilder<VoiceResult> {
  final PlatformSttService? sttService;
  _VoiceRecordingRoute({this.sttService})
      : super(
          opaque: false,
          barrierColor: Colors.transparent,
          transitionDuration: const Duration(milliseconds: 150),
          reverseTransitionDuration: const Duration(milliseconds: 100),
          pageBuilder: (context, animation, secondaryAnimation) =>
              _VoiceRecordingPage(animation: animation, sttService: sttService),
        );
}

class _VoiceRecordingPage extends StatefulWidget {
  final Animation<double> animation;
  final PlatformSttService? sttService;
  const _VoiceRecordingPage({required this.animation, this.sttService});

  @override
  State<_VoiceRecordingPage> createState() => _VoiceRecordingPageState();
}
```

在 `_VoiceRecordingPageState` 中添加 `String? _platformText` 字段。

在 `_startRecording()` 中，录音成功后同时启动 PlatformStt：

```dart
// 在 await _audioRecorder.start(...) 成功后，添加：
if (widget.sttService != null) {
  await widget.sttService!.startListening();
  widget.sttService!.partialTextStream.listen((text) {
    if (mounted) _platformText = text;
  });
}
```

在 `_onPointerUp()` 中，停止录音时同时停止 PlatformStt：

```dart
// 在 await _audioRecorder.stop() 之后添加：
String? platformText;
if (widget.sttService != null) {
  platformText = await widget.sttService!.stopListening();
}
platformText ??= _platformText;
```

更新 `Navigator.pop()` 返回值，包含 platformText：

```dart
Navigator.of(context).pop(VoiceResult(
  action: action,
  filePath: action != VoiceResultAction.cancel ? _recordFilePath : null,
  platformText: action != VoiceResultAction.cancel ? platformText : null,
));
```

在 `_onPointerCancel()` 中也停止 PlatformStt：

```dart
void _onPointerCancel(PointerCancelEvent event) {
  _waveformTimer?.cancel();
  _audioRecorder.stop();
  widget.sttService?.cancel();  // 新增
  if (mounted) {
    Navigator.of(context)
        .pop(const VoiceResult(action: VoiceResultAction.cancel));
  }
}
```

添加 import：

```dart
import '../../../features/text_ai/data/services/platform_stt_service.dart';
```

- [ ] **Step 2: Update AiInputBar — add PlatformStt during recording**

在 `ai_input_bar.dart` 中：

更新 `AiInputBar` widget 增加 `PlatformSttService` 参数：

```dart
class AiInputBar extends StatefulWidget {
  final Function(String) onSubmit;
  final VoidCallback onManualEntry;
  final VoidCallback onCamera;
  final Function(VoiceEndAction action, String filePath, String? platformText)? onVoiceRecorded;
  final bool isLoading;
  final TextEditingController? controller;
  final PlatformSttService? sttService;  // 新增

  const AiInputBar({
    super.key,
    required this.onSubmit,
    required this.onManualEntry,
    required this.onCamera,
    this.onVoiceRecorded,
    this.isLoading = false,
    this.controller,
    this.sttService,  // 新增
  });
```

在 `_AiInputBarState` 中添加 `String? _platformText` 字段。

在 `_onVoiceStart()` 中，录音成功后启动 PlatformStt：

```dart
// 在 await _audioRecorder.start(...) 的 try 块末尾添加：
if (widget.sttService != null) {
  await widget.sttService!.startListening();
  widget.sttService!.partialTextStream.listen((text) {
    if (mounted) _platformText = text;
  });
}
```

在 `_onVoiceEnd()` 中，停止录音时停止 PlatformStt 并传递结果：

```dart
// 在 final path = await _audioRecorder.stop() 之后添加：
String? platformText;
if (widget.sttService != null) {
  platformText = await widget.sttService!.stopListening();
}
platformText ??= _platformText;
_platformText = null;
```

更新回调调用：

```dart
widget.onVoiceRecorded?.call(action, path, platformText);
```

添加 import：

```dart
import '../../../features/text_ai/data/services/platform_stt_service.dart';
```

- [ ] **Step 3: Update MainShell — use orchestrator**

在 `main_shell.dart` 中：

更新 `_handleVoiceResult` 使用 orchestrator：

```dart
Future<void> _handleVoiceResult(BuildContext context, VoiceResult result) async {
  if (result.action == VoiceResultAction.cancel) return;

  final provider = await ref.read(llmRepositoryProvider).getActiveProvider();
  if (!context.mounted) return;

  if (provider == null || !provider.isComplete) {
    AppToast.show(context, AppLocalizations.of(context)!.homePageAiNotConfigured);
    return;
  }

  final orchestrator = ref.read(voiceTranscriptionOrchestratorProvider);
  final pipeline = ref.read(transactionPipelineProvider);

  if (result.filePath == null) return;

  try {
    // 双引擎转写
    final transcription = await orchestrator.transcribe(
      audioPath: result.filePath!,
      platformText: result.platformText,
      provider: provider,
    );
    if (!context.mounted) return;

    if (result.action == VoiceResultAction.transcribe) {
      // 仅转文字
      context.go('/', extra: {'transcribedText': transcription.mergedText});
    } else {
      // 完整管线：传转写结果到首页处理
      context.go('/', extra: {'transcription': transcription});
    }
  } catch (e) {
    if (!context.mounted) return;
    AppToast.show(context, AppLocalizations.of(context)!.homePageRecordFailed(e.toString()));
  }
}
```

更新 `_FloatingRecordButton` 传递 `sttService`：

```dart
onLongPressStart: (_) async {
  final sttService = ref.read(platformSttServiceProvider);
  final result = await VoiceRecordingOverlay.show(context, sttService: sttService);
  // ...
},
```

需要将 `_FloatingRecordButton` 从 `StatelessWidget` 改为 `ConsumerWidget`，或在外层传入 `sttService`。更简单的做法：在 `_BottomBarWithFloatingButton` 中读取 provider 并传给按钮。

更新 import：

```dart
import '../../../config/di/ai_providers.dart';  // 已有，确保包含 orchestrator
```

- [ ] **Step 4: Update HomePage — use orchestrator + processVoiceResult**

在 `home_page.dart` 中：

更新 `_handleVoiceRecorded` 签名接收 platformText：

```dart
Future<void> _handleVoiceRecorded(VoiceEndAction action, String filePath, String? platformText) async {
```

重写方法体使用 orchestrator：

```dart
  Future<void> _handleVoiceRecorded(VoiceEndAction action, String filePath, String? platformText) async {
    final llmRepo = ref.read(llmRepositoryProvider);
    final provider = await llmRepo.getActiveProvider();
    if (!mounted) return;
    if (provider == null || !provider.isComplete) {
      _showSnackBar(AppLocalizations.of(context)!.homePageAiNotConfigured);
      return;
    }

    final orchestrator = ref.read(voiceTranscriptionOrchestratorProvider);
    final pipeline = ref.read(transactionPipelineProvider);

    try {
      setState(() => _isLoading = true);

      // 双引擎转写
      final transcription = await orchestrator.transcribe(
        audioPath: filePath,
        platformText: platformText,
        provider: provider,
      );
      if (!mounted) return;

      if (action == VoiceEndAction.transcribeOnly) {
        // 仅转文字，填入输入框
        _inputController.text = transcription.mergedText;
        _inputController.selection = TextSelection.fromPosition(
          TextPosition(offset: transcription.mergedText.length),
        );
      } else {
        // 完整管线：语音→转写→AI解析→确认卡片
        final categoryTaxonomy = await _buildCategoryTaxonomy();
        final result = await pipeline.processVoiceResult(
          transcription: transcription,
          categoryTaxonomy: categoryTaxonomy,
        );
        if (!mounted) return;

        if (result.transactions.isEmpty) {
          _showSnackBar(AppLocalizations.of(context)!.homePageNoContent);
          return;
        }

        final txn = result.transactions.first;
        final categories = await _categoryRepo.getAll();
        final matchedCategory = categories.firstWhere(
          (c) => c.name == txn.category,
          orElse: () => categories.firstWhere(
            (c) => c.isExpense == (txn.type == 'expense'),
            orElse: () => categories.first,
          ),
        );

        DateTime txnDate = DateTime.now();
        if (txn.date != null && txn.date!.isNotEmpty) {
          try { txnDate = DateTime.parse(txn.date!); } catch (_) {}
        }

        if (!mounted) return;
        await AiConfirmSheet.show(
          context,
          originalInput: result.normalizedText,
          amount: txn.amount,
          category: matchedCategory.name,
          description: txn.description.isNotEmpty
              ? txn.description
              : result.normalizedText.replaceAll(RegExp(r'\d+\.?\d*'), '').trim(),
          date: txnDate,
          confidence: txn.confidence,
          parseTimeMs: 0,
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: () async {
            Navigator.of(context).pop();
            await _saveTransaction(
              input: result.normalizedText,
              amount: txn.amount,
              type: txn.type,
              categoryId: matchedCategory.id,
              description: txn.description.isNotEmpty
                  ? txn.description
                  : result.normalizedText.replaceAll(RegExp(r'\d+\.?\d*'), '').trim(),
              date: txnDate,
              aiSource: txn.confidence > 0.85 ? 'llm' : 'rule',
              confidence: txn.confidence,
            );
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(AppLocalizations.of(context)!.homePageRecordFailed(
          resolveLlmError(e, AppLocalizations.of(context)!)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
```

同时更新 `_handleExternalInput()` 处理从浮动按钮传来的 `transcription` extra：

```dart
// 在 _handleExternalInput 中，现有 voicePath 处理改为：
final transcription = extra['transcription'] as DualTranscriptionResult?;
if (transcription != null) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _handleTranscriptionFromFloating(transcription);
  });
}
```

新增 `_handleTranscriptionFromFloating` 方法：

```dart
Future<void> _handleTranscriptionFromFloating(DualTranscriptionResult transcription) async {
  // 和 _handleVoiceRecorded 的 send 分支逻辑相同，直接用 transcription 调 processVoiceResult
  final pipeline = ref.read(transactionPipelineProvider);
  try {
    setState(() => _isLoading = true);
    final categoryTaxonomy = await _buildCategoryTaxonomy();
    final result = await pipeline.processVoiceResult(
      transcription: transcription,
      categoryTaxonomy: categoryTaxonomy,
    );
    // ... 后续确认卡片逻辑与 _handleVoiceRecorded 的 send 分支完全相同
  } catch (e) { ... } finally { ... }
}
```

添加 import：

```dart
import '../../../../core/ai/voice_transcription_orchestrator.dart';
```

- [ ] **Step 5: Update ChatInputBar — remove VoiceInputMode, add PlatformStt**

在 `chat_input_bar.dart` 中：

移除 `VoiceInputMode` 枚举定义（lines 12-18）。

更新 `ChatInputBar` widget：

```dart
class ChatInputBar extends StatefulWidget {
  final Function(String) onSubmit;
  final VoidCallback onManualEntry;
  final Function(String filePath, String? platformText) onVoiceRecorded;  // 改签名
  final Function(String filePath) onImageCaptured;
  final Function(String filePath, String? platformText) onVoiceTranscribeOnly;  // 改签名
  final bool isLoading;
  final PlatformSttService? sttService;  // 保留，但用途变化

  const ChatInputBar({
    super.key,
    required this.onSubmit,
    required this.onManualEntry,
    required this.onVoiceRecorded,
    required this.onImageCaptured,
    required this.onVoiceTranscribeOnly,
    this.isLoading = false,
    this.sttService,
  });
```

移除 `voiceMode` 属性。

在 `_ChatInputBarState` 中：

移除 Whisper 相关分支。`_handleSend()` 和 `_handleTranscribe()` 统一为录音 + PlatformStt：

```dart
  Future<void> _handleSend() async {
    // 停止 PlatformStt，获取文本
    String? platformText;
    if (widget.sttService != null) {
      platformText = await widget.sttService!.stopListening();
    }
    final result = (platformText ?? _partialText).trim();
    if (result.isNotEmpty) {
      widget.onSubmit(result);
    } else {
      if (mounted) AppToast.show(context, AppLocalizations.of(context)!.chatInputRecordShort);
    }
  }

  Future<void> _handleTranscribe() async {
    String? platformText;
    if (widget.sttService != null) {
      platformText = await widget.sttService!.stopListening();
    }
    final result = (platformText ?? _partialText).trim();
    if (result.isNotEmpty) {
      _controller.text = result;
      _focusNode.requestFocus();
    } else {
      if (mounted) AppToast.show(context, AppLocalizations.of(context)!.chatInputRecordShort);
    }
  }
```

注意：ChatInputBar 当前只用 PlatformStt 做实时文本，不录音。要实现双引擎需要它也录音。在 `_onLongPressStart` 中同时启动录音：

```dart
  void _onLongPressStart(LongPressStartDetails details) {
    HapticFeedback.heavyImpact();
    _gestureOrigin = details.globalPosition;
    setState(() {
      _isVoiceActive = true;
      _zone = _GestureZone.send;
      _partialText = '';
    });

    // 启动 PlatformStt 实时识别
    if (widget.sttService != null) {
      widget.sttService!.startListening();
      widget.sttService!.partialTextStream.listen((text) {
        if (mounted && _isVoiceActive) {
          setState(() => _partialText = text);
        }
      });
    }
  }
```

此处不录音——ChatInputBar 的双引擎录音由 AiChatPage 层面处理（通过 orchestrator）。ChatInputBar 仍然只负责 PlatformStt 实时文本显示和提交。

实际方案：ChatInputBar 在平台原生模式下的 `_handleSend()` 获取 PlatformStt 文本后，回调中传递文本，AiChatPage 接收后走 `processText()` 路径（不需要 orchestrator，因为没有音频文件）。

**最终简化方案**：ChatInputBar 保持使用 PlatformStt 实时文本，移除 VoiceInputMode 分支，始终可用。发送时提交文本到 `onSubmit`，和现在平台模式一样。

- [ ] **Step 6: Update AiChatPage — remove VoiceModeSetting, use orchestrator for voicePath**

在 `ai_chat_page.dart` 中：

移除 VoiceModeSetting 相关：

```dart
// 删除 import：
import '../../../settings/data/services/voice_mode_setting.dart';

// 删除字段：
VoiceInputMode _voiceMode = VoiceInputMode.platform;

// 删除方法：
Future<void> _loadVoiceMode() async { ... }

// 从 initState 中移除：
_loadVoiceMode();

// 从 onRefresh 中移除：
_loadVoiceMode();
```

更新 `_processInput()` 中的 `InputSource.voice` 分支使用 orchestrator：

```dart
case InputSource.voice:
  // 使用 orchestrator 进行双引擎转写
  final orchestrator = ref.read(voiceTranscriptionOrchestratorProvider);
  final provider = await ref.read(llmRepositoryProvider).getActiveProvider();
  if (!mounted) return;
  if (provider == null || !provider.isComplete) {
    throw LlmException(AppLocalizations.of(context)!.chatPageConfigAiError);
  }

  final transcription = await orchestrator.transcribe(
    audioPath: voicePath!,
    provider: provider,
  );
  if (!mounted) return;

  result = await _pipeline.processVoiceResult(
    transcription: transcription,
    categoryTaxonomy: categoryTaxonomy,
    locale: locale,
    bookId: _bookId,
  );
  if (!mounted) return;
  // 更新用户消息为转写文本
  await _chatRepo.insertMessage(
    ConversationMessagesCompanion.insert(
      conversationId: _conversationId,
      role: 'assistant',
      content: AppLocalizations.of(context)!.chatPageVoiceTranscription(result.normalizedText),
      accountBookId: _bookId,
    ),
  );
  setState(() {
    _items.add(_ChatItem.assistant(ConversationMessage(
      id: 0,
      conversationId: _conversationId,
      role: 'assistant',
      content: AppLocalizations.of(context)!.chatPageVoiceTranscription(result.normalizedText),
      accountBookId: _bookId,
      createdAt: DateTime.now(),
    )));
  });
  break;
```

更新 `_transcribeVoiceOnly()` 使用 orchestrator：

```dart
  Future<void> _transcribeVoiceOnly(String audioPath) async {
    if (_isAiResponding) return;
    setState(() => _isAiResponding = true);

    try {
      final provider = await ref.read(llmRepositoryProvider).getActiveProvider();
      if (!mounted) return;
      if (provider == null || !provider.isComplete) {
        throw LlmException(AppLocalizations.of(context)!.chatPageConfigAiError);
      }

      final orchestrator = ref.read(voiceTranscriptionOrchestratorProvider);
      final transcription = await orchestrator.transcribe(
        audioPath: audioPath,
        provider: provider,
      );
      if (!mounted) return;

      setState(() => _isAiResponding = false);

      await _chatRepo.insertMessage(
        ConversationMessagesCompanion.insert(
          conversationId: _conversationId,
          role: 'assistant',
          content: AppLocalizations.of(context)!.chatPageVoiceTranscription(transcription.mergedText),
          accountBookId: _bookId,
        ),
      );
      setState(() {
        _items.add(_ChatItem.assistant(ConversationMessage(
          id: 0,
          conversationId: _conversationId,
          role: 'assistant',
          content: AppLocalizations.of(context)!.chatPageVoiceTranscription(transcription.mergedText),
          accountBookId: _bookId,
          createdAt: DateTime.now(),
        )));
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAiResponding = false);
      final l10n = AppLocalizations.of(context)!;
      AppToast.show(context, l10n.chatPageParseError(resolveLlmError(e, l10n)));
    }
  }
```

更新 build 中的 ChatInputBar，移除 voiceMode：

```dart
ChatInputBar(
  onSubmit: (text) => _processInput(text: text),
  onVoiceRecorded: (path, platformText) => _processInput(voicePath: path),
  onImageCaptured: (path) => _processInput(imagePath: path),
  onVoiceTranscribeOnly: (path, platformText) => _transcribeVoiceOnly(path),
  isLoading: _isAiResponding,
  onManualEntry: () => context.push('/manual-entry'),
  sttService: ref.read(platformSttServiceProvider),
),
```

添加 import：

```dart
import '../../../../core/ai/voice_transcription_orchestrator.dart';
```

- [ ] **Step 7: Verify compilation**

Run: `flutter build apk --debug`
Expected: BUILD SUCCESSFUL

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "refactor(voice): unify all entry points to dual-engine voice transcription

- VoiceRecordingOverlay: add PlatformStt during recording
- AiInputBar: add PlatformStt support, pass platformText in callback
- MainShell: use VoiceTranscriptionOrchestrator for voice processing
- HomePage: use orchestrator + processVoiceResult
- ChatInputBar: remove VoiceInputMode branching, always use PlatformStt
- AiChatPage: use orchestrator for voice path, remove VoiceModeSetting
- TransactionPipeline: add processVoiceResult with cross-validation prompt
- Remove VoiceModeSetting, VoiceInputMode enum, SttMode enum
- Remove voice mode toggle from settings page"
```

---

### Task 4: Manual Verification + Push

**Files:** None (verification only)

- [ ] **Step 1: Run on real device**

```bash
flutter run
```

手动验证以下场景：

| 场景 | 预期 |
|------|------|
| 首页长按录音 → 发送 | 双引擎转写 → LLM 交叉校验 → 确认卡片 |
| 首页长按录音 → 右滑转文字 | 双引擎合并文本填入输入框 |
| 浮动按钮长按 → 发送 | 同上，通过 orchestrator |
| 浮动按钮长按 → 转文字 | 同上 |
| 聊天页长按 → 发送 | PlatformStt 实时文本 → onSubmit → processText |
| 设置页 | 无语音模式切换卡片 |
| 未配置 Whisper 时录音 | 自动降级为 Platform STT |

- [ ] **Step 2: Push**

```bash
git push
```
