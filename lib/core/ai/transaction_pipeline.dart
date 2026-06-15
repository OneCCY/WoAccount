import '../../features/ai/data/models/llm_config.dart';
import '../../features/text_ai/data/services/voice_recognition_service.dart';
import '../../features/vision_ai/data/services/image_recognition_service.dart';
import '../../features/ai/domain/repositories/llm_repository.dart';
import '../media/media_storage_service.dart';
import 'package:wo_account/l10n/app_localizations.dart';

/// 输入源类型
enum InputSource {
  text('文本', '📝'),
  voice('语音', '🎤'),
  image('图片', '📷');

  final String label;
  final String emoji;
  const InputSource(this.label, this.emoji);

  /// Returns the localized label for this input source.
  String getLocalizedLabel(AppLocalizations l10n) {
    switch (this) {
      case InputSource.text:
        return l10n.inputSourceText;
      case InputSource.voice:
        return l10n.inputSourceVoice;
      case InputSource.image:
        return l10n.inputSourceImage;
    }
  }
}

/// 统一记账管线结果
class PipelineResult {
  /// 归一化后的文本（语音转写文本 / 图片识别文本 / 原始文本）
  final String normalizedText;

  /// AI 解析出的交易列表
  final List<TransactionParseResult> transactions;

  /// 输入来源
  final InputSource source;

  /// 保存后的媒体文件路径（语音/图片输入时有值）
  final String? mediaFilePath;

  const PipelineResult({
    required this.normalizedText,
    required this.transactions,
    required this.source,
    this.mediaFilePath,
  });
}

/// 统一记账管线
///
/// 所有输入（文本/语音/图片）都通过此管线处理：
/// 1. 语音 → 录制音频 → 语音模型转文字 → AI 记账解析
/// 2. 图片 → 拍照/选图 → 视觉模型识别 → AI 记账解析
/// 3. 文本 → 直接 AI 记账解析
///
/// 最终统一产出 PipelineResult（包含 TransactionParseResult 列表）。
class TransactionPipeline {
  final LlmRepository _llmRepo;
  final VoiceRecognitionService _voiceService;
  final ImageRecognitionService _imageService;
  final MediaStorageService _mediaStorage;

  TransactionPipeline({
    required this._llmRepo,
    required this._voiceService,
    required this._imageService,
    required this._mediaStorage,
  });

  /// 处理文本输入
  Future<PipelineResult> processText(String text, {String? categoryTaxonomy}) async {
    final results = await _llmRepo.parseTransaction(text, categoryTaxonomy: categoryTaxonomy);
    return PipelineResult(
      normalizedText: text,
      transactions: results,
      source: InputSource.text,
    );
  }

  /// 仅语音转文字（不走 LLM 解析）
  ///
  /// 用于首页右滑转文字场景：用户录音后仅转写文本，填入输入框由用户编辑后发送。
  Future<String> transcribeOnly({
    required String audioTempPath,
    required LlmProvider provider,
  }) async {
    // 保存音频到永久存储
    final savedPath = await _mediaStorage.saveAudio(audioTempPath);

    // 语音转文字
    final text = await _voiceService.transcribe(provider, savedPath);

    if (text.trim().isEmpty) {
      throw const LlmException('语音识别结果为空，请重新录制', errorCode: 'pipelineErrorEmptyVoiceResult');
    }

    return text;
  }

  /// 处理语音输入
  ///
  /// [audioTempPath] 录音临时文件路径
  /// [provider] 当前 LLM 服务商配置
  Future<PipelineResult> processVoice({
    required String audioTempPath,
    required LlmProvider provider,
    String? categoryTaxonomy,
  }) async {
    // 1. 保存音频到永久存储
    final savedPath = await _mediaStorage.saveAudio(audioTempPath);

    // 2. 语音转文字
    final transcribedText = await _voiceService.transcribe(provider, savedPath);

    if (transcribedText.trim().isEmpty) {
      throw const LlmException('语音识别结果为空，请重新录制', errorCode: 'pipelineErrorEmptyVoiceResult');
    }

    // 3. 用转写文本走 AI 记账解析
    final results = await _llmRepo.parseTransaction(transcribedText, categoryTaxonomy: categoryTaxonomy);

    return PipelineResult(
      normalizedText: transcribedText,
      transactions: results,
      source: InputSource.voice,
      mediaFilePath: savedPath,
    );
  }

  /// 处理图片输入
  ///
  /// [imageTempPath] 图片临时文件路径
  /// [provider] 当前 LLM 服务商配置
  Future<PipelineResult> processImage({
    required String imageTempPath,
    required LlmProvider provider,
    String? categoryTaxonomy,
  }) async {
    // 1. 保存图片到永久存储
    final savedPath = await _mediaStorage.saveImageFile(imageTempPath);

    // 2. 视觉模型识别图片内容
    final recognizedText = await _imageService.recognize(
      provider,
      savedPath,
    );

    if (recognizedText.trim().isEmpty) {
      throw const LlmException('图片识别结果为空，请选择更清晰的图片', errorCode: 'pipelineErrorEmptyImageResult');
    }

    // 3. 用识别文本走 AI 记账解析
    final results = await _llmRepo.parseTransaction(recognizedText, categoryTaxonomy: categoryTaxonomy);

    return PipelineResult(
      normalizedText: recognizedText,
      transactions: results,
      source: InputSource.image,
      mediaFilePath: savedPath,
    );
  }
}
