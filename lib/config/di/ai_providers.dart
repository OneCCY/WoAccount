import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/ai/transaction_pipeline.dart';
import '../../core/ai/voice_transcription_orchestrator.dart';
import '../../core/media/media_storage_service.dart';
import '../../features/ai/data/repositories/llm_repository_impl.dart';
import '../../features/ai/domain/repositories/llm_repository.dart';
import '../../features/ai/domain/agent_runner.dart';
import '../../features/ai/domain/builtin_tools.dart';
import '../../features/text_ai/data/services/voice_recognition_service.dart';
import '../../features/text_ai/data/services/platform_stt_service.dart';
import '../../features/vision_ai/data/services/image_recognition_service.dart';
import 'providers.dart';

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

/// 平台原生语音识别服务 Provider（免费、离线可用）
final platformSttServiceProvider = Provider<PlatformSttService>((ref) {
  final service = PlatformSttService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// 双引擎语音转写编排器 Provider
final voiceTranscriptionOrchestratorProvider =
    Provider<VoiceTranscriptionOrchestrator>((ref) {
  return VoiceTranscriptionOrchestrator(
    whisperService: ref.watch(voiceRecognitionServiceProvider),
    mediaStorage: ref.watch(mediaStorageServiceProvider),
  );
});

/// 媒体存储服务 Provider
final mediaStorageServiceProvider = Provider<MediaStorageService>((ref) {
  return MediaStorageService();
});

/// 统一记账管线 Provider
final transactionPipelineProvider = Provider<TransactionPipeline>((ref) {
  return TransactionPipeline(
    llmRepo: ref.watch(llmRepositoryProvider),
    imageService: ref.watch(imageRecognitionServiceProvider),
    mediaStorage: ref.watch(mediaStorageServiceProvider),
    db: ref.watch(appDatabaseProvider),
    agentRunner: ref.watch(agentRunnerProvider),
  );
});

/// Agent 执行引擎 Provider（v2.0）
final agentRunnerProvider = Provider<AgentRunner>((ref) {
  // 首次访问时注册内置工具
  final db = ref.watch(appDatabaseProvider);
  registerBuiltinTools(db);
  return AgentRunner(
    ref.watch(llmRepositoryProvider),
    db,
  );
});

/// AI 记账页未保存的确认卡片（跨页面切换持久化）
/// 存储 ConfirmData 列表，页面重建时恢复
final pendingConfirmCardsProvider = StateProvider<List<dynamic>>((ref) => []);
