# AI 角色管理系统 — 设计文档 v1.2

## 1. 背景

### 1.1 当前问题

WoAccount 的 AI 记账功能使用严格的记账解析 prompt，要求 LLM 仅输出结构化 JSON。当用户输入**非记账内容**（如"你好"、"今天心情不错"、"讲个笑话"）时：

- LLM 不知道以什么角色回应
- 返回的 raw response 只是通用 LLM 默认回答，**没有个性，没有温度**
- 当前已有 `nonTransactionResponse` 字段和处理逻辑，但**缺少角色人格的定义、注入以及对话记忆能力**

### 1.2 目标

- 用户可预设多个 AI 角色，选择其中一个激活。当输入非记账内容时，AI 以所选角色身份给出个性化回复
- 支持**对话历史持久化**，使角色具备上下文记忆能力，避免单轮对话导致的体验割裂
- 通过 **Few-Shot 示例**增强角色表现力，防止人设崩坏
- 通过**双轨记忆模型**（语义记忆 + 情景记忆）让 AI 真正"记住"用户

---

## 2. 架构概览

### 2.1 调用流程图

```
用户输入文本
  │
  ▼
TransactionPipeline.processText()
  │
  ├─ LLM 解析记账（现有逻辑，完全不变）
  │     │
  │     ├─ 成功 → 返回交易列表 → 确认卡片 ✅
  │     │
  │     └─ 失败 → llmErrorNonTransaction 异常
  │               │
  │               ▼
  │          检测是否有已激活的角色 persona？
  │               │
  │           ┌───┴───┐
  │           │       │
  │          是      否
  │           │       │
  │           ▼       ▼
  │     ┌─ 构建增强 System Prompt ─┐   返回原始 LLM 响应
  │     │                          │    （保持当前行为）
  │     │  1. 基础角色 prompt       │
  │     │  2. + 语义记忆 Top-8     │
  │     │  3. + 情景记忆(按需)     │
  │     │  4. + 历史最近 N 轮      │
  │     └──────────┬───────────────┘
  │                │
  │                ▼
  │         调用 LLM (Stream)
  │                │
  │          ┌─────┴──────┐
  │          │            │
  │     UI 渲染回复    异步入队记忆提取 ──→ 批量提取 → 写入
  │          │                              PersonaMemory
  │          ▼
  │     角色化回复 (带记忆)
  │
  └──→ nonTransactionResponse 返回给 UI 显示

# 记忆提取（异步，不阻塞主流程）
MemoryExtractionQueue
  │
  ├─ 触发条件（任一）
  │   • 队列 ≥ 5 条
  │   • 距上次 ≥ 60s
  │   • App 切后台
  │
  ▼
LLM 批量提取（单次调用，走廉价模型）
  │
  ▼
写入事务：upsert PersonaMemory + 更新 keywords
```

### 2.2 分层职责

| 层级 | 模块 | 职责 |
|------|------|------|
| **Model** | `AiPersona` | 角色数据模型（含 Few-Shot 示例、开场白） |
| **Model** | `ChatMessageEntity` | 聊天消息实体（关联角色 ID、时间戳，🆕 FTS 关键词） |
| **Model** | `PersonaMemory` | 🆕 语义记忆实体（类型、内容、权重评分） |
| **Storage** | `PersonaStorage` | SharedPreferences 持久化角色配置 CRUD |
| **Storage** | `ChatHistoryRepository` | Isar 持久化聊天记录、历史加载、自动清理、🆕 FTS 检索 |
| **Storage** | `MemoryRepository` | 🆕 语义记忆 CRUD、评分更新、Top-N 查询 |
| **Queue** | `MemoryExtractionQueue` | 🆕 异步批量记忆提取管线 |
| **Pipeline** | `TransactionPipeline` | 非记账检测 → 历史加载 + 记忆注入 → LLM 调用 → 消息持久化 → 入队提取 |
| **UI** | `PersonaListPage` | 角色列表、选择激活、删除（联动清理历史 + 记忆） |
| **UI** | `PersonaEditPage` | 新建/编辑角色（名称、头像、性格描述、对话示例、开场白） |
| **UI** | `MemoryManagePage` | 🆕 记忆管理页（查看、编辑、删除记忆） |
| **UI** | `AiChatPage` | 初始化加载历史、切换角色重载、流式渲染 |

