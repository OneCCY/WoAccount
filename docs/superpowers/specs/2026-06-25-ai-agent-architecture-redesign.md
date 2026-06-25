# AI 配置架构重设计

> **版本**: v2.0 | **日期**: 2026-06-25
> **状态**: 设计完成，待开发
> **范围**: AI 配置系统全链路重构，从能力配置架构升级为 Agent 导向架构
>
> **替代文档**:
> - `docs/superpowers/llm/llm-config.md` (v1.0, 已废弃)
> - `docs/superpowers/llm/llm-overview.md` (v1.0, 已废弃)
> - `docs/superpowers/specs/2026-06-23-per-capability-provider-design.md` (v1.5, 已废弃)

---

## 1. 现状分析

### 1.1 当前架构

```
LlmProvider（供应商）
  ├── apiKey, baseUrl, temperature, maxTokens, timeoutSeconds
  └── models: Map<String, ModelConfig>   ← 模型嵌套在供应商内
        ├── "text"   → ModelConfig(modelName: "deepseek-chat")
        ├── "vision" → ModelConfig(modelName: "gpt-4o")
        └── "audio"  → ModelConfig(modelName: "paraformer-v2")
```

**存储**: SharedPreferences 中 3 个 key：
- `llm_providers` — 所有供应商 JSON 数组
- `llm_active_provider_id` — 活跃供应商 ID
- `llm_fetched_models` — 从 API 拉取的模型列表缓存

**UI 结构**: 两层入口——模型管理（按能力选供应商+模型）和供应商管理（增删改测）。

### 1.2 已识别的问题

| # | 问题 | 影响 |
|---|------|------|
| P1 | 测试连接使用 `getModelForCapability(text)` 获取模型名，未配模型时发送空字符串，必然失败 | 用户无法在配模型前验证供应商连通性 |
| P2 | 供应商与模型紧耦合，`LlmProvider.models` 嵌套模型配置 | 切换供应商时模型配置丢失；换模型不灵活 |
| P3 | 能力（text/vision/audio）是硬编码的，不对应用户可见的业务功能 | 用户不理解"文本能力"是什么；扩展需改代码 |
| P4 | 无容错机制，主模型失败时无备选 | AI 服务不稳定时整个功能不可用 |
| P5 | 无用量追踪和成本感知 | 用户不知道调了多少次、花了多少钱 |
| P6 | Agent/任务概念缺失，所有 text 请求共享一个模型 | 交易解析、AI 搜索、AI 聊天无法独立选择模型 |

---

## 2. 设计目标

1. **Provider 独立** — 供应商只存连接配置，添加后立即可测试连通性，不依赖模型配置
2. **Agent 导向** — 以业务 Agent 为单位配置模型，不暴露技术能力（text/vision/audio）给用户
3. **容错降级** — 主模型失败时自动切换备选，保证可用性
4. **成本感知** — 记录每次调用，提供用量统计
5. **可扩展** — 新增 Agent/Provider/Tool 以数据驱动，无需改架构

---

## 3. 核心理念：从「能力配置」到「Agent 配置」

### 3.1 概念对比

| | 旧：能力配置 | 新：Agent 配置 |
|---|---|---|
| 用户看到 | "文本模型"、"视觉模型"、"音频模型" | "记账解析"、"小票识别"、"财务搜索" |
| 配置粒度 | 一个文本模型用于所有文本请求 | 每个 Agent 独立选模型 |
| 模型切换 | 改 text 能力影响所有功能 | 改记账解析不影响搜索 |
| 扩展方式 | 加枚举值 + 改过滤关键词 + 改 UI | 加 Agent 预置定义即可 |
| 用户理解 | "文本能力是什么意思？" | "记账解析，一看就懂" |

### 3.2 预置 Agent 体系

| Agent ID | 名称 | 图标 | 功能 | 输出 | 推荐配置 | 状态 |
|----------|------|------|------|------|---------|------|
| `transaction_parser` | 记账解析 | 💰 | 从自然语言中提取交易金额、分类、时间 | Transaction JSON | cheap（快速低价） | 已实现 |
| `receipt_ocr` | 小票识别 | 🧾 | 识别小票/发票图片中的消费信息 | Transaction JSON | balanced（均衡） | 已实现 |
| `voice_transcribe` | 语音转写 | 🎤 | 将语音录音转为文字 | String | cheap（快速低价） | 已实现 |
| `finance_search` | 财务搜索 | 🔍 | 自然语言查询交易、预算、分类 | 查询结果 + 回答 | balanced（均衡） | 已实现 |
| `finance_chat` | AI 对话 | 💬 | 多轮对话分析财务数据 | 对话回复 | premium（高质） | 可扩展 |
| `monthly_report` | 月度报告 | 📊 | 生成月度财务总结 | 格式化报告 | premium（高质） | 可扩展 |
| `budget_advisor` | 预算建议 | 📋 | 基于历史消费推荐预算 | 预算建议 | balanced（均衡） | 可扩展 |

