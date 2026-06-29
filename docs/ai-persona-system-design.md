# AI 角色管理系统 — 设计文档 v1.1

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
  │     1. 从 Isar 加载最近 N 轮历史     返回原始 LLM 响应
  │     2. 组装 system prompt + 历史      （保持当前行为）
  │        + Few-Shot + 当前输入
  │     3. 调用 LLM (Stream)
  │     4. 持久化 user + assistant 消息
  │     5. 异步清理过期历史
  │           │
  │           ▼
  │     角色化回复 (带记忆)
  │
  └──→ nonTransactionResponse 返回给 UI 显示
```

### 2.2 分层职责

| 层级 | 模块 | 职责 |
|------|------|------|
| **Model** | `AiPersona` | 角色数据模型（含 Few-Shot 示例、开场白） |
| **Model** | `ChatMessageEntity` | 聊天消息实体（关联角色 ID、时间戳） |
| **Storage** | `PersonaStorage` | SharedPreferences 持久化角色配置 CRUD |
| **Storage** | `ChatHistoryRepository` | Isar 持久化聊天记录、历史加载、自动清理 |
| **Pipeline** | `TransactionPipeline` | 非记账检测 → 历史加载 → Prompt 注入 → 二次 LLM 调用 → 消息持久化 |
| **UI** | `PersonaListPage` | 角色列表、选择激活、删除（联动清理历史） |
| **UI** | `PersonaEditPage` | 新建/编辑角色（名称、头像、性格描述、对话示例、开场白） |
| **UI** | `AiChatPage` | 初始化加载历史、切换角色重载、流式渲染 |
| **Route** | `AppRouter` | 注册两个新路由 |

---

## 3. 数据层设计

### 3.1 角色数据模型 (SharedPreferences)

```dart
/// AI 角色定义
class AiPersona {
  final String id;          // UUID
  final String name;        // 角色名称
  final String avatar;      // emoji 头像
  final String description; // 性格描述
  final List<DialogueExample> examples; // 🆕 Few-Shot 对话示例
  final String greeting;    // 🆕 开场白
  final bool isDefault;
  final int sortOrder;

  String get systemPrompt => buildPersonaPrompt(name, description, examples);
}

/// 对话示例
class DialogueExample {
  final String user;
  final String assistant;
}

/// Prompt 构建器（含 Few-Shot 注入）
String buildPersonaPrompt(String name, String desc, List<DialogueExample> examples) {
  final buffer = StringBuffer('''你正在进行角色扮演，请始终以设定的角色身份回应用户。

角色名称：$name

角色性格：$desc

## 规则
1. 完全以该角色的身份语气说话，保持一致
2. 回复简洁自然，像日常对话
3. 不要提及你是一个 AI 或语言模型
4. 使用与用户相同的语言回复
5. 即使收到与记账相关的描述，也要以角色身份回应，不要输出 JSON
''');

  if (examples.isNotEmpty) {
    buffer.writeln('\n## 对话示例');
    buffer.writeln('以下示例展示了角色的典型回应方式：');
    for (final ex in examples) {
      buffer.writeln('User: ${ex.user}');
      buffer.writeln('Assistant: ${ex.assistant}');
    }
  }

  return buffer.toString();
}
```

### 3.2 聊天消息模型 (Isar)

```dart
@collection
class ChatMessageEntity {
  Id id = Isar.autoIncrement;

  /// 关联的角色 ID，null 表示默认/无角色对话
  @Index()
  String? personaId;

  /// 'user' | 'assistant' | 'system'
  late String role;

  late String content;