---

## 3. 数据层设计

### 3.1 双轨记忆模型

放弃"全量历史 RAG"的执念，将记忆拆解为两条独立轨道：

| 轨道 | 存储形式 | 检索方式 | 注入位置 | 解决的核心痛点 |
|------|----------|----------|----------|----------------|
| **语义记忆** | Isar `PersonaMemory` 表 (KV 标签) | 按类型+权重直接读取 Top-N | System Prompt 固定区块 | "AI 懂我"（偏好/事实/关系） |
| **情景记忆** | Isar `ChatMessageEntity` (原文) | BM25 全文搜索 + 时间衰减 | User Message 前缀或动态 System 区块 | "AI 记得"（具体事件/上下文） |

> 用户对"记忆力"的感知 80% 来自语义记忆。把 LLM 算力集中在提取结构化标签上，比花在检索原始对话上 ROI 高一个数量级。

### 3.2 角色数据模型 (SharedPreferences)

```dart
/// AI 角色定义
class AiPersona {
  final String id;          // UUID
  final String name;        // 角色名称
  final String avatar;      // emoji 头像
  final String description; // 性格描述
  final List<DialogueExample> examples; // Few-Shot 对话示例
  final String greeting;    // 开场白
  final bool isDefault;
  final int sortOrder;

  String get systemPrompt => buildPersonaPrompt(name, description, examples);
}

/// 对话示例
class DialogueExample {
  final String user;
  final String assistant;
}
```

### 3.3 聊天消息模型 (Isar)

```dart
@collection
class ChatMessageEntity {
  Id id = Isar.autoIncrement;

  @Index()
  String? personaId;

  late String role;    // 'user' | 'assistant' | 'system'
  late String content;

  @Index()
  late DateTime createdAt;

  /// 🆕 为 FTS 优化的关键词字段（异步提取，非原文）
  /// 例如原文"今天去看了哪吒2" → keywords="哪吒2 电影 观影"
  @Index(type: IndexType.fullText)
  String? searchKeywords;
}
```

### 3.4 语义记忆模型 (Isar)

```dart
/// 语义记忆：高度压缩的结构化知识
@collection
class PersonaMemory {
  Id id = Isar.autoIncrement;

  @Index()
  late String personaId;

  /// 枚举: preference | fact | relationship | instruction
  late String type;

  /// 精炼内容，如 "讨厌被叫亲" / "养猫名叫年糕" / "后端Dart开发"
  late String content;

  /// 0.0-1.0，新记忆初始0.8，被命中+0.1，30天未命中-0.05
  late double score;

  @Index()
  late DateTime updatedAt;

  /// 源消息 ID（可选，用于回查原文）
  int? sourceMessageId;
}
```

### 3.5 存储方案对比

| 数据类型 | 存储方案 | 理由 |
|----------|----------|------|
| 角色配置 | SharedPreferences | 数据量极少（<10 条），KV 结构足够 |
| 聊天记录 | Isar | 高频读写、需按角色+时间查询+FTS |
| 语义记忆 | Isar | 需按角色+类型查询、评分排序、轻量级 |

### 3.6 MemoryRepository API

```dart
class MemoryRepository {
  /// 获取某角色的 Top-N 语义记忆（按 score 降序）
  Future<List<PersonaMemory>> getTopMemories({
    required String personaId,
    int limit = 8,
  });

  /// 获取某类型的记忆（用于 UI 分类展示）
  Future<List<PersonaMemory>> getMemoriesByType({
    required String personaId,
    required String type,
  });

  /// 写入或更新记忆（去重合并：同 type + 同 content 则更新 score）
  Future<void> upsertMemory(PersonaMemory memory);

  /// 批量写入记忆（来自提取管线）
  Future<void> upsertMemories(List<PersonaMemory> memories);

  /// 命中时增加权重
  Future<void> bumpScore(int memoryId);

  /// 删除单条记忆
  Future<void> deleteMemory(int id);

  /// 删除角色关联的所有记忆
  Future<void> clearMemories(String personaId);

  /// 清理低分/过期记忆
  Future<void> decayAndPrune({
    double decayRate = 0.05,
    int daysThreshold = 30,
    double minScore = 0.1,
  });
}
```

