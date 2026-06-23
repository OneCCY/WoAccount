# Per-Capability Provider + URL Auto-Detection Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Each capability (text/vision/audio) independently selects a provider (baseUrl + apiKey). Whisper API URL auto-detection fixes 404 errors.

**Architecture:** Add `providerId` to `ModelConfig`. Add `resolveProviderForCapability()` to `LlmConfigManager`. Orchestrator and Pipeline resolve providers internally. `VoiceRecognitionService` tries multiple URL paths on 404.

**Tech Stack:** Flutter, Riverpod, SharedPreferences, Dio

**Spec:** `docs/superpowers/specs/2026-06-23-per-capability-provider-design.md`

## Global Constraints

- All UI text uses AppLocalizations (L10n), no hardcoded user-visible strings
- Conventional Commits: `feat(scope): ...` / `refactor(scope): ...`
- Each Task must pass `flutter build apk --debug`
- Old data compatible (ModelConfig.providerId nullable, falls back to active provider)

---

## File Map

| Action | File | Responsibility |
|--------|------|---------------|
| **Modify** | `lib/features/ai/data/models/llm_config.dart` | ModelConfig + providerId; resolveProviderForCapability |
| **Modify** | `lib/features/text_ai/data/services/voice_recognition_service.dart` | URL auto-detection |
| **Modify** | `lib/core/ai/llm_error_resolver.dart` | Add voiceErrorEndpointNotFound |
| **Modify** | `lib/core/ai/voice_transcription_orchestrator.dart` | Resolve audio provider internally |
| **Modify** | `lib/core/ai/transaction_pipeline.dart` | Resolve text provider internally |
| **Modify** | `lib/features/home/presentation/pages/home_page.dart` | Remove manual getActiveProvider |
| **Modify** | `lib/core/widgets/navigation/main_shell.dart` | Same |
| **Modify** | `lib/features/chat/presentation/pages/ai_chat_page.dart` | Same |
| **Modify** | `lib/features/settings/presentation/pages/llm_settings_page.dart` | UI: per-capability provider selector |
| **Modify** | `lib/l10n/app_*.arb` (5 files) | New L10n keys |

---

### Task 1: Data Model — ModelConfig.providerId + Resolve Functions

**Files:**
- Modify: `lib/features/ai/data/models/llm_config.dart:76-85, 280-290`

**Interfaces:**
- Consumes: existing `ModelConfig`, `LlmProvider`, `LlmConfigManager`
- Produces: `ModelConfig.providerId` (String?), `LlmConfigManager.resolveProviderForCapability(ModelCapability)`, `LlmConfigManager.resolveCapabilityConfig(ModelCapability)`

- [ ] **Step 1: Update ModelConfig**

Replace lines 76-85 in `llm_config.dart`:

```dart
class ModelConfig {
  final String modelName;
  final String? providerId;

  const ModelConfig({required this.modelName, this.providerId});

  Map<String, dynamic> toJson() => {
        'modelName': modelName,
        if (providerId != null) 'providerId': providerId,
      };

  factory ModelConfig.fromJson(Map<String, dynamic> json) => ModelConfig(
        modelName: json['modelName'] as String? ?? '',
        providerId: json['providerId'] as String?,
      );
}
```

- [ ] **Step 2: Add resolve methods to LlmConfigManager**

After `deleteProvider()` (line ~289), add:

```dart
/// Resolve the provider for a given capability.
///
/// Priority: ModelConfig.providerId > active provider (fallback for old data).
static Future<LlmProvider?> resolveProviderForCapability(
  ModelCapability capability,
) async {
  final providers = await loadProviders();
  for (final p in providers) {
    final model = p.models[capability.name];
    if (model != null && model.providerId != null && model.modelName.isNotEmpty) {
      final target = providers.where((x) => x.id == model.providerId).firstOrNull;
      if (target != null && target.isComplete) return target;
    }
  }
  return await getActiveProvider();
}

/// Resolve the provider and model name for a capability.
static Future<(LlmProvider?, String?)> resolveCapabilityConfig(
  ModelCapability capability,
) async {
  final providers = await loadProviders();
  for (final p in providers) {
    final model = p.models[capability.name];
    if (model != null && model.providerId != null && model.modelName.isNotEmpty) {
      final target = providers.where((x) => x.id == model.providerId).firstOrNull;
      if (target != null && target.isComplete) {
        return (target, model.modelName);
      }
    }
  }
  final active = await getActiveProvider();
  final modelName = active?.getModelForCapability(capability);
  return (active, modelName);
}
```

