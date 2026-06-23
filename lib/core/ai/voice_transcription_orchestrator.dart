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
        'No voice recognition engine available',
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
