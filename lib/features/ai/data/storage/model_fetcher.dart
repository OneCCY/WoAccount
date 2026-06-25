import 'package:dio/dio.dart';

import 'provider_storage.dart';

/// 从 API 拉取模型列表
///
/// 替代 llm_settings_page.dart 中的 fetchModelsFromApi() 顶层函数。
class ModelFetcher {
  /// 已知的 URL 兼容后缀
  static const _compatSuffixes = ['/v1', '/v2', '/v3'];

  /// 从 API 拉取模型列表
  ///
  /// 尝试多个 URL candidate，返回第一个成功的模型 ID 列表。
  static Future<List<String>> fetchModels(String baseUrl, String apiKey) async {
    final candidates = _buildUrlCandidates(baseUrl);
    final dio = Dio();

    for (final url in candidates) {
      try {
        final response = await dio.get(
          url,
          options: Options(
            headers: {'Authorization': 'Bearer $apiKey'},
            receiveTimeout: const Duration(seconds: 10),
          ),
        );
        if (response.statusCode == 200) {
          final data = response.data;
          if (data is Map && data['data'] is List) {
            final models = (data['data'] as List)
                .map((m) => m['id'] as String?)
                .whereType<String>()
                .toList();
            if (models.isNotEmpty) {
              // 缓存结果
              return models;
            }
          }
        }
      } catch (_) {
        // 继续尝试下一个 URL
      }
    }
    return [];
  }

  /// 从 API 拉取并缓存模型列表
  static Future<List<String>> fetchAndCache(String providerId, String baseUrl, String apiKey) async {
    final models = await fetchModels(baseUrl, apiKey);
    if (models.isNotEmpty) {
      await ProviderStorage.saveFetchedModels(providerId, models);
    }
    return models;
  }

  /// 构建 URL 候选列表
  static List<String> _buildUrlCandidates(String baseUrl) {
    final candidates = <String>[];
    var url = baseUrl.trimRight();

    // 去掉已知的兼容后缀
    for (final suffix in _compatSuffixes) {
      if (url.endsWith(suffix)) {
        url = url.substring(0, url.length - suffix.length);
        break;
      }
    }

    // 去掉尾部斜杠
    url = url.replaceAll(RegExp(r'/+$'), '');

    // 按优先级构建候选 URL
    candidates.add('$url/v1/models');
    candidates.add('$url/models');
    candidates.add('$url/v1beta/models');

    return candidates;
  }
}