- [ ] **Step 3: Verify compilation**

Run: `flutter build apk --debug`
Expected: BUILD SUCCESSFUL

- [ ] **Step 4: Commit**

```bash
git add lib/features/ai/data/models/llm_config.dart
git commit -m "feat(config): add providerId to ModelConfig and resolveProviderForCapability"
```

---

### Task 2: VoiceRecognitionService — URL Auto-Detection

**Files:**
- Modify: `lib/features/text_ai/data/services/voice_recognition_service.dart:35-74`
- Modify: `lib/core/ai/llm_error_resolver.dart:62-63`
- Modify: `lib/l10n/app_en.arb`, `app_zh.arb`, `app_ja.arb`, `app_ko.arb`, `app_zh_TW.arb`

**Interfaces:**
- Consumes: existing `VoiceRecognitionService`, `Dio`, `LlmException`
- Produces: `_buildCandidateUrls()`, updated `transcribe()` with 404 fallback, `voiceErrorEndpointNotFound` L10n key

- [ ] **Step 1: Rewrite transcribe() and add _buildCandidateUrls()**

Replace the entire `transcribe()` method and add the helper in `voice_recognition_service.dart`:

```dart
  /// Build candidate URL list (auto-detect correct API path)
  List<String> _buildCandidateUrls(String baseUrl) {
    if (baseUrl.endsWith('/v1')) {
      return ['$baseUrl/audio/transcriptions'];
    }
    return [
      '$baseUrl/audio/transcriptions',
      '$baseUrl/v1/audio/transcriptions',
    ];
  }

  Future<String> transcribe(
    LlmProvider provider,
    String audioFilePath, {
    String language = 'zh',
  }) async {
    final model = provider.getModelForCapability(ModelCapability.audio);
    if (model == null || model.isEmpty) {
      throw const LlmException('未配置语音识别模型，请在 AI 设置中配置',
          errorCode: 'voiceErrorNoModelConfigured');
    }

    final file = File(audioFilePath);
    if (!file.existsSync()) {
      throw const LlmException('音频文件不存在',
          errorCode: 'voiceErrorAudioNotFound');
    }

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(audioFilePath, filename: 'recording.m4a'),
      'model': model,
      'language': language,
    });

    final urls = _buildCandidateUrls(provider.baseUrl);

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
        if (e.response?.statusCode == 404) continue;
        if (e.response?.statusCode == 401) {
          throw const LlmException('API Key 无效',
              errorCode: 'llmErrorInvalidApiKey');
        }
        throw LlmException('语音识别失败: ${e.message}',
            errorCode: 'voiceErrorTranscriptionFailed');
      }
    }

    throw LlmException(
      'Whisper API endpoint not found (tried: ${urls.join(", ")})',
      errorCode: 'voiceErrorEndpointNotFound',
    );
  }
```

- [ ] **Step 2: Add L10n key voiceErrorEndpointNotFound**

Add after `voiceErrorTranscriptionFailed` in each ARB file:

app_zh.arb: `"voiceErrorEndpointNotFound": "Whisper API 端点未找到，请检查供应商 Base URL 配置",`
app_en.arb: `"voiceErrorEndpointNotFound": "Whisper API endpoint not found. Please check supplier Base URL",`
app_ja.arb: `"voiceErrorEndpointNotFound": "Whisper APIエンドポイントが見つかりません。サプライヤーのBase URLを確認してください",`
app_ko.arb: `"voiceErrorEndpointNotFound": "Whisper API 엔드포인트를 찾을 수 없습니다. 공급자의 Base URL을 확인해 주세요",`
app_zh_TW.arb: `"voiceErrorEndpointNotFound": "Whisper API 端點未找到，請檢查供應商 Base URL 配置",`

