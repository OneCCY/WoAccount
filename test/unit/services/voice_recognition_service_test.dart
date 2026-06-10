import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wo_account/features/ai/data/models/llm_config.dart';
import 'package:wo_account/features/text_ai/data/services/voice_recognition_service.dart';

void main() {
  group('VoiceRecognitionService', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('voice_test_');
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        try {
          await tempDir.delete(recursive: true);
        } catch (_) {
          // Windows 可能因文件句柄未释放而无法删除，忽略
        }
      }
    });

    Future<File> createTempAudio(String name) async {
      final file = File('${tempDir.path}/$name');
      await file.writeAsBytes([0, 1, 2, 3, 4]);
      return file;
    }

    LlmProvider makeProvider({String? audioModel}) {
      final models = <String, ModelConfig>{};
      if (audioModel != null) {
        models['audio'] = ModelConfig(modelName: audioModel);
      }
      return LlmProvider(
        id: 'test',
        name: 'Test Provider',
        apiKey: 'test-key',
        baseUrl: 'https://api.example.com/v1',
        models: models,
      );
    }

    Dio makeDio({required int statusCode, dynamic responseData, String contentType = 'application/json'}) {
      final dio = Dio();
      dio.httpClientAdapter = _MockAdapter(
        statusCode: statusCode,
        responseData: responseData,
        contentType: contentType,
      );
      return dio;
    }

    test('音频模型未配置时应抛出 LlmException', () async {
      final service = VoiceRecognitionService(Dio());
      final provider = makeProvider(audioModel: null);
      final audioFile = await createTempAudio('test.m4a');

      expect(
        () => service.transcribe(provider, audioFile.path),
        throwsA(isA<LlmException>()),
      );
    });

    test('音频文件不存在时应抛出 LlmException', () async {
      final service = VoiceRecognitionService(Dio());
      final provider = makeProvider(audioModel: 'whisper-1');

      expect(
        () => service.transcribe(provider, '/nonexistent/path/audio.m4a'),
        throwsA(isA<LlmException>()),
      );
    });

    test('正常转录应返回文本', () async {
      final dio = makeDio(
        statusCode: 200,
        responseData: jsonEncode({'text': '午饭拉面25元'}),
      );

      final service = VoiceRecognitionService(dio);
      final provider = makeProvider(audioModel: 'whisper-1');
      final audioFile = await createTempAudio('test.m4a');

      final result = await service.transcribe(provider, audioFile.path);
      expect(result, '午饭拉面25元');
    });

    test('401 错误应抛出 API Key 无效', () async {
      final dio = makeDio(
        statusCode: 401,
        responseData: jsonEncode({'error': 'Unauthorized'}),
      );

      final service = VoiceRecognitionService(dio);
      final provider = makeProvider(audioModel: 'whisper-1');
      final audioFile = await createTempAudio('test.m4a');

      expect(
        () => service.transcribe(provider, audioFile.path),
        throwsA(predicate((e) =>
            e is LlmException && e.message.contains('API Key'))),
      );
    });

    test('纯文本响应应直接返回', () async {
      final dio = makeDio(
        statusCode: 200,
        responseData: '直接返回的文本',
        contentType: 'text/plain',
      );

      final service = VoiceRecognitionService(dio);
      final provider = makeProvider(audioModel: 'whisper-1');
      final audioFile = await createTempAudio('test.m4a');

      final result = await service.transcribe(provider, audioFile.path);
      expect(result, '直接返回的文本');
    });
  });
}

/// 模拟 HTTP 适配器，在传输层拦截请求返回预设响应
class _MockAdapter implements HttpClientAdapter {
  final int statusCode;
  final dynamic responseData;
  final String contentType;

  _MockAdapter({
    required this.statusCode,
    required this.responseData,
    this.contentType = 'application/json',
  });

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = responseData is String
        ? utf8.encode(responseData as String)
        : utf8.encode(jsonEncode(responseData));

    return ResponseBody.fromBytes(
      body,
      statusCode,
      headers: {
        'content-type': [contentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