### 3.7 ChatHistoryRepository 增强

```dart
class ChatHistoryRepository {
  // ... 原有方法

  /// 🆕 FTS 全文搜索：按关键词检索历史消息
  Future<List<ChatMessageEntity>> searchByKeywords({
    required String? personaId,
    required String query,
    int limit = 3,
  });

  /// 🆕 更新消息的关键词字段（提取管线写回）
  Future<void> updateSearchKeywords(int messageId, String keywords);
}
```

---

## 4. 异步记忆提取管线

### 4.1 设计原则

- **绝不阻塞主线程**
- **绝不在每次对话时触发**
- 采用"消息队列 + 批量提取"模式

### 4.2 流程

```
用户发消息 → LLM 流式回复 → UI 渲染 → 写入 ChatMessage (同步，<10ms)
                                       │
                                       ▼ (入队，不等待)
                               MemoryExtractionQueue
                                       │
                               ┌───────┴────────┐
                               │ 触发条件(任一)   │
                               │ • 队列 ≥ 5 条   │
                               │ • 距上次 ≥ 60s  │
                               │ • App 切后台     │
                               └───────┬────────┘
                                       ▼
                           LLM 批量提取（单次调用）
                           Prompt: "分析以下5轮对话，
                           输出JSON: {memories[], keywords[]}"
                                       │
                               ┌───────┴────────┐
                               │  写入事务        │
                               │ • upsert Memory │ ← 去重合并
                               │ • 更新 keywords  │
                               │ • 标记已处理     │
                               └────────────────┘
```

### 4.3 MemoryExtractionQueue 实现

```dart
class MemoryExtractionQueue {
  final MemoryRepository _memoryRepo;
  final ChatHistoryRepository _chatRepo;
  final LlmRepository _llmRepo;
  final List<ChatMessageEntity> _queue = [];
  Timer? _debounceTimer;
  DateTime _lastExtraction = DateTime.now();

  static const int _batchThreshold = 5;
  static const Duration _timeThreshold = Duration(seconds: 60);

  /// 入队一条新消息
  void enqueue(ChatMessageEntity message) {
    _queue.add(message);
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

    // 走廉价模型批量提取（不影响主对话模型）
    try {
      final result = await _extractBatch(batch);
      // 写入语义记忆
      if (result.memories.isNotEmpty) {
        await _memoryRepo.upsertMemories(result.memories);
      }
      // 更新 keywords
      for (final item in result.keywordUpdates) {
        await _chatRepo.updateSearchKeywords(item.messageId, item.keywords);
      }
    } catch (e) {
      // 提取失败不阻塞，消息标记 pending，下次重试
      _queue.addAll(batch);
    }
  }
}
```

### 4.4 批量提取 Prompt

```
分析以下 {n} 轮对话，提取用户的偏好、事实信息和每条消息的关键词。

## 输出格式
{
  "memories": [
    {
      "type": "preference" | "fact" | "relationship" | "instruction",
      "content": "精炼的一句话描述，保留关键细节"
    }
  ],
  "keywords": [
    { "messageIndex": 0, "keywords": "关键词1 关键词2" },
    { "messageIndex": 1, "keywords": "关键词3 关键词4" }
  ]
}

## 记忆提取规则
- 只提取明确表达或可高度确信的信息
- "今天吃饭花了30" 不是记忆，不提取
- "我不吃辣" → {"type": "preference", "content": "不吃辣"}
- "我在字节上班" → {"type": "fact", "content": "在字节跳动工作"}
- "我女朋友叫小红" → {"type": "relationship", "content": "女朋友叫小红"}
- "以后叫我CC就好" → {"type": "instruction", "content": "称呼用户为CC"}

## 对话内容
---
```

---

## 5. Pipeline 记忆注入策略

### 5.1 Token 预算控制

| 区块 | Token 预算 | 说明 |
|------|-----------|------|
| 基础角色 prompt | ~200 | 角色身份 + 规则 |
| Few-Shot 示例 | ~200 | 最多 3 组 |
| 语义记忆块 | ≤ 300 | Top-8 条 × ~40 字 |
| 情景记忆块 | ≤ 200 | 最多 3 条（按需触发） |
| 最近历史 | ~500 | 最近 6 轮对话 |
| **总计增量** | **≤ 500** | 语义记忆 + 情景记忆 |