Add in `llm_error_resolver.dart` voice errors section:
```dart
    case 'voiceErrorEndpointNotFound':
      return l10n.voiceErrorEndpointNotFound;
```

Run: `flutter gen-l10n`

- [ ] **Step 3: Verify compilation**

Run: `flutter build apk --debug`
Expected: BUILD SUCCESSFUL

- [ ] **Step 4: Commit**

```bash
git add lib/features/text_ai/data/services/voice_recognition_service.dart \
        lib/core/ai/llm_error_resolver.dart lib/l10n/app_*.arb lib/l10n/app_localizations*.dart
git commit -m "feat(voice): auto-detect Whisper API URL and add endpoint-not-found error"
```

---

### Task 3: Orchestrator & Pipeline — Internal Provider Resolution

**Files:**
- Modify: `lib/core/ai/voice_transcription_orchestrator.dart`
- Modify: `lib/core/ai/transaction_pipeline.dart`
- Modify: `lib/features/home/presentation/pages/home_page.dart`
- Modify: `lib/core/widgets/navigation/main_shell.dart`
- Modify: `lib/features/chat/presentation/pages/ai_chat_page.dart`

**Interfaces:**
- Consumes: `LlmConfigManager.resolveProviderForCapability()` (from Task 1)
- Produces: Simplified APIs:
  - `orchestrator.transcribe(audioPath, platformText)` — no provider param
  - `pipeline.processText(text, ...)` — no provider param (internal resolution)
  - `pipeline.processVoiceResult(transcription, ...)` — no provider param

- [ ] **Step 1: Update VoiceTranscriptionOrchestrator — remove provider param**

In `voice_transcription_orchestrator.dart`, update `transcribe()`:

Remove `required LlmProvider provider` parameter. Add internal resolution at the top of the method.

```dart
Future<DualTranscriptionResult> transcribe({
  required String audioPath,
  String? platformText,
}) async {
  // Resolve audio provider internally
  final provider = await LlmConfigManager.resolveProviderForCapability(
    ModelCapability.audio,
  );

  // 1. Save audio
  String? savedPath;
  try {
    savedPath = await _mediaStorage.saveAudio(audioPath);
  } catch (_) {}

  // 2. Check engine availability
  final hasPlatform = platformText != null && platformText.trim().isNotEmpty;
  final hasWhisper = provider != null && provider.isComplete &&
      provider.getModelForCapability(ModelCapability.audio) != null;

  if (!hasPlatform && !hasWhisper) {
    throw const LlmException(
      'No voice recognition engine available',
      errorCode: 'voiceErrorNoEngineAvailable',
    );
  }

  // 3. Platform only
  if (hasPlatform && !hasWhisper) {
    return DualTranscriptionResult(platformText: platformText, audioPath: savedPath);
  }

  // 4. Whisper (single or dual engine)
  String? whisperText;
  try {
    whisperText = await _whisperService.transcribe(provider!, savedPath ?? audioPath);
  } catch (e) {
    if (hasPlatform) {
      return DualTranscriptionResult(platformText: platformText, audioPath: savedPath);
    }
    rethrow;
  }

  return DualTranscriptionResult(
    platformText: hasPlatform ? platformText : null,
    whisperText: whisperText,
    audioPath: savedPath,
  );
}
```

Add import: `import '../../features/ai/data/models/llm_config.dart';`

- [ ] **Step 2: Update TransactionPipeline — internal provider resolution**

In `transaction_pipeline.dart`, update `processText()`:

Add internal provider resolution before `_llmRepo.parseTransaction()`:

```dart
Future<PipelineResult> processText(
  String text, {
  String? categoryTaxonomy,
  String locale = 'zh',
  int? bookId,
}) async {
  final resolvedText = await _resolveReference(text, bookId);
  final context = await _buildEnrichedContext(resolvedText, bookId);

  // Resolve text provider internally
  final provider = await LlmConfigManager.resolveProviderForCapability(
    ModelCapability.text,
  );

  final results = await _llmRepo.parseTransaction(
    resolvedText,
    provider: provider,
    categoryTaxonomy: categoryTaxonomy,
    locale: locale,
    fewShotExamples: context.fewShotExamples,
    similarTransactions: context.similarTransactions,
  );
  return PipelineResult(
    normalizedText: text,
    transactions: results,
    source: InputSource.text,
  );
}
```

