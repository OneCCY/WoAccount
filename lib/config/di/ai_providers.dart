import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/ai/data/repositories/llm_repository_impl.dart';
import '../../features/ai/domain/repositories/llm_repository.dart';

/// Dio HTTP 客户端 Provider
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

/// LLM Repository Provider
final llmRepositoryProvider = Provider<LlmRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return LlmRepositoryImpl(dio);
});
