import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ai/transaction_pipeline.dart';
import '../../core/media/media_storage_service.dart';
import '../../features/ai/data/repositories/llm_repository_impl.dart';
import '../../features/ai/domain/repositories/llm_repository.dart';
import '../../features/text_ai/data/services/voice_recognition_service.dart';
import '../../features/vision_ai/data/services/image_recognition_service.dart';

/// Dio HTTP 客户端 Provider
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

/// LLM Repository Provider
final llmRepositoryProvider = Provider<LlmRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return LlmRepositoryImpl(dio);
});

/// 语音识别服务 Provider
final voiceRecognitionServiceProvider = Provider<VoiceRecognitionService>((ref) {
  final dio = ref.watch(dioProvider);
  return VoiceRecognitionService(dio);
});

/// 图片识别服务 Provider
final imageRecognitionServiceProvider = Provider<ImageRecognitionService>((ref) {
  final dio = ref.watch(dioProvider);
  return ImageRecognitionService(dio);
});

/// 媒体存储服务 Provider
final mediaStorageServiceProvider = Provider<MediaStorageService>((ref) {
  return MediaStorageService();
});

/// 统一记账管线 Provider
final transactionPipelineProvider = Provider<TransactionPipeline>((ref) {
  return TransactionPipeline(
    llmRepo: ref.watch(llmRepositoryProvider),
    voiceService: ref.watch(voiceRecognitionServiceProvider),
    imageService: ref.watch(imageRecognitionServiceProvider),
    mediaStorage: ref.watch(mediaStorageServiceProvider),
  );
});