### 5.2 增强 Prompt 构建

```dart
Future<String> buildEnhancedSystemPrompt(AiPersona persona, String userInput) async {
  final buffer = StringBuffer(persona.systemPrompt);

  // 📌 语义记忆：固定注入，按 score 降序取 Top-8
  final memories = await _memoryRepo.getTopMemories(
    personaId: persona.id,
    limit: 8,
  );
  if (memories.isNotEmpty) {
    buffer.writeln('\n## 你对用户的长期了解');
    for (final m in memories) {
      buffer.writeln('- [${m.type}] ${m.content}');
    }
  }

  // 🔍 情景记忆：按需检索，仅在输入含潜在指代时触发
  if (_needsContextRecall(userInput)) {
    final relevant = await _chatRepo.searchByKeywords(
      personaId: persona.id,
      query: userInput,
      limit: 3,
    );
    if (relevant.isNotEmpty) {
      buffer.writeln('\n## 相关历史回忆');
      for (final msg in relevant) {
        buffer.writeln('- [${_formatDate(msg.createdAt)}] ${msg.content}');
      }
    }
  }

  return buffer.toString();
}

/// 轻量判断是否需要触发情景记忆检索
bool _needsContextRecall(String input) {
  if (input.length < 5) return false;
  const triggers = ['之前', '上次', '那个', '还记得', '以前', '昨天', '上周'];
  return triggers.any((t) => input.contains(t));
}
```

### 5.3 Pipeline 集成（伪代码）

```dart
} on LlmException catch (e) {
  if (e.errorCode == 'llmErrorNonTransaction') {
    final activePersona = await PersonaStorage.getActive();
    if (activePersona != null) {
      try {
        // 1️⃣ 加载持久化历史
        final historyEntities = await _chatHistoryRepo.getRecentMessages(
          personaId: activePersona.id,
          limit: 6,
        );
        final historyMessages = historyEntities.map(...).toList();

        // 2️⃣ 构建增强 System Prompt（含记忆注入）
        final enhancedPrompt = await buildEnhancedSystemPrompt(
          activePersona, text,
        );

        final messages = [
          ChatMessage(role: 'system', content: enhancedPrompt),
          ...historyMessages,
          ChatMessage(role: 'user', content: text),
        ];

        // 3️⃣ 调用 LLM（支持 Stream）
        final response = await _llmRepo.chat(
          LlmRequest(messages: messages),
          provider: provider,
        );

        // 4️⃣ 持久化消息
        final now = DateTime.now();
        await _chatHistoryRepo.addMessages([
          ChatMessageEntity()..personaId = activePersona.id..role = 'user'..content = text..createdAt = now,
          ChatMessageEntity()..personaId = activePersona.id..role = 'assistant'..content = response.content..createdAt = now,
        ]);

        // 5️⃣ 异步入队记忆提取（不阻塞响应）
        unawaited(_extractionQueue.enqueue(...));

        // 6️⃣ 异步清理旧历史
        unawaited(_chatHistoryRepo.trimHistory(activePersona.id));

        return PipelineResult(
          normalizedText: text,
          transactions: const [],
          source: InputSource.text,
          nonTransactionResponse: response.content,
        );
      } catch (_) {
        // 静默回退
      }
    }
    return PipelineResult(
      normalizedText: text,
      transactions: const [],
      source: InputSource.text,
      nonTransactionResponse: e.data as String? ?? e.message,
    );
  }
  rethrow;
}
```

---

## 6. UI 设计

### 6.1 页面结构

```
AI 设置页 (llm_settings_page_v2.dart)
  │
  ├── 供应商管理 → SupplierManagementPageV2
  ├── Agent 配置 → AgentListPage
  ├── 使用统计 → UsageAnalysisPage
  └── [新增] AI 角色管理 → PersonaListPage
                                │
                          ┌─────┴──────────┐
                          │                │
                    PersonaEditPage    删除确认弹窗
                    (新建/编辑)         (联动清除历史+记忆)
                          │
                          ▼
                  [新增] 记忆管理页
                  MemoryManagePage
                  (查看/编辑/删除记忆)
```

