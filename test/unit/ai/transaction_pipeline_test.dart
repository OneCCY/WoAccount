import 'package:flutter_test/flutter_test.dart';
import 'package:wo_account/config/database/app_database.dart';
import 'package:wo_account/core/ai/transaction_pipeline.dart';
import 'package:wo_account/core/media/media_storage_service.dart';
import 'package:wo_account/features/ai/data/models/llm_config.dart';
import 'package:wo_account/features/ai/domain/repositories/llm_repository.dart';
import 'package:wo_account/features/text_ai/data/services/voice_recognition_service.dart';
import 'package:wo_account/features/vision_ai/data/services/image_recognition_service.dart';

void main() {
  late AppDatabase testDb;

  setUpAll(() {
    testDb = AppDatabase();
  });

  tearDownAll(() async {
    await testDb.close();
  });

  group('TransactionPipeline', () {
    late FakeLlmRepository fakeLlmRepo;
    late FakeVoiceRecognitionService fakeVoiceService;
    late FakeImageRecognitionService fakeImageService;
    late FakeMediaStorageService fakeMediaStorage;
    late TransactionPipeline pipeline;

    setUp(() {
      fakeLlmRepo = FakeLlmRepository();
      fakeVoiceService = FakeVoiceRecognitionService();
      fakeImageService = FakeImageRecognitionService();
      fakeMediaStorage = FakeMediaStorageService();

      pipeline = TransactionPipeline(
        llmRepo: fakeLlmRepo,
        voiceService: fakeVoiceService,
        imageService: fakeImageService,
        mediaStorage: fakeMediaStorage,
        db: testDb,
      );
    });

    group('processText', () {
      test('应返回文本解析结果', () async {
        fakeLlmRepo.parseResults = [
          const TransactionParseResult(
            type: 'expense',
            amount: 25.0,
            category: '餐饮',
            description: '午饭拉面',
            confidence: 0.95,
          ),
        ];

        final result = await pipeline.processText('午饭拉面25元');

        expect(result.source, InputSource.text);
        expect(result.normalizedText, '午饭拉面25元');
        expect(result.transactions.length, 1);
        expect(result.transactions.first.amount, 25.0);
        expect(result.transactions.first.category, '餐饮');
        expect(result.mediaFilePath, isNull);
      });
    });

    group('processVoice', () {
      test('完整流程：保存音频→转写→解析', () async {
        fakeVoiceService.transcribeResult = '午饭拉面25元';
        fakeLlmRepo.parseResults = [
          const TransactionParseResult(
            type: 'expense',
            amount: 25.0,
            category: '餐饮',
            description: '午饭拉面',
            confidence: 0.95,
          ),
        ];

        final result = await pipeline.processVoice(
          audioTempPath: '/tmp/recording.m4a',
          provider: testProvider,
        );

        expect(result.source, InputSource.voice);
        expect(result.normalizedText, '午饭拉面25元');
        expect(result.transactions.length, 1);
        expect(result.transactions.first.amount, 25.0);
        expect(result.mediaFilePath, isNotNull);
        expect(fakeMediaStorage.savedAudioPaths.length, 1);
      });

      test('转录结果为空时应抛出异常', () async {
        fakeVoiceService.transcribeResult = '';

        expect(
          () => pipeline.processVoice(
            audioTempPath: '/tmp/recording.m4a',
            provider: testProvider,
          ),
          throwsA(isA<LlmException>()),
        );
      });
    });

    group('transcribeOnly', () {
      test('应返回转写文本，不调用 LLM 解析', () async {
        fakeVoiceService.transcribeResult = '午饭拉面25元';

        final result = await pipeline.transcribeOnly(
          audioTempPath: '/tmp/recording.m4a',
          provider: testProvider,
        );

        expect(result, '午饭拉面25元');
        expect(fakeMediaStorage.savedAudioPaths.length, 1);
        // parseTransaction 不应被调用
        expect(fakeLlmRepo.parseCallCount, 0);
      });

      test('转录结果为空时应抛出异常', () async {
        fakeVoiceService.transcribeResult = '   ';

        expect(
          () => pipeline.transcribeOnly(
            audioTempPath: '/tmp/recording.m4a',
            provider: testProvider,
          ),
          throwsA(isA<LlmException>()),
        );
      });
    });

    group('processImage', () {
      test('完整流程：保存图片→识别→解析', () async {
        fakeImageService.recognizeResult = '发票金额 128.00';
        fakeLlmRepo.parseResults = [
          const TransactionParseResult(
            type: 'expense',
            amount: 128.0,
            category: '餐饮',
            description: '发票',
            confidence: 0.9,
          ),
        ];

        final result = await pipeline.processImage(
          imageTempPath: '/tmp/photo.jpg',
          provider: testProvider,
        );

        expect(result.source, InputSource.image);
        expect(result.normalizedText, '发票金额 128.00');
        expect(result.transactions.length, 1);
        expect(result.transactions.first.amount, 128.0);
        expect(result.mediaFilePath, isNotNull);
      });
    });
  });
}

/// 测试用 LlmProvider
final testProvider = LlmProvider(
  id: 'test',
  name: 'Test',
  apiKey: 'test-key',
  baseUrl: 'https://api.example.com/v1',
  models: {
    'audio': const ModelConfig(modelName: 'whisper-1'),
    'vision': const ModelConfig(modelName: 'gpt-4o'),
    'text': const ModelConfig(modelName: 'gpt-4o'),
  },
);

// ==================== Fakes ====================

class FakeLlmRepository implements LlmRepository {
  List<TransactionParseResult> parseResults = [];
  int parseCallCount = 0;

  @override
  Future<List<TransactionParseResult>> parseTransaction(
    String input, {
    String? categoryTaxonomy,
    String locale = 'zh',
    String? fewShotExamples,
    String? similarTransactions,
  }) async {
    parseCallCount++;
    return parseResults;
  }

  @override
  Future<LlmProvider?> getActiveProvider() async => testProvider;

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeVoiceRecognitionService implements VoiceRecognitionService {
  String transcribeResult = '';

  @override
  Future<String> transcribe(
    LlmProvider provider,
    String audioFilePath, {
    String language = 'zh',
  }) async {
    return transcribeResult;
  }
}

class FakeImageRecognitionService implements ImageRecognitionService {
  String recognizeResult = '';

  @override
  Future<String> recognize(
    LlmProvider provider,
    String imageFilePath, {
    String? customPrompt,
  }) async {
    return recognizeResult;
  }

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeMediaStorageService implements MediaStorageService {
  final List<String> savedAudioPaths = [];
  final List<String> savedImagePaths = [];

  @override
  Future<String> saveAudio(String tempPath, {String? filename}) async {
    final savedPath = '/fake/media/audio/${DateTime.now().millisecondsSinceEpoch}.m4a';
    savedAudioPaths.add(savedPath);
    return savedPath;
  }

  @override
  Future<String> saveImageFile(String tempPath, {String? filename}) async {
    final savedPath = '/fake/media/images/${DateTime.now().millisecondsSinceEpoch}.jpg';
    savedImagePaths.add(savedPath);
    return savedPath;
  }

  @override
  noSuchMethod(Invocation invocation) => throw UnimplementedError();
}
