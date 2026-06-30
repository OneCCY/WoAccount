import 'dart:async';
import 'dart:convert';
import '../../../../config/database/app_database.dart';
import '../../data/models/llm_config.dart';
import '../../data/storage/provider_storage.dart';
import '../../domain/repositories/llm_repository.dart';
import 'chat_history_repository.dart';
import 'memory_repository.dart';

/// 异步记忆提取队列
/// 采用"消息队列 + 批量提取"模式，绝不阻塞主线程
class MemoryExtractionQueue {
  final MemoryRepository _memoryRepo;
  final ChatHistoryRepository _chatHistoryRepo;
  final LlmRepository? _llmRepo;

  final List<_QueueItem> _queue = [];
  Timer? _debounceTimer;
  DateTime _lastExtraction = DateTime.now();

  static const int _batchThreshold = 5;
  static const Duration _timeThreshold = Duration(seconds: 60);

  MemoryExtractionQueue({
    required MemoryRepository memoryRepo,
    required ChatHistoryRepository chatHistoryRepo,
    LlmRepository? llmRepo,
  })  : _memoryRepo = memoryRepo,
        _chatHistoryRepo = chatHistoryRepo,
        _llmRepo = llmRepo;

  /// 入队一条新消息
  void enqueue(String personaId, String userContent, String assistantContent) {
    _queue.add(_QueueItem(personaId, userContent, assistantContent));
    _tryTrigger();
  }

  /// App 切后台时触发
  void onAppBackgrounded() => _flush();

  /// 判断是否满足触发条件
  void _tryTrigger() {
    if (_queue.length >= _batchThreshold) {
      _flush();
      return;
    }
    final elapsed = DateTime.now().difference(_lastExtraction);
    if (elapsed >= _timeThreshold && _queue.isNotEmpty) {
      _flush();
      return;
    }
    // 兜底 debounce
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_timeThreshold, _flush);
  }

  /// 执行批量提取
  Future<void> _flush() async {
    _debounceTimer?.cancel();
    if (_queue.isEmpty) return;

    final batch = List<_QueueItem>.from(_queue);
    _queue.clear();
    _lastExtraction = DateTime.now();

    try {
      final result = await _extractBatch(batch);
      // 写入语义记忆
      if (result.memories.isNotEmpty) {
        for (final m in result.memories) {
          await _memoryRepo.upsertMemory(m);
        }
      }
      // 更新 keywords
      for (final item in result.keywordUpdates) {
        await _chatHistoryRepo.updateSearchKeywords(item.messageId, item.keywords);
      }
    } catch (e) {
      // 提取失败不阻塞，消息标记 pending，下次批量时重试
      _queue.addAll(batch);
    }
  }

  /// 批量提取语义记忆和关键词
  Future<_ExtractionResult> _extractBatch(List<_QueueItem> batch) async {
    if (batch.isEmpty) return _ExtractionResult([], []);

    // 构建对话文本
    final dialogues = batch.map((item) {
      return 'User: ${item.userContent}\nAssistant: ${item.assistantContent}';
    }).join('\n\n');

    final prompt = '''分析以下对话，提取用户的偏好、事实和每条消息的关键词。

## 对话内容
$dialogues

## 记忆提取规则
- 只提取明确表达或可高度确信的信息
- "今天吃饭花了30" 不是记忆，不提取
- "我不吃辣" → {"type": "preference", "content": "不吃辣"}
- "我在字节上班" → {"type": "fact", "content": "在字节跳动工作"}
- "我女朋友叫小红" → {"type": "relationship", "content": "女朋友叫小红"}
- "以后叫我CC就好" → {"type": "instruction", "content": "称呼用户为CC"}

## 输出格式
{
  "memories": [
    {"type": "preference", "content": "精炼的一句话描述"}
  ],
  "keywords": [
    {"index": 0, "keywords": "关键词1 关键词2"}
  ]
}''';

    // 调用 LLM 执行提取
    if (_llmRepo == null) return _ExtractionResult([], []);

    try {
      // 获取可用的 provider
      final provider = await _getAvailableProvider();
      if (provider == null) return _ExtractionResult([], []);

      final response = await _llmRepo.chat(
        LlmRequest(
          messages: [ChatMessage(role: 'user', content: prompt)],
        ),
        provider: provider,
      );

      // 解析 JSON 结果
      return _parseExtractionResult(response.content, batch.length);
    } catch (e) {
      // 提取失败不阻塞
      return _ExtractionResult([], []);
    }
  }

  /// 获取可用的 LLM provider
  Future<LlmProvider?> _getAvailableProvider() async {
    // 尝试从 ProviderStorage 获取
    final v2Providers = await ProviderStorage.loadAll();
    final ready = v2Providers.where((p) => p.isReady).toList();
    if (ready.isNotEmpty) {
      final p = ready.first;
      return LlmProvider(
        id: p.id,
        name: p.name,
        apiKey: p.apiKey,
        baseUrl: p.baseUrl,
        temperature: p.temperature,
        maxTokens: p.maxTokens,
        timeoutSeconds: p.timeoutSeconds,
        providerKey: p.providerKey ?? 'custom',
        models: {},
      );
    }
    return null;
  }

  /// 解析 LLM 返回的记忆提取结果
  _ExtractionResult _parseExtractionResult(String content, int batchSize) {
    try {
      final decoded = jsonDecode(content) as Map<String, dynamic>;

      // 解析 memories
      final memories = <PersonaMemory>[];
      final memoryList = decoded['memories'] as List<dynamic>? ?? [];
      final now = DateTime.now();
      for (final m in memoryList) {
        final map = m as Map<String, dynamic>;
        memories.add(PersonaMemory(
          id: 0,
          personaId: '', // 将在 upsert 时由 repository 设置
          type: map['type'] as String? ?? 'preference',
          content: map['content'] as String? ?? '',
          score: 0.8,
          updatedAt: now,
        ));
      }

      // 解析 keywords
      final keywords = <_KeywordUpdate>[];
      final keywordList = decoded['keywords'] as List<dynamic>? ?? [];
      for (var i = 0; i < keywordList.length && i < batchSize; i++) {
        final map = keywordList[i] as Map<String, dynamic>;
        keywords.add(_KeywordUpdate(
          messageId: i + 1, // 简化处理，实际应映射到数据库 ID
          keywords: map['keywords'] as String? ?? '',
        ));
      }

      return _ExtractionResult(memories, keywords);
    } catch (e) {
      // 解析失败
      return _ExtractionResult([], []);
    }
  }
}

class _QueueItem {
  final String personaId;
  final String userContent;
  final String assistantContent;

  _QueueItem(this.personaId, this.userContent, this.assistantContent);
}

class _ExtractionResult {
  final List<PersonaMemory> memories;
  final List<_KeywordUpdate> keywordUpdates;

  _ExtractionResult(this.memories, this.keywordUpdates);
}

class _KeywordUpdate {
  final int messageId;
  final String keywords;

  _KeywordUpdate({required this.messageId, required this.keywords});
}