### 6.2 角色编辑页 (PersonaEditPage)

(同 v1.1，新增"管理记忆"入口按钮)

### 6.3 记忆管理页 (MemoryManagePage)

```
┌────────────────────────────────────────┐
│ ← 角色记忆管理                          │
├────────────────────────────────────────┤
│ 🏷️ 偏好                                │
│ ┌──────────────────────────────────┐  │
│ │ 🗑️ 不吃辣                       │  │
│ │ 🗑️ 喜欢喝咖啡                   │  │
│ └──────────────────────────────────┘  │
│                                        │
│ 📖 事实                                │
│ ┌──────────────────────────────────┐  │
│ │ 🗑️ 在字节跳动工作               │  │
│ │ 🗑️ 养猫名叫年糕                 │  │
│ └──────────────────────────────────┘  │
│                                        │
│ 💬 社交关系                            │
│ ┌──────────────────────────────────┐  │
│ │ 🗑️ 女朋友叫小红                 │  │
│ └──────────────────────────────────┘  │
│                                        │
│ ⚙️ 习惯指令                            │
│ ┌──────────────────────────────────┐  │
│ │ 🗑️ 称呼用户为CC                 │  │
│ └──────────────────────────────────┘  │
│                                        │
│ ┌──────────────────────────────────┐  │
│ │ AI 会自动从对话中学习并更新记忆  │  │
│ │ 你可以随时查看和删除不想要的记忆 │  │
│ └──────────────────────────────────┘  │
└────────────────────────────────────────┘
```

---

## 7. 路由设计

在 [`app_router.dart`](lib/config/routes/app_router.dart) 的非 Shell 路由区新增：

```dart
GoRoute(
  path: '/ai/personas',
  builder: (context, state) => const PersonaListPage(),
),
GoRoute(
  path: '/ai/personas/edit',
  builder: (context, state) {
    final persona = state.extra as AiPersona?;
    return PersonaEditPage(existingPersona: persona);
  },
),
GoRoute(
  path: '/ai/personas/memories',
  builder: (context, state) {
    final personaId = state.extra as String;
    return MemoryManagePage(personaId: personaId);
  },
),
```

---

## 8. 本地化字符串

(在 v1.1 基础上追加)

| Key | 中文值 |
|-----|--------|
| `aiPersonaManageMemories` | 管理记忆 |
| `aiPersonaMemoryTitle` | 角色记忆管理 |
| `aiPersonaMemoryTypePreference` | 偏好 |
| `aiPersonaMemoryTypeFact` | 事实 |
| `aiPersonaMemoryTypeRelationship` | 社交关系 |
| `aiPersonaMemoryTypeInstruction` | 习惯指令 |
| `aiPersonaMemoryEmpty` | 还没有记忆，AI 会在对话中自动学习 |
| `aiPersonaMemoryDeleteConfirm` | 确定删除这条记忆吗？ |
| `aiPersonaMemoryDeleted` | 记忆已删除 |
| `aiPersonaMemoryLearnHint` | AI 会自动从对话中学习并更新记忆，你可以随时查看和删除不想要的记忆 |

---

## 9. 影响范围清单

### 🆕 新增文件清单

| 文件 | 说明 |
|------|------|
| `lib/features/ai/data/models/ai_persona.dart` | 数据模型 + prompt builder |
| `lib/features/ai/data/models/chat_message_entity.dart` | Isar 聊天消息实体（🆕 FTS keywords） |
| `lib/features/ai/data/models/persona_memory.dart` | 🆕 Isar 语义记忆实体 |
| `lib/features/ai/data/storage/persona_storage.dart` | SharedPreferences CRUD |
| `lib/features/ai/data/repository/chat_history_repository.dart` | Isar 聊天记录仓库（🆕 FTS 检索） |
| `lib/features/ai/data/repository/memory_repository.dart` | 🆕 语义记忆 CRUD + 评分 |
| `lib/features/ai/data/repository/memory_extraction_queue.dart` | 🆕 异步批量提取管线 |
| `lib/features/ai/presentation/pages/persona_list_page.dart` | 角色列表页 |
| `lib/features/ai/presentation/pages/persona_edit_page.dart` | 角色编辑页 |
| `lib/features/ai/presentation/pages/memory_manage_page.dart` | 🆕 记忆管理页 |