Same for `processVoiceResult()` — add provider resolution before `_llmRepo.parseTransaction()`.

Check if `LlmRepositoryImpl.parseTransaction()` accepts a `provider` parameter. If not, add it.

Add import: `import '../../features/ai/data/models/llm_config.dart';`

- [ ] **Step 3: Update HomePage — remove manual provider check**

In `home_page.dart`, simplify `_handleVoiceRecorded()`:

Remove the `getActiveProvider()` check at the top. Let the orchestrator/pipeline handle provider resolution. Wrap the call in try-catch for error display:

```dart
Future<void> _handleVoiceRecorded(VoiceEndAction action, String filePath, String? platformText) async {
  final orchestrator = ref.read(voiceTranscriptionOrchestratorProvider);
  final pipeline = ref.read(transactionPipelineProvider);

  try {
    setState(() => _isLoading = true);

    final transcription = await orchestrator.transcribe(
      audioPath: filePath,
      platformText: platformText,
    );
    if (!mounted) return;

    if (action == VoiceEndAction.transcribeOnly) {
      _inputController.text = transcription.mergedText;
      _inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: transcription.mergedText.length),
      );
    } else {
      final categoryTaxonomy = await _buildCategoryTaxonomy();
      final result = await pipeline.processVoiceResult(
        transcription: transcription,
        categoryTaxonomy: categoryTaxonomy,
      );
      if (!mounted) return;
      await _showConfirmForResult(result);
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

Also simplify `_handleAiInput()` similarly — remove manual provider check.

- [ ] **Step 4: Update MainShell — remove manual provider check**

In `main_shell.dart`, simplify `_handleVoiceResult()`:

```dart
Future<void> _handleVoiceResult(BuildContext context, VoiceResult result) async {
  if (result.action == VoiceResultAction.cancel) return;
  if (result.filePath == null) return;

  final orchestrator = ref.read(voiceTranscriptionOrchestratorProvider);

  try {
    final transcription = await orchestrator.transcribe(
      audioPath: result.filePath!,
      platformText: result.platformText,
    );
    if (!context.mounted) return;

    if (result.action == VoiceResultAction.transcribe) {
      context.go('/', extra: {'transcribedText': transcription.mergedText});
    } else {
      context.go('/', extra: {'transcription': transcription});
    }
  } catch (e) {
    if (!context.mounted) return;
    AppToast.show(context, AppLocalizations.of(context)!.homePageRecordFailed(e.toString()));
  }
}
```

Remove the `getActiveProvider()` call and `provider == null` check.

- [ ] **Step 5: Update AiChatPage — remove manual provider check**

In `ai_chat_page.dart`:

Update `_processInput()` to remove the `getActiveProvider()` check for voice/image sources. Let the pipeline/orchestrator resolve internally.

Remove the `provider` parameter from `_pipeline.processVoiceResult()` and `_pipeline.processImage()` calls if they accept it.

Remove the import of `voice_transcription_orchestrator.dart` if no longer needed (the pipeline handles it).

- [ ] **Step 6: Update LlmRepositoryImpl if needed**

Check if `parseTransaction()` currently gets provider from `getActiveProvider()` internally. If so, add an optional `provider` parameter:

```dart
Future<List<TransactionParseResult>> parseTransaction(
  String input, {
  LlmProvider? provider,  // NEW: if null, resolve internally
  String? categoryTaxonomy,
  String locale = 'zh',
  String? fewShotExamples,
  String? similarTransactions,
}) async {
  provider ??= await LlmConfigManager.resolveProviderForCapability(ModelCapability.text);
  if (provider == null || !provider.isComplete) {
    throw const LlmException('No provider configured', errorCode: 'llmErrorNoProviderOrInput');
  }
  // ... rest of existing logic
}
```

- [ ] **Step 7: Verify compilation**

Run: `flutter build apk --debug`
Expected: BUILD SUCCESSFUL

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "refactor(ai): resolve providers per-capability internally in orchestrator and pipeline"
```