### 3.3 Agent 间调用关系

```
语音记账:  voice_transcribe ──→ transaction_parser ──→ 创建交易记录
小票记账:  receipt_ocr       ──→ transaction_parser ──→ 创建交易记录
手动记账:  文本输入          ──→ transaction_parser ──→ 创建交易记录

财务搜索:  finance_search    ──→ 多轮工具调用 ──→ 返回结果
AI 对话:   finance_chat      ──→ 多轮对话 + 工具调用
月度报告:  monthly_report    ──→ 数据聚合 + AI 生成
```

`transaction_parser` 是链路的末端——被多个上游 Agent 复用。配好一次，所有入口共享。

---

## 4. 架构设计

### 4.1 四层模型

```
Layer 0 ┌───────────────────────────────────────────────────────┐
        │              Provider（供应商）                         │
        │  纯连接配置：id, name, apiKey, baseUrl                   │
        │  添加后自动 GET /models 拉取模型列表                      │
        │  唯一职责：能连上、能认证                                 │
        │  与模型和 Agent 完全无关                                  │
        └───────────────────────────────────────────────────────┘
                                      │ references
Layer 1 ┌───────────────────────────────────────────────────────┐
        │              AgentConfig（Agent 用户配置）               │
        │  存储用户对每个 Agent 的个性化设置                        │
        │  agentId → { providerId, modelName, fallback, ... }    │
        │  独立存储，与 Provider 解耦                              │
        └───────────────────────────────────────────────────────┘
                                      │ configures
Layer 2 ┌───────────────────────────────────────────────────────┐
        │              Agent（Agent 预置定义）                     │
        │  预置的不可变定义：id, name, prompt, tools, testCases    │
        │  新增 Agent 无需改存储结构                               │
        │  高级用户可编辑 prompt                                   │
        └───────────────────────────────────────────────────────┘
                                      │ uses
Layer 3 ┌───────────────────────────────────────────────────────┐
        │              AgentRunner（执行引擎）                     │
        │  组装请求 → 主模型调用 → 超时/失败 → 备选降级            │
        │  记录 Trace → 返回结果                                  │
        └───────────────────────────────────────────────────────┘

观测层 ┌───────────────────────────────────────────────────────┐
       │              TraceCollector（用量跟踪）                   │
       │  每次调用的 trace：Agent、Provider、模型、Token、耗时、成本  │
       │  用于统计、模型推荐、预算控制                              │
       └───────────────────────────────────────────────────────┘
```

### 4.2 存储设计

所有配置存储在 SharedPreferences：

```
llm_providers → [
  {
    "id": "p1",
    "name": "DeepSeek",
    "apiKey": "sk-xxx",
    "baseUrl": "https://api.deepseek.com",
    "apiFormat": "openai",
    "temperature": 0.0,
    "maxTokens": 1000,
    "timeoutSeconds": 30,
    "providerKey": "deepseek"
  },
  ...
]

llm_agent_configs → {
  "transaction_parser": {
    "providerId": "p1",
    "modelName": "deepseek-chat",
    "fallbackProviderId": null,
    "fallbackModelName": null,
    "temperature": null,     // null = 使用 Provider 默认值
    "maxTokens": null,
    "timeout": 10
  },
  "finance_search": {
    "providerId": "p1",
    "modelName": "deepseek-chat",
    "fallbackProviderId": "p3",
    "fallbackModelName": "qwen2:7b",
    ...
  },
  ...
}

llm_traces → [
  {
    "id": "t1",
    "agentId": "transaction_parser",
    "providerId": "p1",
    "modelName": "deepseek-chat",
    "timestamp": "2026-06-25T10:30:00",
    "latencyMs": 89,
    "inputTokens": 150,
    "outputTokens": 80,
    "success": true,
    "fallbackUsed": false
  },
  ...
]
```