### 🔧 修改文件清单

| 文件 | 改动量 | 说明 |
|------|--------|------|
| `lib/core/ai/transaction_pipeline.dart` | +40 行 | 历史加载 + 记忆注入 + 消息持久化 + 异步提取入队 |
| `lib/features/chat/presentation/pages/ai_chat_page.dart` | +25 行 | 初始化加载历史、切换角色重载、流式写入 |
| `lib/config/routes/app_router.dart` | +24 行 | 注册三个新路由 |
| `lib/features/ai/presentation/pages/llm_settings_page_v2.dart` | +10 行 | 添加"AI 角色管理"入口 |
| `lib/l10n/app_zh.arb` | +25 行 | 新增本地化字符串 |
| `pubspec.yaml` | +3 行 | 新增 isar/isar_flutter_libs/path_provider |
| `lib/main.dart` | +10 行 | 初始化 Isar + 注入依赖 |

---

## 10. 分阶段交付路线

| 版本 | 交付物 | 工时 | 用户感知 |
|------|--------|------|----------|
| **v1.2** | 语义记忆提取 + System Prompt 注入 + 记忆管理 UI | **5h** | ⭐⭐⭐⭐⭐ "它终于记住我了" |
| v1.2.1 | 情景记忆 FTS + 关键词异步提取 + 按需检索 | 3h | ⭐⭐⭐ "它能想起上周的事" |
| v1.3 | 记忆衰减/合并算法 + 用户手动修正反馈闭环 | 3h | ⭐⭐⭐⭐ "记忆越来越准" |

---

## 11. 落地避坑清单

| # | 规则 | 说明 |
|---|------|------|
| 1 | **不要实时提取** | 用户发完消息立刻调 LLM 提取记忆会导致回复延迟翻倍。必须异步队列 |
| 2 | **不要用对话模型做提取** | 用 Qwen-Turbo / GLM-4-Flash 等廉价模型，成本降 10 倍 |
| 3 | **不要存原始对话作为语义记忆** | 一定要 LLM 压缩为结构化标签，"用户说他不喜欢吃香菜" → [preference] 不吃香菜，Token 节省 70% |
| 4 | **FTS 中文分词** | Isar FTS 默认按空格分词，中文需预处理。写入 searchKeywords 时让 LLM 在批量提取时一并输出关键词 |
| 5 | **记忆上限兜底** | 单角色语义记忆硬限 100 条，超出淘汰最低 score |
| 6 | **隐私明示** | 首次激活记忆功能时弹窗告知"AI 会记住你的偏好以提供更好服务" |

---

## 12. 方案对比

| 维度 | 纯向量 RAG | 纯 LLM 摘要塞 Prompt | ✅ 本方案 |
|------|-----------|---------------------|---------|
| 包体积增量 | +10-20MB | 0 | 0 |
| 端侧推理开销 | Embedding 50-200ms/条 | 0 | 0 |
| 记忆提取延迟 | 实时阻塞 | 实时阻塞 | **异步批量，用户无感** |
| Token 消耗 | 中 | 高 | **低（结构化压缩+按需检索）** |
| 中文专有名词召回 | ⚠️ 依赖 Embedding 质量 | ❌ 摘要易丢失细节 | ✅ **FTS 精确匹配** |
| 实现复杂度 | 高 | 低 | **中（纯 Dart + Isar）** |

---

> 文档版本: v1.2
> 最后更新: 2026-06-29
> 
> **v1.2 变更**：
> - 引入双轨记忆模型（语义记忆 + 情景记忆）
> - 新增 PersonaMemory + MemoryRepository
> - 新增 MemoryExtractionQueue 异步批量提取管线
> - 新增 Token 预算控制策略（≤500 Token 增量）
> - 新增 FTS 中文全文检索
> - 新增记忆管理 UI（MemoryManagePage）
> - 新增落地避坑清单
> - 新增方案对比表
> - 分阶段交付路线：v1.2 → v1.2.1 → v1.3
