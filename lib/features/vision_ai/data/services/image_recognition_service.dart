import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../ai/data/models/llm_config.dart';
import '../../../../core/config/ai_provider_presets.dart';

/// 图片识别服务
///
/// 将图片发送到视觉模型进行小票/发票/收据识别。
/// 兼容 OpenAI Vision API 格式：POST {baseUrl}/chat/completions
/// 使用多模态 messages 格式传入 base64 编码的图片。
class ImageRecognitionService {
  final Dio _dio;

  ImageRecognitionService(this._dio);

  /// 识别图片中的消费信息
  ///
  /// [provider] 当前激活的 LLM 服务商配置
  /// [imagePath] 本地图片文件路径
  /// [customPrompt] 自定义提示词（可选，默认使用小票识别提示）
  /// 返回识别后的文本描述
  Future<String> recognize(
    LlmProvider provider,
    String imagePath, {
    String? customPrompt,
    String? modelName,
  }) async {
    final model = modelName ?? provider.getModelForCapability(ModelCapability.vision);
    if (model == null || model.isEmpty) {
      throw const LlmException('未配置视觉识别模型，请在 AI 设置中配置', errorCode: 'visionErrorNoModelConfigured');
    }

    final file = File(imagePath);
    if (!file.existsSync()) {
      throw const LlmException('图片文件不存在', errorCode: 'visionErrorImageNotFound');
    }

    final imageBytes = await file.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    // 判断图片 MIME 类型
    final ext = imagePath.toLowerCase().split('.').last;
    final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

    final prompt = customPrompt ?? _defaultReceiptPrompt;

    try {
      final preset = getPresetByKey(provider.providerKey);
      final isAnthropic = preset?.apiFormat == ApiFormat.anthropic;

      if (isAnthropic) {
        return await _recognizeAnthropic(provider, model, base64Image, mimeType, prompt);
      } else {
        return await _recognizeOpenAI(provider, model, base64Image, mimeType, prompt);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const LlmException('API Key 无效', errorCode: 'llmErrorInvalidApiKey');
      }
      throw LlmException('图片识别失败: ${e.message}', errorCode: 'visionErrorRecognitionFailed');
    }
  }

  /// OpenAI Vision API 格式识别
  Future<String> _recognizeOpenAI(
    LlmProvider provider,
    String model,
    String base64Image,
    String mimeType,
    String prompt,
  ) async {
    final response = await _dio.post(
      '${provider.baseUrl}/chat/completions',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${provider.apiKey}',
          'Content-Type': 'application/json',
        },
        sendTimeout: Duration(seconds: provider.timeoutSeconds),
        receiveTimeout: Duration(seconds: provider.timeoutSeconds),
      ),
      data: {
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': [
              {'type': 'text', 'text': prompt},
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:$mimeType;base64,$base64Image',
                },
              },
            ],
          },
        ],
        'max_tokens': 2000,
      },
    );

    final data = response.data as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>;
    return (choices[0] as Map<String, dynamic>)['message']['content'] as String;
  }

  /// Anthropic Vision API 格式识别
  Future<String> _recognizeAnthropic(
    LlmProvider provider,
    String model,
    String base64Image,
    String mimeType,
    String prompt,
  ) async {
    final response = await _dio.post(
      '${provider.baseUrl}/messages',
      options: Options(
        headers: {
          'x-api-key': provider.apiKey,
          'anthropic-version': '2023-06-01',
          'Content-Type': 'application/json',
        },
        sendTimeout: Duration(seconds: provider.timeoutSeconds),
        receiveTimeout: Duration(seconds: provider.timeoutSeconds),
      ),
      data: {
        'model': model,
        'max_tokens': 2000,
        'messages': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'image',
                'source': {
                  'type': 'base64',
                  'media_type': mimeType,
                  'data': base64Image,
                },
              },
              {'type': 'text', 'text': prompt},
            ],
          },
        ],
      },
    );

    final data = response.data as Map<String, dynamic>;
    final content = data['content'] as List<dynamic>;
    return (content[0] as Map<String, dynamic>)['text'] as String;
  }

  static const _defaultReceiptPrompt = '''
请识别这张图片中的消费信息。这可能是小票、发票、收据、外卖订单截图或转账记录。

请以纯文本形式描述以下信息：
1. 消费金额
2. 商家/来源名称
3. 消费项目/商品描述
4. 消费日期（如果图中可见）
5. 消费类型（餐饮/交通/购物/娱乐等）

如果是小票/发票，请列出每项商品及价格。
如果无法识别，请描述图片中可见的文字内容。
''';
}