**关键设计**：
- Provider 不存任何模型信息（`models` map 移除）
- Agent 定义是代码常量（不在 SharedPreferences 中）
- AgentConfig 独立存储，key 为 `llm_agent_configs`
- 新增 Agent 只需加代码常量和 UI 卡片，不需要迁移存储
- Trace 独立存储，可定期清理

---

## 5. 数据模型

### 5.1 Provider

```dart
class AiProvider {
  final String id;           // UUID，创建时生成
  final String name;         // 显示名称
  final String apiKey;       // API 密钥
  final String baseUrl;      // API 端点
  final ApiFormat apiFormat; // openai | anthropic | ...
  final String? providerKey; // 关联预置模板（deepseek/openai/...），自定义为 null
  final double temperature;  // 默认温度
  final int maxTokens;       // 默认最大 Token
  final int timeoutSeconds;  // 默认超时（秒）

  // 注意：不再有 models 字段
  // 注意：不再有 isComplete（Provider 只需 apiKey + baseUrl 非空即可用）
}
```

### 5.2 Agent（预置定义，不可变）

```dart
class AiAgent {
  final String id;                 // "transaction_parser"
  final String nameKey;            // l10n key
  final String descriptionKey;     // l10n key for description
  final String icon;               // "💰"
  final String systemPrompt;       // System prompt
  final List<String> builtinToolIds; // 内置工具 ID 列表
  final JsonSchema outputSchema;   // 结构化输出 schema
  final ModelProfile recommendedProfile; // cheap | balanced | premium
  final List<AgentTestCase> testCases;    // 测试用例
  final int defaultTimeout;        // 默认超时秒数
}

enum ModelProfile { cheap, balanced, premium }
```

### 5.3 AgentConfig（用户配置，存储）

```dart
class AgentConfig {
  final String agentId;              // 关联 Agent
  final String providerId;           // 主供应商
  final String modelName;            // 主模型
  final String? fallbackProviderId;  // 备选供应商
  final String? fallbackModelName;   // 备选模型
  final double? temperature;         // 覆盖默认值（null = 用 Provider 默认）
  final int? maxTokens;              // 覆盖默认值
  final int? timeout;                // 覆盖默认值
  final bool enabled;                // 是否启用
}
```

### 5.4 AgentTestCase

```dart
class AgentTestCase {
  final String input;                     // 测试输入
  final Map<String, dynamic> expectedOutput; // 期望输出
  final List<String> mustIncludeFields;   // 必须包含的字段
}
```

### 5.5 AiTrace（观测数据）

```dart
class AiTrace {
  final String id;
  final String agentId;
  final String providerId;
  final String modelName;
  final DateTime timestamp;
  final int latencyMs;
  final int? inputTokens;
  final int? outputTokens;
  final bool success;
  final String? errorCode;
  final bool fallbackUsed;
  final String? fallbackProviderId;
  final String? fallbackModelName;
}
```

---

## 6. 核心流程

### 6.1 AgentRunner 执行流程

```
用户输入
    │
    ▼
AgentRunner.run(agentId, input)
    │
    ├─ 1. 加载 Agent 预置定义 (prompt, tools, outputSchema)
    ├─ 2. 加载 AgentConfig (providerId, modelName, fallback)
    ├─ 3. 加载 AiProvider
    ├─ 4. 构建请求 (system prompt + tools + input + output schema)
    │
    ▼
┌──────────────────────────────────────┐
│  尝试主模型                           │
│  POST {baseUrl}  + modelName         │
│  timeout: config.timeout             │
└──────────┬───────────────────────────┘
           │
      成功？├─ 是 → 记录 Trace(success) → 返回结果
           │
      否   ▼
┌──────────────────────────────────────┐
│  检查是否有备选模型                    │
│  config.fallbackProviderId != null?  │
└──────────┬───────────────────────────┘
           │
      有备选？├─ 是 → 尝试备选模型
           │        ├─ 成功 → 记录 Trace(success, fallbackUsed=true) → 返回
           │        └─ 失败 → 记录 Trace(failure) → 抛出异常
           │
      无备选 ▼
      记录 Trace(failure) → 抛出异常
```

### 6.2 测试连接流程（分层验证）