---

### Task 4: UI — Per-Capability Provider Selector

**Files:**
- Modify: `lib/features/settings/presentation/pages/llm_settings_page.dart`

**Interfaces:**
- Consumes: `LlmConfigManager.resolveCapabilityConfig()` (from Task 1), `ModelConfig.providerId` (from Task 1)
- Produces: Updated model management page showing provider name per capability

- [ ] **Step 1: Update _ModelManagementPage to show provider name**

In the `_ModelManagementPage`, update each capability card to show the provider name:

Read the current `_buildCapabilityCard` method. Update it to use `resolveCapabilityConfig()`:

```dart
Widget _buildCapabilityCard(ModelCapability cap, AppLocalizations l10n) {
  return FutureBuilder<(LlmProvider?, String?)>(
    future: LlmConfigManager.resolveCapabilityConfig(cap),
    builder: (context, snapshot) {
      final (provider, modelName) = snapshot.data ?? (null, null);
      final providerName = provider?.name ?? '';
      final hasConfig = modelName != null && modelName.isNotEmpty;

      String subtitle;
      if (hasConfig && providerName.isNotEmpty) {
        subtitle = '$providerName · $modelName';
      } else if (hasConfig) {
        subtitle = modelName!;
      } else {
        subtitle = l10n.settingsModelNotConfigured; // or similar
      }

      return ListTile(
        leading: Icon(cap.icon),
        title: Text(cap.label),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => _CapabilityConfigPage(capability: cap),
        )),
      );
    },
  );
}
```

- [ ] **Step 2: Update _CapabilityConfigPage — add provider selector**

In `_CapabilityConfigPage`, add a provider selection step before model selection:

1. Show a list of configured providers (those with apiKey + baseUrl set)
2. When user selects a provider, fetch model list from that provider's API
3. When user selects a model, save `ModelConfig(modelName: model, providerId: selectedProvider.id)`
4. Clean up old provider's capability config

Update `_selectModel()`:

```dart
Future<void> _selectModel(LlmProvider selectedProvider, String? model) async {
  if (model == null) return;

  final providers = await LlmConfigManager.loadProviders();

  // 1. Update selected provider's model config (with providerId)
  final newModels = Map<String, ModelConfig>.from(selectedProvider.models);
  newModels[widget.capability.name] = ModelConfig(
    modelName: model,
    providerId: selectedProvider.id,
  );
  await LlmConfigManager.updateProvider(
    selectedProvider.copyWith(models: newModels),
  );

  // 2. Clean up old provider's capability config
  for (final p in providers) {
    if (p.id == selectedProvider.id) continue;
    if (p.models.containsKey(widget.capability.name)) {
      final cleaned = Map<String, ModelConfig>.from(p.models);
      cleaned.remove(widget.capability.name);
      await LlmConfigManager.updateProvider(p.copyWith(models: cleaned));
    }
  }

  // 3. Refresh UI
  if (mounted) setState(() {});
}
```

- [ ] **Step 3: Verify compilation and test UI**

Run: `flutter build apk --debug`
Expected: BUILD SUCCESSFUL

- [ ] **Step 4: Commit**

```bash
git add lib/features/settings/presentation/pages/llm_settings_page.dart
git commit -m "feat(settings): per-capability provider selector in model management UI"
```

---

### Task 5: Deploy and Verify

**Files:** None (verification only)

- [ ] **Step 1: Deploy to real device**

```bash
flutter run -d a485ea70
```

- [ ] **Step 2: Verify**

| Scenario | Expected |
|----------|----------|
| Model management page | Each capability shows "Provider · Model" |
| Configure audio with different provider than text | Both configs preserved |
| Switch audio provider | Text provider unaffected |
| Voice transcription with correct baseUrl | Success |
| Voice transcription with missing /v1 | Auto-detects correct path |
| Voice transcription with wrong URL | Clear error message |
| Old data (no providerId) | Falls back to active provider |

- [ ] **Step 3: Push**

```bash
git push
```
