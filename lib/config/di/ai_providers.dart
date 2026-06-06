import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/ai/data/repositories/llm_repository_impl.dart';
import '../../features/ai/domain/repositories/llm_repository.dart';
import '../../features/ai/data/models/llm_config.dart';

/// Dio HTTP 客户端 Provider
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

/// LLM Repository Provider
final llmRepositoryProvider = Provider<LlmRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return LlmRepositoryImpl(dio);
});

/// LLM 配置 Provider（异步加载）
final llmConfigProvider = FutureProvider<LlmConfig>((ref) async {
  final repo = ref.watch(llmRepositoryProvider);
  return await repo.getConfig();
});