```
Level 1: 供应商连通性测试
  │
  ├─ 判断 apiFormat:
  │   ├─ OpenAI: GET {baseUrl}/models
  │   │           Headers: Authorization: Bearer {apiKey}
  │   │           → 200 OK = 连通
  │   │
  │   └─ Anthropic: GET {baseUrl}/models
  │                  Headers: x-api-key: {apiKey}
  │                  → 200 OK = 连通
  │
  └─ 优势：不依赖任何模型配置，只需 apiKey + baseUrl

Level 2: 模型可用性测试（AgentConfig 保存时触发）
  │
  ├─ POST {baseUrl}/chat/completions
  │   Body: { model: "{modelName}", messages: [...], max_tokens: 10 }
  │   → 200 OK = 该模型在该供应商上可用
  │
  └─ 触发时机：用户选择模型并保存时

Level 3: 任务适配性测试（Agent 编辑页手动触发）
  │
  ├─ 发送 Agent 的 testCases 中的第一个用例
  │   body: { model: "{modelName}", messages: [{system_prompt + test_input}] }
  │   → 检查输出是否符合 outputSchema
  │
  └─ 用户可一键运行全部测试用例，查看通过率
```

### 6.3 供应商添加后自动拉取模型

```
添加 Provider
  │
  ├─ 保存 Provider → SharedPreferences
  │
  ├─ GET {baseUrl}/models （用 apiKey 认证）
  │   ├─ 成功 → 解析模型列表 [{id, owned_by, ...}]
  │   │         → 按能力关键词过滤分组
  │   │         → 缓存到 SharedPreferences
  │   │         → UI 模型中下拉框自动填充
  │   │
  │   └─ 失败 → 标记模型列表为空
  │              → UI 中用户需手动输入模型名
  │
  └─ 自动跑一次 Level 1 连通性测试 → 显示状态
```

---

## 7. UI 设计

### 7.1 主入口：AI 设置页

```
┌────────────────────────────────────────┐
│  ← AI 设置                             │
│                                        │
│  ┌─ 供应商 ─────────────────── 3 个 ─┐ │
│  │                                    │ │
│  │  🟢 DeepSeek                       │ │
│  │     api.deepseek.com   延迟: 89ms  │ │
│  │     [测试] [编辑]                  │ │
│  │                                    │ │
│  │  🟢 OpenAI                         │ │
│  │     api.openai.com     延迟: 230ms │ │
│  │     [测试] [编辑]                  │ │
│  │                                    │ │
│  │  🔴 Ollama                         │ │
│  │     localhost:11434     未连接      │ │
│  │     [测试] [编辑]                  │ │
│  │                                    │ │
│  │  [+ 添加供应商]                     │ │
│  └────────────────────────────────────┘ │
│                                        │
│  ┌─ 功能配置 ────────────────────────┐ │
│  │                                    │ │
│  │  💰 记账解析                       │ │
│  │     DeepSeek / deepseek-chat       │ │
│  │     备选: Ollama / qwen2:7b       │ │
│  │     测试: 5/5 通过 ✅          ▸  │ │
│  │                                    │ │
│  │  🔍 财务搜索                       │ │
│  │     DeepSeek / deepseek-chat       │ │
│  │     备选: 无                   ▸  │ │
│  │                                    │ │
│  │  🎤 语音转写                       │ │
│  │     DeepSeek / paraformer-v2       │ │
│  │     备选: 无                   ▸  │ │
│  │                                    │ │
│  │  🧾 小票识别                       │ │
│  │     OpenAI / gpt-4o                │ │
│  │     备选: 无                   ▸  │ │
│  │                                    │ │
│  └────────────────────────────────────┘ │
│                                        │
│  ┌─ 本月用量 ───────────────────────┐ │
│  │  调用: 128 次                     │ │
│  │  预估费用: ¥0.87                  │ │
│  │  ▇▇▇▇▇▇▇▇░░░░░░ 40%             │ │
│  └────────────────────────────────────┘ │
└────────────────────────────────────────┘
```

### 7.2 供应商编辑页

