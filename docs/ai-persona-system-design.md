# AI 角色管理系统 — 设计文档

## 1. 背景

### 1.1 当前问题

WoAccount 的 AI 记账功能使用严格的记账解析 prompt，要求 LLM 仅输出结构化 JSON。当用户输入**非记账内容**（如"你好"、"今天心情不错"、"讲个笑话"）时：

- LLM 不知道以什么角色回应
- 返回的 raw response 只是通用 LLM 默认回答，**没有个性，没有温度**
- 当前已有 `nonTransactionResponse` 字段（[`PipelineResult`](lib/core/ai/transaction_pipeline.dart#L38-L62)）和处理逻辑（[`ai_chat_page.dart:336`](lib/features/chat/presentation/pages/ai_chat_page.dart#L336-L358)），但缺少角色人格的定义和注入

### 1.2 目标

用户可预设多个 AI 角色，选择其中一个激活。当输入非记账内容时，AI 以所选角色身份给出个性化回复。

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
  │     用角色 prompt  返回原始 LLM 响应
  │     二次调用 LLM   （保持当前行为）
  │           │
  │           ▼
  │     角色化回复
  │
  └──→ nonTransactionResponse 返回给 UI 显示
```

### 2.2 分层职责

| 层级 | 模块 | 职责 |
|------|------|------|
| **Model** | `AiPersona` | 角色数据模型（id、name、avatar、description） |
| **Storage** | `PersonaStorage` | SharedPreferences 持久化 CRUD |
| **Pipeline** | `TransactionPipeline` | 非记账检测 → 角色 prompt 注入 → 二次 LLM 调用 |
| **UI** | `PersonaListPage` | 角色列表、选择激活、删除 |
| **UI** | `PersonaEditPage` | 新建/编辑角色（名称、头像、性格描述） |
| **Route** | `AppRouter` | 注册两个新路由 |

---

## 3. 数据层设计

### 3.1 数据模型

```dart
/// AI 角色定义
class AiPersona {
  final String id;          // UUID
  final String name;        // 角色名称，如"温柔知心"
  final String avatar;      // emoji 头像，如 🧚
  final String description; // 性格描述（自然语言）
  final bool isDefault;     // 是否默认选中
  final int sortOrder;      // 排序值

  // 自动从 description 生成 system prompt（runtime 计算，不存储）
  String get systemPrompt => buildPersonaPrompt(name, description);
}

/// 从性格描述生成角色 system prompt
String buildPersonaPrompt(String name, String description) {
  return '''你正在进行角色扮演，请始终以设定的角色身份回应用户。

角色名称：$name

角色性格：$description

## 规则
1. 完全以该角色的身份语气说话，保持一致
2. 回复简洁自然，像日常对话
3. 不要提及你是一个 AI 或语言模型
4. 使用与用户相同的语言回复''';
}
```

### 3.2 存储方案

使用 `SharedPreferences`，与 `AgentConfigStorage` 一致，**无需数据库迁移**。

| Key | Value | 说明 |
|-----|-------|------|
| `ai_personas` | `Map<String, AiPersona>` 的 JSON | 所有角色数据 |
| `ai_persona_active` | `String?` | 当前激活的角色 ID |

**Storage API：**

```dart
class PersonaStorage {
  static Future<List<AiPersona>> loadAll();
  static Future<void> save(AiPersona persona);
  static Future<void> delete(String id);
  static Future<String?> getActiveId();
  static Future<void> setActiveId(String? id);
  static Future<AiPersona?> getActive();
}
```

### 3.3 DB 设计决策

| 对比项 | SharedPreferences | SQLite |
|--------|-------------------|--------|
| 迁移成本 | 零 | 需 migration |
| 数据结构 | 简单 key-value | 关系型 |
| 数据量 | 极少（最多 5-10 个角色） | 大 |
| 结论 | ✅ 选用 | ❌ 过度设计 |

---

## 4. Pipeline 集成设计

### 4.1 修改点

仅修改 [`transaction_pipeline.dart:207-217`](lib/core/ai/transaction_pipeline.dart#L207-L217) 处的异常捕获逻辑。

### 4.2 伪代码

```dart
} on LlmException catch (e) {
  if (e.errorCode == 'llmErrorNonTransaction') {
    // [新增] 检测是否有激活的角色
    final activePersona = await PersonaStorage.getActive();
    if (activePersona != null) {
      try {
        // 用角色的 system prompt 调用 LLM
        final personaResponse = await _llmRepo.chat(
          LlmRequest(
            messages: [
              ChatMessage(role: 'system', content: activePersona.systemPrompt),
              ChatMessage(role: 'user', content: text),
            ],
            // 复用相同的 provider
          ),
          provider: provider,
        );
        return PipelineResult(
          normalizedText: text,
          transactions: const [],
          source: InputSource.text,
          nonTransactionResponse: personaResponse.content,
        );
      } catch (_) {
        // 角色调用失败，回退到原始 LLM 响应
      }
    }
    // 无角色 或 角色调用失败时返回原始响应
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
- ✅ `ai_chat_page.dart` UI 层不变
- ✅ Provider/DI 注入不变

---

## 5. UI 设计

### 5.1 页面结构

```
AI 设置页 (llm_settings_page_v2.dart)
  │
  ├── 供应商管理 → ...
  ├── Agent 配置 → ...
  ├── 使用统计 → ...
  └── [新增] AI 角色管理 → PersonaListPage
                                │
                          ┌─────┴──────┐
                          │            │
                    PersonaEditPage  删除确认弹窗
                    (新建/编辑)
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

组件说明：
- 顶部"不启用"选项：选中时 personaStorage.setActiveId(null)
- 每个角色卡片：点击=选中，✏️=编辑，🗑️=删除（带确认弹窗）
- 空状态："还没有创建角色哦～点击右上角 + 创建第一个角色吧！"
```

### 5.3 角色编辑页 (PersonaEditPage)

```
┌────────────────────────────────────────┐
│ ← 新建角色                    [💾 保存] │
├────────────────────────────────────────┤
│                                        │
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
│ ┌────────────────────────────────────┐ │
│ │ 💡 角色性格越具体，AI 表现越鲜明！ │ │
│ │ 建议包含：语气（温柔/幽默/犀利）、 │ │
│ │ 说话风格（简洁/啰嗦）、习惯用语等  │ │
│ └────────────────────────────────────┘ │
│                                        │
└────────────────────────────────────────┘
```

### 5.4 交互逻辑

| 操作 | 行为 |
|------|------|
| 点击角色卡片 | 设为当前选中角色 + `PersonaStorage.setActiveId()` |
| 点击 ✏️ | 导航到 `PersonaEditPage` 编辑模式 |
| 点击 🗑️ | 弹出确认弹窗 → 确认后删除 + 如果该角色是当前激活的，自动清空激活 ID |
| 点击 [+添加] | 导航到 `PersonaEditPage` 新建模式 |
| 编辑页保存 | 校验名称非空 → `PersonaStorage.save()` → 返回列表页 |

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

`app_zh.arb` 新增约 8 个 key：

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
| `aiPersonaDeleteConfirm` | 确定删除角色"{name}"吗？ |
| `aiPersonaEmpty` | 还没有创建角色哦～ |
| `aiPersonaNameRequired` | 请输入角色名称 |
| `aiPersonaTip` | 角色性格越具体，AI 表现越鲜明！建议包含语气、说话风格、习惯用语等 |

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
| 数据库 schema | 不需要 migration |
| 现有 Provider/DI | 不需要新 Provider |
| Chat UI | 不改动 `ai_chat_page.dart` |

### 🆕 新增文件清单

| 文件 | 说明 |
|------|------|
| `lib/features/ai/data/models/ai_persona.dart` | 数据模型 + prompt builder |
| `lib/features/ai/data/storage/persona_storage.dart` | SharedPreferences CRUD |
| `lib/features/ai/presentation/pages/persona_list_page.dart` | 角色列表页 |
| `lib/features/ai/presentation/pages/persona_edit_page.dart` | 角色编辑页 |

### 🔧 修改文件清单

| 文件 | 改动量 | 说明 |
|------|--------|------|
| `lib/core/ai/transaction_pipeline.dart` | +15 行 | `llmErrorNonTransaction` 捕获处注入角色 prompt |
| `lib/config/routes/app_router.dart` | +16 行 | 注册两个新路由 |
| `lib/features/ai/presentation/pages/llm_settings_page_v2.dart` | +10 行 | 添加"AI 角色管理"入口 |
| `lib/l10n/app_zh.arb` | +12 行 | 新增本地化字符串 |
| `lib/l10n/app_localizations_zh.dart` | +36 行 | 对应生成的 Dart 代码 |
| `lib/l10n/app_localizations.dart` | +12 行 | 抽象类新增方法 |

---

## 9. 开放问题

| 问题 | 方案 |
|------|------|
| 角色回复用的 LLM provider 和记账用的是同一个吗？ | **是**，复用记账用的 provider/model，用户无需额外配置 |
| 记账和角色回复用同一个对话上下文吗？ | **不共享**，角色回复单独一轮调用，不污染记账的对话历史 |
| 用户输入既是记账又是闲聊怎么办？ | 按现有逻辑只走记账通道。角色仅在纯非记账输入时触发 |
| 角色调用 LLM 失败怎么处理？ | 静默回退到原始 LLM 响应，用户无感知 |
| 是否支持自定义 system prompt（高级用户）？ | 第一期自动生成。第二期可增加"高级模式"让用户直接编辑 prompt |

---

## 10. 开发步骤

| 步骤 | 内容 | 预估 |
|------|------|------|
| 1 | 创建 `AiPersona` 模型 + `buildPersonaPrompt()` | 30min |
| 2 | 创建 `PersonaStorage`（SharedPreferences CRUD） | 30min |
| 3 | 实现 `PersonaListPage`（列表 + 选择 + 删除） | 1.5h |
| 4 | 实现 `PersonaEditPage`（新建/编辑表单） | 1.5h |
| 5 | 集成到 `TransactionPipeline` | 30min |
| 6 | 添加路由、AI 设置页入口 | 30min |
| 7 | 添加本地化字符串 | 15min |
| 8 | 端到端验证 | 30min |
| | **合计** | **约 5h** |

---

> 文档版本: v1.0
> 最后更新: 2026-06-29
