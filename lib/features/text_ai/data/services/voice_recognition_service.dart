import 'dart:io';
import 'package:dio/dio.dart';
import '../../../ai/data/models/llm_config.dart';

/// 语音识别服务
///
/// 将音频文件发送到 AI 模型进行语音转文字。
/// 兼容 OpenAI Whisper API 格式：POST {baseUrl}/audio/transcriptions
class VoiceRecognitionService {
  final Dio _dio;

  VoiceRecognitionService(this._dio);

  /// 将音频文件转录为文本
  ///
  /// [provider] 当前激活的 LLM 服务商配置
  /// [audioFilePath] 本地音频文件路径
  /// [language] 语言代码（默认 'zh' 中文）
  /// 返回识别后的文本
  Future<String> transcribe(
    LlmProvider provider,
    String audioFilePath, {
    String language = 'zh',
  }) async {
    final model = provider.getModelForCapability(ModelCapability.audio);
    if (model == null || model.isEmpty) {
      throw const LlmException('未配置语音识别模型，请在 AI 设置中配置');
    }

    final file = File(audioFilePath);
    if (!file.existsSync()) {
      throw const LlmException('音频文件不存在');
    }

    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          audioFilePath,
          filename: 'recording.m4a',
        ),
        'model': model,
        'language': language,
      });

      final response = await _dio.post(
        '${provider.baseUrl}/audio/transcriptions',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${provider.apiKey}',
          },
          sendTimeout: Duration(seconds: provider.timeoutSeconds),
          receiveTimeout: Duration(seconds: provider.timeoutSeconds),
        ),
      );

      final data = response.data;

      // OpenAI Whisper 标准响应: { "text": "..." }
      if (data is Map<String, dynamic> && data.containsKey('text')) {
        return data['text'] as String;
      }

      // 兼容直接返回纯文本的情况
      if (data is String) return data;

      throw const LlmException('语音识别返回格式异常');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const LlmException('API Key 无效');
      }
      throw LlmException('语音识别失败: ${e.message}');
    }
  }
}