```
┌────────────────────────────────────┐
│  ← 添加供应商                       │
│                                    │
│  预设模板                           │
│  ┌────────────────────────────────┐│
│  │ DeepSeek                   ▸  ││
│  └────────────────────────────────┘│
│                                    │
│  API Key                           │
│  ┌────────────────────────────────┐│
│  │ sk-xxxxxxxx               👁  ││
│  └────────────────────────────────┘│
│                                    │
│  API 地址                          │
│  ┌────────────────────────────────┐│
│  │ https://api.deepseek.com       ││
│  └────────────────────────────────┘│
│                                    │
│  ┌─ 高级设置（展开）──────────────┐│
│  │ 温度: 0.0  ├──●─────────────┤ ││
│  │ 最大Token: 1000                ││
│  │ 超时: 30秒                     ││
│  └────────────────────────────────┘│
│                                    │
│  连通性: 🟢 已连接 (89ms)          │
│  [测试连接]                        │
│                                    │
│  [保存]                            │
└────────────────────────────────────┘
```

**交互变更**：
- 保存时自动跑 Level 1 测试，显示结果
- 不要求配置模型（模型在 Agent 配置页选择）
- 预设模板自动填 url

### 7.3 Agent 配置页

```
┌────────────────────────────────────┐
│  ← 记账解析                         │
│                                    │
│  从自然语言中提取交易金额、分类、时间  │
│  推荐级别：快速低价（cheap）         │
│                                    │
│  ┌─ 主模型 ──────────────────────┐ │
│  │ 供应商：[DeepSeek       ▼]    │ │
│  │ 模型：  [deepseek-chat   ▼]   │ │
│  │         (从 API 拉取或手动输入) │ │
│  └───────────────────────────────┘ │
│                                    │
│  ┌─ 备选模型 ────────────────────┐ │
│  │ ☑ 启用自动降级                │ │
│  │ 供应商：[Ollama         ▼]    │ │
│  │ 模型：  [qwen2:7b       ▼]   │ │
│  │ 超时：  [5]  秒               │ │
│  └───────────────────────────────┘ │
│                                    │
│  ┌─ 测试 ────────────────────────┐ │
│  │ 用例 1: "今天买菜50"           │ │
│  │   → expense, 50, grocery      │ │
│  │   🟢 通过 (89ms)              │ │
│  │                                │ │
│  │ 用例 2: "工资8000到账"         │ │
│  │   → income, 8000, salary      │ │
│  │   🟢 通过 (92ms)              │ │
│  │                                │ │
│  │ [运行全部测试]                  │ │
│  └────────────────────────────────┘ │
│                                    │
│  ┌─ 高级（展开）─────────────────┐ │
│  │ 温度覆盖：(使用默认)           │ │
│  │ MaxToken覆盖：(使用默认)       │ │
│  │ Prompt 预览/编辑               │ │
│  └────────────────────────────────┘ │
│                                    │
│  [保存]                            │
└────────────────────────────────────┘
```

**交互**：
- 选择供应商后，自动尝试从 API 拉取模型列表填充下拉框
- 如果拉取失败，下拉框允许手动输入模型名
- 选择模型后自动跑 Level 2 测试
- "运行全部测试"跑所有 testCases，显示通过率
- 高级用户可展开编辑 prompt

### 7.4 首次使用引导

```
用户首次使用"语音记账"功能
  │
  ▼
┌────────────────────────────────┐
│  🤖 语音记账需要配置 AI 服务    │
│                                │
│  需要配置 2 项：                │
│  🎤 语音转写 → 推荐 cheap     │
│  💰 记账解析  → 推荐 cheap     │
│                                │
│  [一键推荐配置]                 │
│  [手动配置]                     │
└────────────────────────────────┘
  │
  ├─ 一键推荐：
  │   检查已有 Provider
  │   ├─ 有 Provider → 自动分配最优模型
  │   └─ 无 Provider → 引导添加（推荐 DeepSeek，免费/低价）
  │
  └─ 手动配置：
      跳转到 AI 设置页
```

---

## 8. 容错与降级

### 8.1 降级链

```
请求: AgentRunner.run("transaction_parser", "今天买菜50")
  │
  ├─ 1. 加载配置: providerId=p1(DeepSeek), model=deepseek-chat
  │                     fallback=p3(Ollama), model=qwen2:7b
  │
  ├─ 2. 尝试主模型 DeepSeek/deepseek-chat
  │     POST → 3秒超时 → TimeoutException
  │
  ├─ 3. 降级到备选 Ollama/qwen2:7b
  │     POST → 成功 (180ms)
  │     → 记录 Trace: success=true, fallbackUsed=true
  │     → 返回结果
  │
  └─ 如果备选也失败：
       记录 Trace: success=false
       → 连续失败 3 次 → 通知用户 + 建议检查配置
```

### 8.2 降级触发条件

