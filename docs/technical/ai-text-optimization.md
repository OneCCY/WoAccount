# AI 文本记账优化方案

> 目标：提升文本识别准确度、降低延迟、增强鲁棒性
> 涉及文件：`prompt_templates.dart`、`llm_repository_impl.dart`、`rule_engine.dart`、`ai_chat_page.dart`

---

## 优化项 1：规则引擎分类名与数据库对齐

**问题**: `rule_engine.dart` 硬编码的分类名（如 `'餐饮'`、`'交通'`）与 seed data 中的实际分类名（`'餐饮美食'`、`'交通出行'`）不一致，降级时依赖 `contains` 模糊匹配碰巧成功。

**文件**: `lib/core/ai/rule_engine.dart:19-98`

**方案**:
- 将 `_rules` 中所有 `category` 字段改为与 seed data 一致的精确名称
- 同步修正 `subcategory` 字段与 seed data 中的二级分类名一致
- 在 `CategoryRule` 中增加 `categoryKey` 字段（对应 seed data 的 l10nKey），用于未来本地化

**改动**:
```
'餐饮'  → '餐饮美食'
'交通'  → '交通出行'
'住房'  → '居住'
'购物'  → '服饰美容' / '日用百货'  (需拆分，原规则混合了两类)
'娱乐'  → '休闲娱乐'
'教育'  → '教育学习'
'医疗'  → '医疗健康'
'社交'  → '社交人情'
'工资'  → '工资薪酬'
'奖金'  → '工资薪酬' (奖金是工资薪酬的子分类)
'退款'  → '报销退款'
'兼职'  → '副业兼职'
```

同步修正 subcategory（对照 `category_seed_data.dart`）:
```
'餐食'  → '聚餐请客' 或最接近的子分类
'面食'  → '午餐' (面食不是独立子分类)
'外卖'  → '外卖'
'公交地铁' → '地铁' / '公交' (拆分为两条规则)
```

**验证**: 规则引擎解析 "午饭拉面25" 应返回 `category: '餐饮美食'`, `subcategory: '午餐'`

---

## 优化项 2：分类匹配 fallback 策略降级

**问题**: `ai_chat_page.dart:464-467` 当 LLM 返回的分类名无法匹配时，直接 fallback 到同类型第一个分类（通常是"餐饮美食"），用户不注意就存错。

**文件**: `lib/features/chat/presentation/pages/ai_chat_page.dart:447-468`

**方案**:
- 移除第 3 级 fallback（"返回同类型第一个分类"）
- 改为：精确匹配 → 包含匹配 → **返回 null + 标记不确定**
- 在 `_processInput` 第 375-407 行的循环中，当 `_matchCategory` 返回 null 时：
  - confidence 强制设为 0.3
  - 在 ConfirmCard 上显示醒目的"⚠️ 分类不确定，请手动选择"提示
- 对 `_matchSubcategory`（第 470-499 行）同样处理：不再自动创建未知子分类，改为提示用户选择

**新增**:
- `ConfirmData` 增加 `bool categoryUncertain` 字段
- `ConfirmCard` UI 增加不确定状态的视觉样式（黄色边框 + 选择器高亮）

**验证**: 输入 "foobarxyz 25"，LLM 返回不存在的分类名 → ConfirmCard 显示警告，不自动选分类

---

## 优化项 3：响应 JSON 解析鲁棒性增强

**问题**: `llm_repository_impl.dart:432` 的正则 `(\[[\s\S]*\]|\{[\s\S]*\})` 使用贪婪匹配，遇到 LLM 输出前后附带文字或 JSON 值中含 `]` 时可能截断错误。

**文件**: `lib/features/ai/data/repositories/llm_repository_impl.dart:429-453`

**方案**:
- 替换正则提取为括号计数器算法：
  1. 找到第一个 `[` 或 `{` 的位置
  2. 从该位置开始，用计数器追踪 `[`/`]` 和 `{`/`}` 的配对
  3. 计数器归零时即为 JSON 结束位置
- 增加 JSON 解析失败后的 retry 逻辑：如果解析失败，尝试 `jsonDecode` 整个 response（某些模型直接返回纯 JSON）
- 增加 `amount` 字段的类型宽容处理：接受 `String` 类型的数字（`"25.5"` → `25.5`），避免 LLM 返回 `"amount": "25"` 时崩溃

**新增辅助方法**:
```dart
/// 从 LLM 响应中提取 JSON 字符串（括号计数器算法）
String? _extractJson(String content) {
  final start = content.indexOf(RegExp(r'[\[{]'));
  if (start == -1) return null;
  final opener = content[start];
  final closer = opener == '[' ? ']' : '}';
  int depth = 0;
  for (int i = start; i < content.length; i++) {
    if (content[i] == opener) depth++;
    if (content[i] == closer) depth--;
    if (depth == 0) return content.substring(start, i + 1);
  }
  return null;
}
```