  /// 消息时间戳，用于排序和清理
  @Index()
  late DateTime createdAt;
}
```

### 3.3 存储方案对比与决策

| 数据类型 | 存储方案 | 理由 |
|----------|----------|------|
| 角色配置 | SharedPreferences | 数据量极少（<10条），KV 结构足够，零迁移成本 |
| 聊天记录 | **Isar** | 高频读写、需按角色+时间查询、纯 Dart 零原生依赖 |
| 聊天记录 | SharedPreferences | ❌ 全量序列化性能差、无查询能力、体积膨胀风险高 |
| 聊天记录 | SQLite (Drift) | ❌ 现有 DB 已用于业务，角色聊天作为独立功能应解耦 |

### 3.4 ChatHistoryRepository API

```dart
class ChatHistoryRepository {
  final Isar _db;

  /// 获取某角色的最近 N 条消息（按时间正序）
  Future<List<ChatMessageEntity>> getRecentMessages({
    required String? personaId,
    int limit = 20,
  });

  /// 批量保存（user + assistant 一起写入）
  Future<void> addMessages(List<ChatMessageEntity> msgs);

  /// 清理策略：保留最近 keepCount 条，删除更早的
  Future<void> trimHistory(String? personaId, {int keepCount = 50});

  /// 删除角色时联动清理
  Future<void> clearHistory(String? personaId);
}
```

### 3.5 Isar 数据库初始化

在应用启动时初始化 Isar 实例，作为单例注入：

```dart
// 初始化
final dir = await getApplicationDocumentsDirectory();
final isar = await Isar.open(
  [ChatMessageEntitySchema],
  directory: dir.path,
);