| 条件 | 行为 |
|------|------|
| 请求超时 | 立即切备选 |
| HTTP 5xx | 立即切备选 |
| HTTP 429 (限流) | 立即切备选 |
| HTTP 401 (认证失败) | 不降级（密钥问题，换模型也没用） |
| 响应解析失败 | 切备选 |

### 8.3 健康检查

后台定时（每 5 分钟）对活跃 Agent 的主模型发健康检查请求。连续失败 3 次自动标记为 degraded，UI 上显示警告。

---

## 9. 用量追踪

### 9.1 记录内容

每笔 AI 调用记录：
- Agent ID、Provider、模型名
- 时间戳、耗时
- Input/Output Token 数（从 API 响应提取）
- 成功/失败、错误码、是否使用了备选

### 9.2 统计维度

| 维度 | 用途 |
|------|------|
| 按 Agent 统计 | 哪个 Agent 调用最多 |
| 按 Provider 统计 | 哪个供应商花费最多 |
| 按时间统计 | 本月调用趋势 |
| 成功率 | 主模型 vs 备选模型成功率 |
| 平均延迟 | 哪个模型最快 |
| 预估费用 | 基于 Token 用量 × 单价 |

### 9.3 智能推荐

基于 Trace 数据自动给出建议：
- "DeepSeek 成功率 100%，平均延迟 89ms → 推荐继续使用"
- "Ollama 近 7 天延迟升高至 3s → 建议检查本地服务"
- "本月 AI 费用已用 ¥0.87，远低于预算 ¥10 → 可尝试 premium 模型"

---

## 10. 代码结构设计

```
lib/features/ai/
├── data/
│   ├── models/
│   │   ├── ai_provider.dart          # AiProvider 数据类
│   │   ├── ai_agent.dart             # AiAgent 预置定义（不可变）
│   │   ├── agent_config.dart         # AgentConfig 用户配置
│   │   ├── agent_test_case.dart      # AgentTestCase
│   │   ├── ai_trace.dart             # AiTrace 追踪记录
│   │   └── provider_preset.dart      # ProviderPreset 预置模板
│   ├── repositories/
│   │   ├── llm_repository_impl.dart   # API 调用实现
│   │   └── model_fetcher.dart         # 从 API 拉取模型列表
│   └── storage/
│       ├── provider_storage.dart      # Provider CRUD (SharedPreferences)
│       ├── agent_config_storage.dart  # AgentConfig CRUD
│       └── trace_storage.dart         # Trace 记录与查询
├── domain/
│   ├── repositories/
│   │   └── llm_repository.dart        # 领域接口
│   ├── agent_runner.dart              # Agent 执行引擎
│   ├── agent_registry.dart            # Agent 注册表（预置定义）
│   └── tool_registry.dart             # Tool 注册表
└── presentation/
    ├── pages/
    │   ├── llm_settings_page.dart      # AI 设置主入口
    │   ├── supplier_management_page.dart  # 供应商管理
    │   ├── provider_edit_page.dart     # 供应商编辑
    │   ├── agent_list_page.dart        # 功能配置列表
    │   └── agent_edit_page.dart        # Agent 配置编辑
    └── widgets/
        ├── connection_status_badge.dart
        ├── model_selector.dart
        └── test_case_runner.dart
```

---

## 11. 数据迁移

### 11.1 旧格式 → 新格式

旧存储结构：
```json
// llm_providers (旧)
[{
  "id": "p1",
  "name": "DeepSeek",
  "apiKey": "sk-xxx",
  "baseUrl": "https://api.deepseek.com",
  "models": {
    "text": { "modelName": "deepseek-chat" },
    "audio": { "modelName": "paraformer-v2" }
  }
}]
```

