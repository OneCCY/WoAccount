import 'dart:async';
import '../../../../config/database/app_database.dart';
import 'chat_history_repository.dart';
import 'memory_repository.dart';

/// 异步记忆提取队列
/// 采用"消息队列 + 批量提取"模式，绝不阻塞主线程
class MemoryExtractionQueue {
  final MemoryRepository _memoryRepo;
  final ChatHistoryRepository _chatHistoryRepo;

  final List<_QueueItem> _queue = [];
  Timer? _debounceTimer;
  DateTime _lastExtraction = DateTime.now();

  static const int _batchThreshold = 5;
  static const Duration _timeThreshold = Duration(seconds: 60);

  MemoryExtractionQueue({
    required MemoryRepository memoryRepo,
    required ChatHistoryRepository chatHistoryRepo,
  })  : _memoryRepo = memoryRepo,
        _chatHistoryRepo = chatHistoryRepo;

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

    // TODO: 调用 LLM 执行提取
    // 目前返回空结果，等 LLM 集成后再启用
    return _ExtractionResult([], []);
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

  _KeywordUpdate(this.messageId, this.keywords);
}