// 注入到 Pipeline / ChatPage
```

---

## 4. Pipeline 集成设计

### 4.1 修改点

仅修改 [`transaction_pipeline.dart:207-217`](lib/core/ai/transaction_pipeline.dart#L207-L217) 处的异常捕获逻辑。

### 4.2 伪代码（含持久化）

```dart
} on LlmException catch (e) {
  if (e.errorCode == 'llmErrorNonTransaction') {
    final activePersona = await PersonaStorage.getActive();
    if (activePersona != null) {
      try {
        // 1️⃣ 加载持久化历史
        final historyEntities = await _chatHistoryRepo.getRecentMessages(
          personaId: activePersona.id,
          limit: 10,
        );
        final historyMessages = historyEntities.map((e) =>
          ChatMessage(role: e.role, content: e.content),
        ).toList();

        // 2️⃣ 组装消息列表：system prompt + 历史 + 当前输入
        final messages = [
          ChatMessage(role: 'system', content: activePersona.systemPrompt),
          ...historyMessages,
          ChatMessage(role: 'user', content: text),
        ];

        // 3️⃣ 调用 LLM
        final response = await _llmRepo.chat(
          LlmRequest(messages: messages),
          provider: provider,
        );

        // 4️⃣ 持久化本轮对话
        final now = DateTime.now();
        await _chatHistoryRepo.addMessages([
          ChatMessageEntity()
            ..personaId = activePersona.id
            ..role = 'user'
            ..content = text
            ..createdAt = now,
          ChatMessageEntity()
            ..personaId = activePersona.id
            ..role = 'assistant'
            ..content = response.content
            ..createdAt = now,
        ]);

        // 5️⃣ 异步清理旧消息（不阻塞响应）
        unawaited(_chatHistoryRepo.trimHistory(activePersona.id));

        return PipelineResult(
          normalizedText: text,
          transactions: const [],
          source: InputSource.text,
          nonTransactionResponse: response.content,
        );
      } catch (_) {
        // 角色调用失败，静默回退到原始 LLM 响应
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

### 4.3 不变的部分

- ✅ 记账解析流程完全不变
- ✅ `AgentRunner` 内部逻辑不变
- ✅ `prompt_templates.dart` 不变
- ✅ Provider/DI 注入不变

---

## 5. UI 设计

### 5.1 页面结构

```
AI 设置页 (llm_settings_page_v2.dart)
  │
  ├── 供应商管理 → SupplierManagementPageV2
  ├── Agent 配置 → AgentListPage
  ├── 使用统计 → UsageAnalysisPage
  └── [新增] AI 角色管理 → PersonaListPage
                                │
                          ┌─────┴──────┐
                          │            │
                    PersonaEditPage  删除确认弹窗
                    (新建/编辑)      (联动清除历史)
```

### 5.2 角色列表页 (PersonaListPage)

```
┌────────────────────────────────────────┐
│ ← AI 角色管理                    [+添加]│
├────────────────────────────────────────┤
│                                        │
│  ○ 不启用角色（AI 保持当前默认回复）     │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │ 🧚 温柔知心               ● 已选 │  │
│  │ 温柔体贴，像知心朋友般回应        │  │
│  │                    ✏️  🗑️        │  │
│  └──────────────────────────────────┘  │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │ 🤖 毒舌吐槽家           ○       │  │
│  │ 犀利幽默，带点毒舌               │  │
│  │                    ✏️  🗑️        │  │
│  └──────────────────────────────────┘  │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │ 🐱 猫娘酱               ○       │  │
│  │ 可爱粘人，用喵星人的方式交流     │  │
│  │                    ✏️  🗑️        │  │
│  └──────────────────────────────────┘  │
│                                        │
└────────────────────────────────────────┘

交互：
- 顶部"不启用"选项：选中时 personaStorage.setActiveId(null)
- 每个角色卡片：点击=选中，✏️=编辑，🗑️=删除（确认弹窗，联动清理历史记录）
- 空状态："还没有创建角色哦～点击右上角 + 创建第一个角色吧！"
```

### 5.3 角色编辑页 (PersonaEditPage)

```
┌────────────────────────────────────────┐
│ ← 新建角色                    [💾 保存] │
├────────────────────────────────────────┤
│ 角色名称                               │
│ ┌────────────────────────────────────┐ │
│ │ e.g. 温柔知心                      │ │
│ └────────────────────────────────────┘ │
│                                        │
│ 角色头像                               │
│ ┌────────────────────────────────────┐ │
│ │ 😊 😎 🧐 🤗 🤖 🧚 🎅 🧛        │ │
│ │ 🐱 🐶 🦊 🐰 🐼 🦄 🐧 🦋        │ │
│ │ 💃 🕺 🎪 🎭 🧙 🧝 🧞 🧜        │ │
│ └────────────────────────────────────┘ │
│                                        │
│ 性格描述                               │
│ ┌────────────────────────────────────┐ │
│ │ 你是一个温柔体贴的知心朋友。       │ │
│ │ 总是用温暖和理解的态度回应         │ │
│ │ 用户的每一句话。说话轻声细语，    │ │
│ │ 喜欢用表情符号增加亲和力。        │ │
│ └────────────────────────────────────┘ │
│            (最多 200 字)                │
│                                        │
│ 🆕 对话示例 (可选)                      │
│ ┌────────────────────────────────────┐ │
│ │ User: 今天天气真好                 │ │
│ │ Assistant: 喵～最适合晒太阳了！🐾  │ │
│ │                            [+ 添加]│ │
│ ├────────────────────────────────────┤ │
│ │ User: 我好累啊                     │ │
│ │ Assistant: 辛苦啦～要记得好好休息  │ │
│ │                             🗑️    │ │
│ └────────────────────────────────────┘ │
│    添加几组对话示例，让 AI 更贴合人设    │
│                                        │
│ 🆕 开场白 (可选)                        │
│ ┌────────────────────────────────────┐ │
│ │ 嗨～我是你的专属小助手，            │ │
│ │ 今天想聊点啥？😊                   │ │
│ └────────────────────────────────────┘ │
│    激活角色时自动发送的第一句话         │
│                                        │
│ ┌────────────────────────────────────┐ │
│ │ 💡 角色性格越具体，AI 表现越鲜明！ │ │
│ │ 建议包含：语气（温柔/幽默/犀利）、 │ │
│ │ 说话风格（简洁/啰嗦）、习惯用语等  │ │
│ └────────────────────────────────────┘ │
│                                        │
└────────────────────────────────────────┘
```

### 5.4 AiChatPage 适配

| 场景 | 行为 |
|------|------|
| 页面初始化 | 根据当前激活 Persona 从 Isar 加载历史消息渲染列表 |
| 切换角色 | 监听 activePersonaId 变化 → 重新加载对应历史 → 滚动到底部 |
| 流式输出 | assistant 消息先以临时状态显示，流结束后再写入 DB |
| 首次激活有开场白的角色 | 自动发送 greeting 作为第一条 assistant 消息并持久化 |
| 用户发送消息 | 文本直接走现有 `processText()`，非记账时 persona 接管；存入 Isar |
| 清空历史 | 角色编辑页提供"清空聊天记录"按钮 |

---

## 6. 路由设计

在 [`app_router.dart`](lib/config/routes/app_router.dart) 的非 Shell 路由区新增：

```dart
GoRoute(
  path: '/ai/personas',
  builder: (context, state) => const PersonaListPage(),
),
GoRoute(
  path: '/ai/personas/edit',
  builder: (context, state) {
    final persona = state.extra as AiPersona?;  // null = 新建
    return PersonaEditPage(existingPersona: persona);
  },
),
```

---

## 7. 本地化字符串

`app_zh.arb` 新增以下 key：

| Key | 中文值 |
|-----|--------|
| `aiPersonaManage` | AI 角色管理 |
| `aiPersonaAdd` | 添加角色 |
| `aiPersonaEdit` | 编辑角色 |
| `aiPersonaName` | 角色名称 |
| `aiPersonaAvatar` | 角色头像 |
| `aiPersonaDescription` | 性格描述 |
| `aiPersonaDescriptionHint` | 描述角色的性格特点、说话方式... |
| `aiPersonaNone` | 不启用角色 |
| `aiPersonaDeleteConfirm` | 确定删除角色"{name}"吗？同时也将清除聊天记录。 |
| `aiPersonaEmpty` | 还没有创建角色哦～ |
| `aiPersonaNameRequired` | 请输入角色名称 |
| `aiPersonaTip` | 角色性格越具体，AI 表现越鲜明！建议包含语气、说话风格、习惯用语等 |
| `aiPersonaExamples` | 对话示例 |
| `aiPersonaExamplesHint` | 添加几组对话示例，让 AI 更贴合人设 |
| `aiPersonaExampleUser` | 用户 |
| `aiPersonaExampleAssistant` | 角色 |
| `aiPersonaAddExample` | 添加示例 |
| `aiPersonaGreeting` | 开场白 |
| `aiPersonaGreetingHint` | 激活角色时自动发送的第一句话 |
| `aiChatHistoryCleared` | 聊天记录已清除 |
| `aiChatHistoryClear` | 清空聊天记录 |

---

## 8. 影响范围清单

### ✅ 不受影响的模块

| 模块 | 原因 |
|------|------|
| 记账解析 prompt | 不改动 `prompt_templates.dart` |
| Agent Runner | 不改动 `agent_runner.dart` |
| Agent 注册表 | 不改动 `agent_registry.dart` |
| 搜索功能 | 无关 |
| 语音输入 | 无关 |
| 图片识别 | 无关 |
| 数据库 schema (Drift) | 聊天记录使用独立 Isar 存储 |
| 现有 Provider/DI | 不需要新 Provider |

### 🆕 新增文件清单

| 文件 | 说明 |
|------|------|
| `lib/features/ai/data/models/ai_persona.dart` | 数据模型 + prompt builder |
| `lib/features/ai/data/models/chat_message_entity.dart` | 🆕 Isar 聊天消息实体 |
| `lib/features/ai/data/storage/persona_storage.dart` | SharedPreferences CRUD |
| `lib/features/ai/data/repository/chat_history_repository.dart` | 🆕 Isar 聊天记录仓库 |
| `lib/features/ai/presentation/pages/persona_list_page.dart` | 角色列表页 |
| `lib/features/ai/presentation/pages/persona_edit_page.dart` | 角色编辑页（含示例+开场白） |

### 🔧 修改文件清单

| 文件 | 改动量 | 说明 |
|------|--------|------|
| `lib/core/ai/transaction_pipeline.dart` | +30 行 | 历史加载 + Prompt 注入 + 消息持久化 + 异步清理 |
| `lib/features/chat/presentation/pages/ai_chat_page.dart` | +25 行 | 初始化加载历史、切换角色重载、流式写入 |
| `lib/config/routes/app_router.dart` | +16 行 | 注册两个新路由 |
| `lib/features/ai/presentation/pages/llm_settings_page_v2.dart` | +10 行 | 添加"AI 角色管理"入口 |
| `lib/l10n/app_zh.arb` | +17 行 | 新增本地化字符串 |
| `pubspec.yaml` | +3 行 | 新增 `isar`, `isar_flutter_libs`, `path_provider` |
| `lib/main.dart` | +5 行 | 应用启动时初始化 Isar |

---

## 9. 开放问题

| 问题 | 方案 |
|------|------|
| 角色回复用的 LLM provider 和记账用的是同一个吗？ | **是**，复用记账用的 provider/model，用户无需额外配置 |
| 记账和角色回复用同一个对话上下文吗？ | **不共享**，角色对话独立持久化到 Isar，不污染记账历史 |
| 用户输入既是记账又是闲聊怎么办？ | 按现有逻辑只走记账通道。System Prompt 中增加防穿透兜底指令，让 LLM 以角色身份回应而非输出 JSON |
| 角色调用 LLM 失败怎么处理？ | 静默回退到原始 LLM 响应，用户无感知 |
| Token 超限怎么办？ | `getRecentMessages` 限制条数（默认 10 轮）；后续可按 token 数动态截断 |
| 聊天记录隐私安全？ | Isar 支持 encrypted box，后续版本可开启加密存储 |
| 是否支持自定义 system prompt（高级用户）？ | 第一期自动生成。第二期可增加"高级模式"让用户直接编辑 prompt |
| Isar 与现有 Drift 共存？ | 完全独立，Isar 仅存储角色聊天记录，Drift 存储业务数据 |

---

## 10. 开发步骤

| # | 步骤 | 内容 | 预估 |
|---|------|------|------|
| 1 | 依赖 | 引入 Isar 依赖 + 初始化配置（`pubspec.yaml` + `main.dart`） | 30min |
| 2 | Model | 创建 `AiPersona` + `DialogueExample` + `buildPersonaPrompt()` | 30min |
| 3 | Model | 创建 `ChatMessageEntity`（Isar collection） | 15min |
| 4 | Storage | 创建 `ChatHistoryRepository`（Isar CRUD） | 1h |
| 5 | Storage | 创建 `PersonaStorage`（SharedPreferences CRUD） | 30min |
| 6 | UI | 实现 `PersonaListPage`（列表 + 选择 + 删除联动清理） | 1.5h |
| 7 | UI | 实现 `PersonaEditPage`（含对话示例 + 开场白表单） | 2h |
| 8 | Pipeline | 集成到 `TransactionPipeline`（历史加载 + 持久化 + 回退） | 1h |
| 9 | Chat | 适配 `AiChatPage`（历史渲染 + 切换重载 + 流式写入 + 开场白） | 1.5h |
| 10 | Route | 添加路由、AI 设置页入口 | 30min |
| 11 | i18n | 添加本地化字符串 | 15min |
| 12 | Test | 端到端验证 | 45min |
| | **合计** | | **约 9h** |

---

> 文档版本: v1.1
> 最后更新: 2026-06-29
> 
> **v1.1 变更**：
> - 新增 Isar 聊天消息实体 + ChatHistoryRepository
> - 引入对话历史持久化机制
> - 新增 Few-Shot 示例支持（DialogueExample）
> - 新增角色开场白（greeting）
> - AiChatPage 适配历史加载/切换/流式写入
> - 新增 Isar 依赖（pubspec.yaml + 初始化）
> - 开发步骤从 5h → 9h