**验证**: LLM 返回 `"这是结果：[{\"amount\":25}] 希望有帮助"` → 正确提取 `[{"amount":25}]`

---

## 优化项 4：分类匹配引入编辑距离容错

**问题**: LLM 返回 "餐饮美食" 但数据库中是 "餐饮美食"（完全匹配没问题），但 LLM 返回 "餐食" 或 "吃饭" 时 `contains` 匹配全部失败，触发激进 fallback。

**文件**: `lib/features/chat/presentation/pages/ai_chat_page.dart:456-467`

**方案**:
- 在精确匹配和包含匹配之间，增加一层 **编辑距离匹配**（Levenshtein distance ≤ 2）
- 使用简单的内联实现（不需要引入第三方包）：
  ```dart
  // 在精确匹配失败后，包含匹配之前
  for (final c in categories) {
    if (c.isExpense == isExpense && _levenshtein(c.name, categoryName) <= 2) {
      return c;
    }
  }
  ```
- 同样应用于 `_matchSubcategory`（第 475-480 行）

**新增辅助方法**:
```dart
int _levenshtein(String a, String b) {
  // 标准 DP 实现，O(m*n)
}
```

**验证**: LLM 返回 "餐饮" → 编辑距离 2 匹配到 "餐饮美食" ✅

---

## 优化项 5：增加上下文感知的对话式记账

**问题**: 每次 `parseTransaction` 只发送 system + user 两条消息，无历史上下文。用户说"不对，是晚饭"时无法理解这是修正指令。

**文件**: `lib/features/ai/data/repositories/llm_repository_impl.dart:153-186`、`lib/features/chat/presentation/pages/ai_chat_page.dart:245-443`

**方案**:
- `parseTransaction` 方法签名增加可选参数 `List<ChatMessage>? history`
- `TransactionPipeline.processText` 同步增加 `history` 参数透传
- `_processInput` 中，在调用 pipeline 前，从 `_items` 提取最近 2 轮对话（用户消息 + AI 确认卡片）作为 history
- system prompt 增加指令：`如果用户的输入像是对上一笔交易的修正（如"不对"、"应该是"、"改一下"），请返回修正后的交易，并在 note 字段标注 "修正"`

**调用链改动**:
```
_processInput
  → _pipeline.processText(displayText, history: recentHistory)
    → _llmRepo.parseTransaction(text, history: history)
      → chat(LlmRequest(messages: [system, ...history, user]))
```

**验证**: 
1. 用户: "午饭25" → AI: 餐饮-午餐 ¥25
2. 用户: "不对是晚饭" → AI: 餐饮-晚餐 ¥25（note: 修正）

---

## 优化项 6：为 parseTransaction 增加 JSON Schema 约束（Structured Output）

**问题**: 当前完全依赖 prompt 指令要求 LLM 返回 JSON，但部分模型可能返回格式不符的文本。OpenAI 和 Anthropic 都已支持 structured output / tool_use 来强制 JSON schema。

**文件**: `lib/features/ai/data/repositories/llm_repository_impl.dart:60-92`、`lib/features/ai/data/models/llm_config.dart`

**方案**:
- 在 `LlmProvider` 中增加 `bool supportsStructuredOutput` 标记（根据 provider preset 自动设置）
- OpenAI 格式：当 `supportsStructuredOutput=true` 时，在请求 body 中增加 `response_format: { type: "json_object" }`
- Anthropic 格式：使用 tool_use 模式，定义 `parse_transaction` tool 并强制调用
- 不支持 structured output 的 provider 保持现有 prompt + 正则解析方式

**改动范围**: `_chatOpenAI` 和 `_chatAnthropic` 方法，增加 `responseFormat` 参数到 `LlmRequest`

**验证**: 使用 OpenAI gpt-4o-mini 调用时，response 保证为合法 JSON，无需正则提取

---

## 执行顺序建议

| 顺序 | 优化项 | 难度 | 预期收益 |
|------|--------|------|----------|
| 1 | 规则引擎分类名对齐 | ⭐ | 消除降级时的分类错配 |
| 2 | JSON 解析鲁棒性 | ⭐ | 消除偶发解析失败 |
| 3 | 分类匹配 fallback 降级 | ⭐⭐ | 减少错误分类入库 |
| 4 | 编辑距离容错 | ⭐⭐ | 提升分类匹配率 |
| 5 | 上下文感知对话 | ⭐⭐⭐ | 支持对话式修正 |
| 6 | Structured Output | ⭐⭐⭐ | 从根本上保证 JSON 格式 |
