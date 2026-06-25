import 'package:dio/dio.dart';

import 'provider_storage.dart';

/// 从 API 拉取模型列表
///
/// 支持 OpenAI 和 Anthropic 两种认证格式。
class ModelFetcher {
  static const _compatSuffixes = ['/v1', '/v2', '/v3'];

  /// 从 API 拉取模型列表
  ///
  /// [apiKey] API 密钥
  /// [baseUrl] API 基础地址
  /// [isAnthropic] 是否使用 Anthropic 认证格式（x-api-key 头）
  static Future<List<String>> fetchModels(
    String baseUrl,
    String apiKey, {
    bool isAnthropic = false,
  }) async {
    final candidates = _buildUrlCandidates(baseUrl);
    final dio = Dio();

    final headers = isAnthropic
        ? {'x-api-key': apiKey, 'anthropic-version': '2023-06-01'}
        : {'Authorization': 'Bearer $apiKey'};

    for (final url in candidates) {
      try {
        final response = await dio.get(
          url,
          options: Options(
            headers: headers,
            receiveTimeout: const Duration(seconds: 10),
          ),
        );
        if (response.statusCode == 200) {
          final data = response.data;
          // OpenAI 格式: { "data": [{ "id": "model-name", ... }] }
          if (data is Map && data['data'] is List) {
            final models = (data['data'] as List)
                .map((m) => m['id'] as String?)
                .whereType<String>()
                .toList();
            if (models.isNotEmpty) return models;
          }
          // Anthropic 格式: { "data": [{ "id": "model-name", ... }] }
          // Anthropic 也使用类似格式
          if (data is Map && data['models'] is List) {
            final models = (data['models'] as List)
                .map((m) => m is Map ? m['name'] as String? : null)
                .whereType<String>()
                .toList();
            if (models.isNotEmpty) return models;
          }
        }
      } catch (_) {
        continue;
      }
    }
    return [];
  }

  /// 从 API 拉取并缓存模型列表
  static Future<List<String>> fetchAndCache(
    String providerId,
    String baseUrl,
    String apiKey, {
    bool isAnthropic = false,
  }) async {
    final models = await fetchModels(baseUrl, apiKey, isAnthropic: isAnthropic);
    if (models.isNotEmpty) {
      await ProviderStorage.saveFetchedModels(providerId, models);
    }
    return models;
  }

  /// 构建 URL 候选列表
  static List<String> _buildUrlCandidates(String baseUrl) {
    final candidates = <String>[];
    var url = baseUrl.trimRight();

    for (final suffix in _compatSuffixes) {
      if (url.endsWith(suffix)) {
        url = url.substring(0, url.length - suffix.length);
        break;
      }
    }

    url = url.replaceAll(RegExp(r'/+$'), '');

    candidates.add('$url/v1/models');
    candidates.add('$url/models');
    candidates.add('$url/v1beta/models');

    return candidates;
  }
}