迁移逻辑：
```dart
Future<void> migrateFromV1() async {
  final oldProviders = await loadProviders(); // 旧 LlmProvider 含 models

  // 1. 提取 agent_configs
  for (final provider in oldProviders) {
    for (final entry in provider.models.entries) {
      final capability = entry.key;       // "text", "vision", "audio"
      final modelConfig = entry.value;    // ModelConfig
      final agentId = _capabilityToAgentId(capability); // text→transaction_parser 等

      // 只有 modelName 非空且没有已配置的 Agent 才迁移
      if (modelConfig.modelName.isNotEmpty && agentId != null) {
        final existing = await loadAgentConfig(agentId);
        if (existing == null) {
          await saveAgentConfig(AgentConfig(
            agentId: agentId,
            providerId: provider.id,
            modelName: modelConfig.modelName,
          ));
        }
      }
    }
  }

  // 2. 保存不含 models 的 Provider
  final newProviders = oldProviders.map((p) => AiProvider(
    id: p.id,
    name: p.name,
    apiKey: p.apiKey,
    baseUrl: p.baseUrl,
    // ... 其他字段
    // 不包含 models
  ));
  await saveProviders(newProviders);

  // 3. 标记已迁移
  await setConfigVersion(2);
}

// 能力 → Agent 映射（只有唯一的映射才自动迁移）
String? _capabilityToAgentId(String capability) {
  switch (capability) {
    case 'text': return 'transaction_parser'; // 唯一 text Agent
    case 'vision': return 'receipt_ocr';       // 唯一 vision Agent
    case 'audio': return 'voice_transcribe';   // 唯一 audio Agent
    default: return null;
  }
}
```

### 11.2 兼容性

- 旧数据自动迁移，用户无感知
- 使用 `llm_config_version` 标记版本
- 迁移后旧 `models` 字段从存储中移除
- `llm_active_provider_id` 不再使用，但保留不删（兼容旧代码读取）

---

## 12. 安全与隐私

### 12.1 API Key 存储

| 当前 | 建议 |
|------|------|
| SharedPreferences 明文 | `flutter_secure_storage`（系统密钥链） |

### 12.2 Trace 数据

- 只存储本地，不上传
- 用户可一键清除
- Token 用量统计不含原始输入/输出内容

---

## 13. 实施计划

### Phase 1：解耦与修复（2-3 天）

| 任务 | 文件 | 说明 |
|------|------|------|
| AiProvider 去掉 models | `llm_config.dart` | 重构数据类，新增 AiProvider |
| AgentConfig 数据类 | `agent_config.dart` | 新建 AgentConfig + 存储 |
| 测试连接改用 /models | `llm_repository_impl.dart` | testConnection 不再依赖模型 |
| Agent 预置定义 | `agent_registry.dart` | 定义 4 个已有 Agent + testCases |
| 数据迁移 | `llm_config.dart` | migrateFromV1() |
| 更新服务层调用 | `voice_recognition_service.dart` 等 | 改用 AgentConfig + AgentRunner |

### Phase 2：UI 重建（2-3 天）

| 任务 | 说明 |
|------|------|
| AI 设置主入口 | 新主页面，显示供应商列表 + Agent 配置列表 |
| 供应商管理页 | 仅管理连接配置，测试只验连通性 |
| Agent 配置页 | 选主模型 + 备选 + 测试用例运行 |
| 移除旧能力配置页 | 删除 model_management_page、capability_config_page |

### Phase 3：增强（3-5 天）

| 任务 | 说明 |
|------|------|
| AgentRunner 完整实现 | 带主备降级的执行引擎 |
| TraceCollector | 用量记录与统计 |
| Agent 自动拉取模型 | Provider 保存后自动 GET /models |
| 首次使用引导 | 功能入口检测未配置 Agent 时弹出引导 |

### Phase 4：生态扩展（长期）

| 任务 | 说明 |
|------|------|
| Tool Registry | 注册 getCategories/getTransactions 等工具 |
| 新 Agent 扩展 | 月度报告、预算建议、分类推荐 |
| 成本面板 | 月度用量图表 + 费用估算 |
| Agent 社区 | 导入/导出 Agent 配置 |
| 本地模型优先 | Ollama 作为更优的降级方案 |

---

## 14. 预置 Agent 完整定义

### 14.1 transaction_parser（记账解析）

```dart
AiAgent(
  id: 'transaction_parser',
  nameKey: 'agentTransactionParser',
  descriptionKey: 'agentTransactionParserDesc',
  icon: '💰',
  recommendedProfile: ModelProfile.cheap,
  defaultTimeout: 10,
  builtinToolIds: ['get_categories', 'get_exchange_rate'],
  outputSchema: JsonSchema({
    'type': 'object',
    'properties': {
      'type': {'type': 'string', 'enum': ['expense', 'income', 'transfer']},
      'amount': {'type': 'number'},
      'category': {'type': 'string'},
      'subcategory': {'type': 'string'},
      'date': {'type': 'string', 'format': 'date'},
      'note': {'type': 'string'},
      'confidence': {'type': 'number'},
    },
    'required': ['type', 'amount', 'category'],
  }),
  systemPrompt: '...',  // 当前已有的 prompt
  testCases: [
    AgentTestCase(
      input: '今天买菜花了50',
      expectedOutput: {'type': 'expense', 'amount': 50},
      mustIncludeFields: ['type', 'amount', 'category'],
    ),
    AgentTestCase(
      input: '工资到账8000',
      expectedOutput: {'type': 'income', 'amount': 8000},
      mustIncludeFields: ['type', 'amount', 'category'],
    ),
  ],
);
```

### 14.2 receipt_ocr（小票识别）

```dart
AiAgent(
  id: 'receipt_ocr',
  nameKey: 'agentReceiptOcr',
  descriptionKey: 'agentReceiptOcrDesc',
  icon: '🧾',
  recommendedProfile: ModelProfile.balanced,
  defaultTimeout: 15,
  builtinToolIds: [],
  outputSchema: TransactionSchema, // 复用
  systemPrompt: '...',  // 当前已有的 prompt
  testCases: [...],
);
```

### 14.3 voice_transcribe（语音转写）

```dart
AiAgent(
  id: 'voice_transcribe',
  nameKey: 'agentVoiceTranscribe',
  descriptionKey: 'agentVoiceTranscribeDesc',
  icon: '🎤',
  recommendedProfile: ModelProfile.cheap,
  defaultTimeout: 30,
  builtinToolIds: [],
  outputSchema: JsonSchema({
    'type': 'object',
    'properties': {'text': {'type': 'string'}},
    'required': ['text'],
  }),
  systemPrompt: '',  // 转写不需要 system prompt
  testCases: [],     // 转写无法用静态文本测试
);
```

### 14.4 finance_search（财务搜索）

```dart
AiAgent(
  id: 'finance_search',
  nameKey: 'agentFinanceSearch',
  descriptionKey: 'agentFinanceSearchDesc',
  icon: '🔍',
  recommendedProfile: ModelProfile.balanced,
  defaultTimeout: 15,
  builtinToolIds: ['get_transactions', 'get_budgets', 'get_categories', 'calculate_total'],
  outputSchema: null, // 搜索不要求结构化输出
  systemPrompt: '...',
  testCases: [...],
);
```

---

## 15. 配置示例

### 最小配置（只需一个免费供应商）

```json
// llm_providers
[{
  "id": "p1",
  "name": "DeepSeek",
  "apiKey": "sk-xxx",
  "baseUrl": "https://api.deepseek.com",
  "apiFormat": "openai",
  ...
}]

// llm_agent_configs
{
  "transaction_parser": {
    "providerId": "p1",
    "modelName": "deepseek-chat"
  },
  "finance_search": {
    "providerId": "p1",
    "modelName": "deepseek-chat"
  },
  "voice_transcribe": {
    "providerId": "p1",
    "modelName": "paraformer-v2"
  }
}
```

### 完整配置（多供应商 + 主备）

```json
// llm_providers
[
  { "id": "p1", "name": "DeepSeek", ... },   // 主力：便宜快速
  { "id": "p2", "name": "OpenAI", ... },     // 视觉：GPT-4o
  { "id": "p3", "name": "Ollama", ... }      // 备选：本地免费
]

// llm_agent_configs
{
  "transaction_parser": {
    "providerId": "p1",
    "modelName": "deepseek-chat",
    "fallbackProviderId": "p3",
    "fallbackModelName": "qwen2:7b",
    "timeout": 10
  },
  "receipt_ocr": {
    "providerId": "p2",
    "modelName": "gpt-4o",
    "fallbackProviderId": null,
    "timeout": 15
  },
  "voice_transcribe": {
    "providerId": "p1",
    "modelName": "paraformer-v2",
    "fallbackProviderId": null,
    "timeout": 30
  },
  "finance_search": {
    "providerId": "p1",
    "modelName": "deepseek-chat",
    "fallbackProviderId": "p3",
    "fallbackModelName": "qwen2:7b",
    "timeout": 15
  }
}
```

---

## 变更记录

| 日期 | 版本 | 变更 |
|------|------|------|
| 2026-06-04 | v1.0 | 初始设计，单供应商单模型 |
| 2026-06-23 | v1.5 | 增加能力独立供应商选择 |
| 2026-06-25 | v2.0 | Agent 导向架构重设计，Provider 解耦，主备降级，Trace 追踪 |
