# 01 - 需求分析文档 (Technical Specification)

> **版本**: v3.0 | **更新日期**: 2026-06-02 | **状态**: 已更新为本地优先方案

## 1.1 系统概述

### 1.1.1 项目定义

**WoAccount** 是一款基于 AI Agent 架构的智能记账应用，核心解决传统记账App中"分类选择繁琐"的痛点。系统通过 LLM + Function Calling 实现自然语言理解，用户输入一句话即可完成记账、查询、分析等操作。

### 1.1.2 技术愿景

```
传统记账App:
┌─────────────────────────────────────────────────────┐
│  输入金额 → 选择一级分类 → 选择二级分类 → 备注 → 保存  │
│  操作步骤: 5步 | 耗时: ~30秒 | 放弃率: 60%+           │
└─────────────────────────────────────────────────────┘

WoAccount:
┌─────────────────────────────────────────────────────┐
│  输入"午饭拉面25" → AI解析 → 确认 → 保存              │
│  操作步骤: 2步 | 耗时: ~5秒 | 预期放弃率: <20%         │
└─────────────────────────────────────────────────────┘
```

### 1.1.3 核心技术栈


| 层级       | 技术选型                       | 版本 |
| ---------- | ------------------------------ | ---- |
| 前端框架   | Flutter                        | 3.x  |
| 编程语言   | Dart                           | 3.x  |
| 状态管理   | Riverpod                       | 2.x  |
| 本地数据库 | SQLite (Drift)                 | 2.x  |
| AI服务     | LLM API (通义千问/GPT-4o-mini) | -    |
| 后端服务   | Supabase                       | -    |
| 数据库     | PostgreSQL                     | 15+  |

## 1.2 需求分类

### 需求层级定义


| 层级   | 定义               | 验收标准           |
| ------ | ------------------ | ------------------ |
| **P0** | 核心功能，MVP必须  | 不实现则系统不可用 |
| **P1** | 重要功能，影响体验 | 不实现则体验降级   |
| **P2** | 增强功能，锦上添花 | 可延期至后续版本   |
| **P3** | 未来功能，长期规划 | 列入Roadmap        |

## 1.3 功能需求 (Functional Requirements)

### 1.3.1 FR-001: 智能记账输入

**优先级**: P0
**模块**: Transaction Input
**描述**: 用户输入自然语言描述，系统自动解析为结构化交易记录

#### 输入规格


| 参数  | 类型   | 约束             | 示例               |
| ----- | ------ | ---------------- | ------------------ |
| input | String | 1-200字符，UTF-8 | "午饭吃了碗拉面25" |

#### 输出规格

```json
{
  "transaction": {
    "amount": 25.00,
    "description": "午饭拉面",
    "category_id": "cat_001",
    "subcategory_id": "sub_001_02",
    "transaction_date": "2025-01-15",
    "ai_confidence": 0.92,
    "source": "llm"
  },
  "metadata": {
    "parse_duration_ms": 850,
    "model_used": "qwen-turbo",
    "tokens_consumed": 128
  }
}
```

#### 解析规则


| 规则ID | 规则描述             | 优先级 | 示例                   |
| ------ | -------------------- | ------ | ---------------------- |
| R-001  | 提取金额 (整数/小数) | 最高   | "25" → 25.00          |
| R-002  | 提取金额 (带单位)    | 高     | "25元" → 25.00        |
| R-003  | 提取金额 (带符号)    | 高     | "¥25" → 25.00        |
| R-004  | 识别分类 (关键词)    | 中     | "火锅" → 餐饮         |
| R-005  | 识别分类 (语义)      | 中     | "吃了顿好的" → 餐饮   |
| R-006  | 提取日期 (显式)      | 中     | "1月5号" → 2025-01-05 |
| R-007  | 提取日期 (隐式)      | 低     | "昨天" → 前一天日期   |

#### 验收标准

- [ ]  AC-001: 输入"午饭拉面25"，解析出amount=25, category=餐饮
- [ ]  AC-002: 输入"打车去公司23.5"，解析出amount=23.5, category=交通
- [ ]  AC-003: 输入"交房租3500"，解析出amount=3500, category=住房
- [ ]  AC-004: 解析响应时间 < 2秒 (P95)
- [ ]  AC-005: 金额提取准确率 > 98%
- [ ]  AC-006: 分类识别准确率 > 90%

### 1.3.2 FR-002: AI自动分类

**优先级**: P0
**模块**: AI Classification Engine
**描述**: 基于 LLM + Rule Engine 的混合分类系统

#### 分类体系

```
分类层级结构 (最多3级):
├── L1: 一级分类 (9个)
│   ├── 🍜 餐饮 (Food)
│   ├── 🚗 交通 (Transport)
│   ├── 🛒 购物 (Shopping)
│   ├── 🏠 住房 (Housing)
│   ├── 🎮 娱乐 (Entertainment)
│   ├── 📚 教育 (Education)
│   ├── 💊 医疗 (Medical)
│   ├── 👤 社交 (Social)
│   └── 💰 其他 (Other)
│
├── L2: 二级分类 (每个L1下3-6个)
│   ├── 餐饮 > 早餐/午餐/晚餐/外卖/零食/饮料
│   ├── 交通 > 公交地铁/打车/加油/停车/火车飞机
│   └── ...
│
└── L3: 三级分类 (可选，用户自定义)
```

#### 分类引擎架构

```
输入文本
    │
    ▼
┌─────────────────────────────────────────────────────────┐
│  Layer 1: 预处理                                          │
│  ├── 文本清洗 (去除标点、多余空格)                        │
│  ├── 金额提取 (正则: /(\d+\.?\d*)(元|块|¥)?/)           │
│  └── 日期提取 (相对日期 → 绝对日期)                       │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Layer 2: 规则引擎 (Rule Engine)                          │
│  ├── 关键词匹配 (HashMap<String, Category>)              │
│  ├── 正则模式匹配 (RegExp)                               │
│  ├── 用户历史匹配 (UserPattern)                          │
│  └── 置信度: 0.85-0.95                                   │
│                                                          │
│  命中? ──是──▶ 返回结果                                   │
│    │                                                     │
│    否                                                    │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Layer 3: LLM API (通义千问/GPT)                          │
│  ├── Prompt Engineering                                  │
│  │   System: "你是记账助手，分析消费描述并分类"           │
│  │   User: "{input}"                                     │
│  │   Response Format: JSON                               │
│  ├── Function Calling (可选)                             │
│  └── 置信度: 0.70-0.95                                   │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Layer 4: 结果校验 & 融合                                  │
│  ├── 格式校验 (JSON Schema)                              │
│  ├── 范围校验 (金额 > 0, 分类存在)                       │
│  ├── 置信度加权 (规则 > LLM > 默认)                      │
│  └── 用户确认 (置信度 < 0.7 时提示)                      │
└─────────────────────────────────────────────────────────┘
```

#### Prompt 设计

```python
SYSTEM_PROMPT = """你是一个智能记账助手。请分析用户的消费描述，提取以下信息：

1. amount: 金额 (数字)
2. category: 一级分类名称
3. subcategory: 二级分类名称 (可选)
4. description: 精简描述 (10字以内)
5. confidence: 置信度 (0-1)

可用的一级分类: 餐饮, 交通, 购物, 住房, 娱乐, 教育, 医疗, 社交, 其他

请严格按照JSON格式返回，不要包含其他内容。"""

USER_PROMPT_TEMPLATE = "用户输入: {input}"
```

#### 验收标准

- [ ]  AC-010: 规则引擎覆盖80%常见场景
- [ ]  AC-011: LLM分类准确率 > 90%
- [ ]  AC-012: 混合分类准确率 > 95%
- [ ]  AC-013: 分类响应时间 < 500ms (规则) / < 2s (LLM)

### 1.3.3 FR-003: 账单管理

**优先级**: P0
**模块**: Transaction Management
**描述**: 交易记录的CRUD操作和查询

#### 数据模型

```sql
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    description VARCHAR(500) NOT NULL,
    category_id UUID NOT NULL REFERENCES categories(id),
    subcategory_id UUID REFERENCES categories(id),
    transaction_date DATE NOT NULL,
    original_input VARCHAR(500),
    ai_confidence FLOAT CHECK (ai_confidence >= 0 AND ai_confidence <= 1),
    ai_source VARCHAR(20) DEFAULT 'manual',
    user_confirmed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### API规格


| 端点                     | 方法   | 描述         | 请求参数                                                | 响应            |
| ------------------------ | ------ | ------------ | ------------------------------------------------------- | --------------- |
| `/api/transactions`      | GET    | 查询交易列表 | page, limit, start_date, end_date, category_id, keyword | TransactionList |
| `/api/transactions`      | POST   | 创建交易     | amount, description, category_id, date                  | Transaction     |
| `/api/transactions/{id}` | GET    | 获取单个交易 | id                                                      | Transaction     |
| `/api/transactions/{id}` | PUT    | 更新交易     | amount, description, category_id                        | Transaction     |
| `/api/transactions/{id}` | DELETE | 删除交易     | id                                                      | 204 No Content  |

#### 查询规格

```json
// GET /api/transactions?page=1&limit=20&start_date=2025-01-01&end_date=2025-01-31&category_id=cat_001

{
  "data": [
    {
      "id": "txn_001",
      "amount": 25.00,
      "description": "午饭拉面",
      "category": {
        "id": "cat_001",
        "name": "餐饮",
        "icon": "🍜",
        "color": "#FF9800"
      },
      "transaction_date": "2025-01-15",
      "created_at": "2025-01-15T12:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 156,
    "total_pages": 8
  }
}
```

#### 验收标准

- [ ]  AC-020: 创建交易成功后返回完整对象
- [ ]  AC-021: 查询支持分页、时间范围、分类筛选
- [ ]  AC-022: 更新交易仅修改传入的字段
- [ ]  AC-023: 删除交易为软删除 (deleted_at标记)
- [ ]  AC-024: 查询响应时间 < 100ms (P95)

---

### 1.3.4 FR-004: 分类管理

**优先级**: P0
**模块**: Category Management
**描述**: 分类体系的CRUD操作

#### 数据模型

```sql
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),  -- NULL表示系统预设
    name VARCHAR(50) NOT NULL,
    icon VARCHAR(10),
    color VARCHAR(9) DEFAULT '#607D8B',
    parent_id UUID REFERENCES categories(id),
    level INTEGER DEFAULT 1 CHECK (level >= 1 AND level <= 3),
    is_system BOOLEAN DEFAULT FALSE,
    is_expense BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
  
    UNIQUE(user_id, name, parent_id)
);
```

#### 系统预设分类

```json
{
  "categories": [
    {
      "name": "餐饮",
      "icon": "🍜",
      "color": "#FF9800",
      "subcategories": ["早餐", "午餐", "晚餐", "外卖", "零食", "饮料"]
    },
    {
      "name": "交通",
      "icon": "🚗",
      "color": "#2196F3",
      "subcategories": ["公交地铁", "打车", "加油", "停车", "火车飞机"]
    },
    {
      "name": "购物",
      "icon": "🛒",
      "color": "#E91E63",
      "subcategories": ["日用品", "衣服", "电子产品", "家居"]
    },
    {
      "name": "住房",
      "icon": "🏠",
      "color": "#9C27B0",
      "subcategories": ["房租", "水电煤", "物业", "维修"]
    },
    {
      "name": "娱乐",
      "icon": "🎮",
      "color": "#4CAF50",
      "subcategories": ["电影", "游戏", "旅游", "运动"]
    },
    {
      "name": "教育",
      "icon": "📚",
      "color": "#00BCD4",
      "subcategories": ["课程", "书籍", "培训"]
    },
    {
      "name": "医疗",
      "icon": "💊",
      "color": "#F44336",
      "subcategories": ["挂号", "药品", "体检"]
    },
    {
      "name": "社交",
      "icon": "👤",
      "color": "#FF5722",
      "subcategories": ["礼物", "聚餐", "红包"]
    },
    {
      "name": "其他",
      "icon": "💰",
      "color": "#607D8B",
      "subcategories": []
    }
  ]
}
```

#### 验收标准

- [ ]  AC-030: 系统预设分类在首次启动时自动创建
- [ ]  AC-031: 用户可创建自定义分类 (最多3级)
- [ ]  AC-032: 删除分类时检查是否有关联交易
- [ ]  AC-033: 分类列表支持拖拽排序

---

### 1.3.5 FR-005: AI智能检索

**优先级**: P0
**模块**: AI Query Engine
**描述**: 用户通过自然语言查询历史账单

#### 查询意图分类


| 意图类型       | 描述                 | 示例                   | 调用Tool           |
| -------------- | -------------------- | ---------------------- | ------------------ |
| **存在性查询** | 查询某类消费是否存在 | "我上周剪过头发吗？"   | query_transactions |
| **统计查询**   | 查询消费总额/均值    | "这个月餐饮花了多少？" | analyze_spending   |
| **筛选查询**   | 按条件筛选记录       | "找出超过100的消费"    | query_transactions |
| **对比查询**   | 对比不同时期/分类    | "比上个月多吗？"       | analyze_spending   |
| **明细查询**   | 查看具体消费明细     | "看看外卖明细"         | query_transactions |

#### 意图识别 Prompt

```python
QUERY_SYSTEM_PROMPT = """你是一个记账查询助手。分析用户的查询意图，提取查询参数。

意图类型:
- existential: 存在性查询 (有没有、是不是)
- statistical: 统计查询 (花了多少、平均)
- filter: 筛选查询 (找出、列出)
- comparison: 对比查询 (比...多吗、对比)
- detail: 明细查询 (看看、列出详情)

请返回JSON格式:
{
  "intent": "意图类型",
  "params": {
    "start_date": "YYYY-MM-DD或相对日期",
    "end_date": "YYYY-MM-DD",
    "category": "分类名称",
    "min_amount": 数字或null,
    "max_amount": 数字或null,
    "keyword": "关键词或null"
  },
  "confidence": 0-1
}"""
```

#### 验收标准

- [ ]  AC-040: 输入"我上周剪过头发吗？"，返回上周美容/理发记录
- [ ]  AC-041: 输入"这个月餐饮花了多少？"，返回本月餐饮总额
- [ ]  AC-042: 输入"找出超过100的消费"，返回金额>100的列表
- [ ]  AC-043: 意图识别准确率 > 85%
- [ ]  AC-044: 查询响应时间 < 3秒

---

### 1.3.6 FR-006: AI消费洞察

**优先级**: P1
**模块**: AI Insight Engine
**描述**: 系统主动分析消费数据，发现异常和趋势

#### 洞察类型


| 类型         | 算法          | 触发条件       | 示例输出                    |
| ------------ | ------------- | -------------- | --------------------------- |
| **异常检测** | Z-Score / IQR | 周环比 > 30%   | "本周餐饮支出比上周增加65%" |
| **趋势检测** | 线性回归      | 连续3个月趋势  | "交通费用连续3个月下降"     |
| **周期检测** | 自相关分析    | 发现周期规律   | "每月15号有大额消费"        |
| **超支预警** | 移动平均预测  | 预算使用 > 80% | "月底预算将超支200元"       |
| **消费结构** | 占比分析      | 月度统计       | "外卖占餐饮45%"             |

#### 异常检测算法

```python
def detect_anomaly(current_week: float, historical_weeks: list[float]) -> dict:
    """
    使用Z-Score检测异常消费
  
    Args:
        current_week: 本周消费金额
        historical_weeks: 过去N周消费金额列表
  
    Returns:
        {
            "is_anomaly": bool,
            "z_score": float,
            "percentage_change": float,
            "message": str
        }
    """
    mean = statistics.mean(historical_weeks)
    std = statistics.stdev(historical_weeks)
  
    if std == 0:
        return {"is_anomaly": False}
  
    z_score = (current_week - mean) / std
  
    # Z-Score > 2 认为是异常
    is_anomaly = abs(z_score) > 2
  
    percentage_change = ((current_week - mean) / mean) * 100
  
    return {
        "is_anomaly": is_anomaly,
        "z_score": round(z_score, 2),
        "percentage_change": round(percentage_change, 1),
        "message": f"本周消费{current_week}元，{'增加' if percentage_change > 0 else '减少'}{abs(percentage_change)}%"
    }
```

#### 验收标准

- [ ]  AC-050: 周环比 > 30% 时触发异常提醒
- [ ]  AC-051: 连续3个月趋势被检测到
- [ ]  AC-052: 预算使用 > 80% 时触发预警
- [ ]  AC-053: 洞察结果通过LLM生成自然语言描述

---

### 1.3.7 FR-007: AI对话助手

**优先级**: P1
**模块**: AI Agent
**描述**: 支持多轮对话、上下文记忆的AI助手

#### Agent架构

```
┌─────────────────────────────────────────────────────────────────┐
│                        AI Agent 架构                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                    用户交互层                             │   │
│  │  ├── 自然语言输入 (Text)                                 │   │
│  │  ├── 语音输入 (Voice → Text)                             │   │
│  │  └── 图片输入 (OCR → Text)                               │   │
│  └─────────────────────────┬───────────────────────────────┘   │
│                             │                                   │
│  ┌─────────────────────────▼───────────────────────────────┐   │
│  │                    Agent Core                             │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │   │
│  │  │  NLU Engine │  │  Reasoning  │  │   Memory    │     │   │
│  │  │  意图理解    │  │  推理引擎    │  │  记忆系统    │     │   │
│  │  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘     │   │
│  │         │                │                │             │   │
│  │         └────────────────┼────────────────┘             │   │
│  │                          │                              │   │
│  │  ┌───────────────────────▼───────────────────────────┐  │   │
│  │  │              Function Calling Layer                │  │   │
│  │  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ │  │   │
│  │  │  │ create_ │ │ query_  │ │analyze_ │ │  set_   │ │  │   │
│  │  │  │transact.│ │transact.│ │spending │ │ budget  │ │  │   │
│  │  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘ │  │   │
│  │  └───────────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────────┘   │
│                             │                                   │
│  ┌─────────────────────────▼───────────────────────────────┐   │
│  │                    Data Layer                             │   │
│  │  ├── Transaction DB (SQLite/PostgreSQL)                  │   │
│  │  ├── User Profile (Preferences, Habits)                  │   │
│  │  └── Conversation History (Context Window)               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### Function Calling 定义

```dart
/// AI Agent 可调用的工具集
class AgentTools {
  /// 创建交易记录
  static final createTransaction = FunctionDefinition(
    name: 'create_transaction',
    description: '创建一笔新的交易记录',
    parameters: {
      'type': 'object',
      'properties': {
        'amount': {
          'type': 'number',
          'description': '交易金额，必须大于0',
        },
        'description': {
          'type': 'string',
          'description': '交易描述，10字以内',
        },
        'category': {
          'type': 'string',
          'description': '分类名称，如: 餐饮、交通、购物',
          'enum': ['餐饮', '交通', '购物', '住房', '娱乐', '教育', '医疗', '社交', '其他'],
        },
        'date': {
          'type': 'string',
          'description': '交易日期，格式YYYY-MM-DD，默认今天',
        },
      },
      'required': ['amount', 'description', 'category'],
    },
  );

  /// 查询交易记录
  static final queryTransactions = FunctionDefinition(
    name: 'query_transactions',
    description: '查询交易记录，支持按时间、分类、金额、关键词筛选',
    parameters: {
      'type': 'object',
      'properties': {
        'start_date': {'type': 'string', 'description': '开始日期 YYYY-MM-DD'},
        'end_date': {'type': 'string', 'description': '结束日期 YYYY-MM-DD'},
        'category': {'type': 'string', 'description': '分类名称'},
        'min_amount': {'type': 'number', 'description': '最小金额'},
        'max_amount': {'type': 'number', 'description': '最大金额'},
        'keyword': {'type': 'string', 'description': '搜索关键词'},
        'limit': {'type': 'integer', 'description': '返回数量限制，默认20'},
      },
    },
  );

  /// 分析消费数据
  static final analyzeSpending = FunctionDefinition(
    name: 'analyze_spending',
    description: '分析消费数据，返回统计结果和趋势',
    parameters: {
      'type': 'object',
      'properties': {
        'period': {
          'type': 'string',
          'description': '统计周期',
          'enum': ['this_week', 'last_week', 'this_month', 'last_month', 'this_year'],
        },
        'category': {'type': 'string', 'description': '分类，为空则统计所有'},
        'compare': {'type': 'boolean', 'description': '是否与上期对比'},
      },
      'required': ['period'],
    },
  );

  /// 设置预算
  static final setBudget = FunctionDefinition(
    name: 'set_budget',
    description: '设置月度预算',
    parameters: {
      'type': 'object',
      'properties': {
        'amount': {'type': 'number', 'description': '预算金额'},
        'category': {'type': 'string', 'description': '分类，为空则为总预算'},
      },
      'required': ['amount'],
    },
  );
}
```

#### 上下文记忆

```dart
/// 对话上下文管理
class ConversationContext {
  /// 对话历史 (最近N轮)
  final List<Message> history;
  
  /// 当前查询上下文
  final QueryContext? currentQuery;
  
  /// 用户偏好
  final UserPreferences preferences;
  
  /// 构建System Prompt
  String buildSystemPrompt() {
    return '''
你是WoAccount记账助手。你可以帮助用户：
1. 记账：用户描述消费，你调用create_transaction
2. 查询：用户查询历史，你调用query_transactions
3. 分析：用户想了解消费情况，你调用analyze_spending
4. 预算：用户设置预算，你调用set_budget

当前时间: ${DateTime.now()}
用户偏好: ${preferences.toJson()}

请用简洁友好的语言回复用户。
''';
  }
}
```

#### 验收标准

- [ ]  AC-060: 支持至少5轮连续对话
- [ ]  AC-061: 上下文引用正确 (如"那笔"引用之前的记录)
- [ ]  AC-062: Function Calling 调用准确率 > 90%
- [ ]  AC-063: 对话响应时间 < 3秒

---

### 1.3.8 FR-008: AI智能建议

**优先级**: P2
**模块**: AI Suggestion Engine
**描述**: 基于消费数据生成个性化建议

#### 建议生成规则


| 规则ID | 条件                 | 建议模板                                                |
| ------ | -------------------- | ------------------------------------------------------- |
| S-001  | 外卖占比 > 40%       | "外卖占餐饮{percent}%，尝试自己做饭可省约{amount}元/月" |
| S-002  | 某分类连续增长       | "{category}连续{months}个月增长，建议关注"              |
| S-003  | 周末消费 > 工作日2倍 | "周末消费比工作日高{percent}%，考虑规划周末预算"        |
| S-004  | 无预算设置           | "建议设置月度预算，基于过去3个月均值{amount}元"         |
| S-005  | 订阅服务检测         | "发现{count}个定期扣款，检查是否都需要？"               |

#### 验收标准

- [ ]  AC-070: 建议基于真实数据生成
- [ ]  AC-071: 建议可执行 (包含具体金额/操作)
- [ ]  AC-072: 每月最多推送5条建议

---

### 1.3.9 FR-009: 预算管理

**优先级**: P1
**模块**: Budget Management
**描述**: 设置和追踪月度预算

#### 数据模型

```sql
CREATE TABLE budgets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id),
    category_id UUID REFERENCES categories(id),  -- NULL表示总预算
    amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
    period VARCHAR(20) DEFAULT 'monthly',
    year INTEGER NOT NULL,
    month INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
  
    UNIQUE(user_id, category_id, year, month)
);
```

#### 预算追踪

```json
{
  "budget": {
    "id": "budget_001",
    "amount": 1500.00,
    "category": "餐饮",
    "period": "2025-01"
  },
  "status": {
    "spent": 1280.00,
    "remaining": 220.00,
    "percentage": 85.3,
    "daily_average": 85.33,
    "projected_total": 2560.00,
    "will_exceed": true,
    "exceed_amount": 1060.00
  }
}
```

#### 验收标准

- [ ]  AC-080: 支持设置总预算和分类预算
- [ ]  AC-081: 实时显示预算使用进度
- [ ]  AC-082: 使用 > 80% 时推送提醒
- [ ]  AC-083: 预测月底是否超支

---

## 1.4 非功能需求 (Non-Functional Requirements)

### 1.4.1 性能需求


| 指标          | 目标值  | P95值 | 测试方法 |
| ------------- | ------- | ----- | -------- |
| App冷启动时间 | < 1.5s  | 2s    | 性能测试 |
| App热启动时间 | < 0.5s  | 1s    | 性能测试 |
| AI解析 (规则) | < 100ms | 200ms | 单元测试 |
| AI解析 (LLM)  | < 1.5s  | 3s    | 集成测试 |
| 账单列表加载  | < 500ms | 1s    | 性能测试 |
| 统计图表渲染  | < 800ms | 1.5s  | 性能测试 |
| 数据库查询    | < 50ms  | 100ms | 基准测试 |
| 页面切换      | < 200ms | 500ms | UI测试   |

### 1.4.2 存储需求


| 数据类型 | 单条大小 | 增长速率    | 存储策略 |
| -------- | -------- | ----------- | -------- |
| 交易记录 | ~1KB     | 3条/天      | 本地SQLite |
| 分类数据 | ~100B    | 静态        | 本地SQLite |
| 对话历史 | ~2KB/轮  | 按需        | 本地SQLite |
| AI训练数据 | ~200B  | 按修正记录  | 本地SQLite |

### 1.4.3 安全需求


| 需求      | 实现方式                         | 验收标准               |
| --------- | -------------------------------- | ---------------------- |
| 传输加密  | HTTPS/TLS 1.3                    | LLM API通信加密        |
| API Key保护 | --dart-define 注入，不硬编码   | Key不出现在代码仓库中  |
| 输入校验  | 参数校验 + SQL注入防护           | 防止恶意输入           |

> 当前阶段无用户认证、无云端数据，数据仅存本机 SQLite。

### 1.4.4 可用性需求


| 需求     | 描述                | 实现方式              |
| -------- | ------------------- | --------------------- |
| 离线可用 | 无网络时可记账      | 本地SQLite + 规则引擎 |
| 错误恢复 | 网络异常时降级      | 规则引擎兜底          |
| 崩溃恢复 | App崩溃后数据不丢失 | SQLite事务保证        |

---

## 1.5 数据流图

### 1.5.1 记账数据流

```
用户输入: "午饭拉面25"
        │
        ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: 输入预处理                                          │
│  ├── 文本清洗: "午饭拉面25" → "午饭拉面25"                    │
│  ├── 金额提取: "25" → 25.00                                  │
│  └── 日期推断: 今天 → 2025-01-15                              │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 2: AI分类                                              │
│  ├── 规则匹配: "拉面" → 餐饮 (confidence: 0.9)               │
│  ├── LLM解析: 通义千问API (confidence: 0.92)                 │
│  └── 结果融合: 餐饮 > 午餐 (confidence: 0.91)                │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 3: 用户确认                                            │
│  ├── 展示解析结果卡片                                         │
│  ├── 用户可修改分类/金额                                      │
│  └── 确认保存                                                 │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 4: 数据持久化                                          │
│  ├── 写入本地SQLite (Drift)                                   │
│  └── 更新统计缓存                                             │
└─────────────────────────────────────────────────────────────┘
```

### 1.5.2 查询数据流

```
用户查询: "我上周剪过头发吗？"
        │
        ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 1: 意图识别                                            │
│  ├── 意图: existential (存在性查询)                           │
│  ├── 时间: 上周 (2025-01-06 ~ 2025-01-12)                    │
│  ├── 分类: 美容/理发                                          │
│  └── 关键词: 剪头发、理发                                     │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 2: SQL构建                                             │
│  SELECT * FROM transactions                                  │
│  WHERE user_id = ?                                           │
│    AND transaction_date BETWEEN '2025-01-06' AND '2025-01-12'│
│    AND (category_id IN (美容ID, 理发ID)                       │
│         OR description LIKE '%理发%'                         │
│         OR description LIKE '%剪头%')                        │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 3: 结果处理                                            │
│  ├── 有结果: 生成详细回答                                     │
│  └── 无结果: 告知未找到                                       │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  Layer 4: LLM生成回复                                        │
│  "上周三(1月10日)你在XX理发店消费了38元，是剪头发的费用。"   │
└─────────────────────────────────────────────────────────────┘
```

---

## 1.6 用例规格 (Use Case Specifications)

### UC-001: 智能记账


| 项目           | 描述                         |
| -------------- | ---------------------------- |
| **用例ID**     | UC-001                       |
| **用例名称**   | 智能记账                     |
| **主要参与者** | 记账用户                     |
| **前置条件**   | 用户已打开App                |
| **后置条件**   | 交易记录已保存               |
| **触发条件**   | 用户输入消费描述并点击"记账" |

**主成功场景**:

```
1. 用户在输入框输入消费描述 (如"午饭吃了碗拉面25")
2. 用户点击"记账"按钮
3. 系统显示加载动画
4. 系统调用AI解析服务
   4.1 规则引擎尝试匹配
   4.2 若未命中，调用LLM API
5. 系统显示解析结果卡片
   - 金额: ¥25.00
   - 分类: 餐饮 > 午餐
   - 描述: 午饭拉面
   - 置信度: 92%
6. 用户确认信息正确
7. 用户点击"确认记账"按钮
8. 系统保存交易记录到数据库
9. 系统显示成功提示
10. 系统刷新首页账单列表
```

**扩展场景**:

```
3a. AI解析失败
    3a.1 系统显示"解析失败，请重试"提示
    3a.2 用户点击重试，返回步骤4
  
4a. 规则引擎命中
    4a.1 直接返回结果，跳过LLM调用
  
5a. 用户修改分类
    5a.1 用户点击分类名称
    5a.2 系统显示分类选择器
    5a.3 用户选择新分类
    5a.4 系统更新解析结果卡片
  
5b. 用户修改金额
    5b.1 用户点击金额
    5b.2 系统显示金额输入框
    5b.3 用户输入新金额
    5b.4 系统更新解析结果卡片
  
5c. 置信度过低 (< 70%)
    5c.1 系统高亮显示"请确认分类是否正确"
    5c.2 用户必须手动确认或修改
```

**特殊需求**:

- AI解析响应时间 < 2秒
- 金额提取准确率 > 98%
- 分类识别准确率 > 90%

---

### UC-002: 自然语言查询


| 项目           | 描述             |
| -------------- | ---------------- |
| **用例ID**     | UC-002           |
| **用例名称**   | 自然语言查询     |
| **主要参与者** | 记账用户         |
| **前置条件**   | 用户已有记账记录 |
| **后置条件**   | 查询结果已展示   |
| **触发条件**   | 用户输入查询语句 |

**主成功场景**:

```
1. 用户进入AI助手页面
2. 用户输入查询 (如"我上周剪过头发吗？")
3. 系统调用LLM进行意图识别
4. LLM返回意图和参数
5. 系统调用对应的Function
6. 系统获取查询结果
7. 系统调用LLM生成自然语言回复
8. 系统展示回复结果
```

**扩展场景**:

```
3a. 意图不明确
    3a.1 系统询问用户确认意图
    3a.2 "你是想查询上周的消费记录吗？"
  
6a. 无查询结果
    6a.1 系统告知未找到记录
    6a.2 "上周没有找到理发相关的记录"
  
6b. 多条结果
    6b.1 系统展示结果列表
    6b.2 用户可点击查看明细
```

---

## 1.7 接口规格 (Interface Specifications)

### 1.7.1 AI解析接口 (内部服务，非HTTP API)

AI解析在应用内部通过 Dart 类调用，不暴露 HTTP 接口。流程如下：

```
用户输入 → AiService.parseInput() → 规则引擎/LLM API → AiParseResult
```

**LLM API 调用规格 (通义千问)**:

```http
POST https://dashscope.aliyuncs.com/api/v1/chat/completions
Content-Type: application/json
Authorization: Bearer {AI_API_KEY}

{
  "model": "qwen-turbo",
  "messages": [
    {"role": "system", "content": "你是记账助手..."},
    {"role": "user", "content": "午饭吃了碗拉面25"}
  ],
  "temperature": 0.1,
  "response_format": {"type": "json_object"}
}
```

**响应**:

```json
{
  "amount": 25.00,
  "category": "餐饮",
  "subcategory": "午餐",
  "description": "午饭拉面",
  "confidence": 0.92
}
```

### 1.7.2 对话接口 (内部服务)

AI对话在应用内部通过 AiService.chat() 调用，使用 Function Calling 架构：

```
用户查询 → AiService.chat() → LLM (Function Calling) → 执行工具 → 生成回复
```

---

## 1.8 用户故事 (User Stories)

### 1.8.1 记账功能


| ID     | 角色     | 用户故事                                                                 | 验收标准                                             | 优先级 |
| ------ | -------- | ------------------------------------------------------------------------ | ---------------------------------------------------- | ------ |
| US-001 | 记账用户 | 作为一个忙碌的上班族，我想通过输入一句话来记账，这样我不用花时间选择分类 | 输入"午饭拉面25"后，AI自动识别金额和分类，确认后保存 | P0     |
| US-002 | 记账用户 | 作为一个记账新手，我想让App自动帮我分类，这样我不用学习复杂的分类体系    | AI分类准确率>90%，用户无需手动选择分类               | P0     |
| US-003 | 记账用户 | 作为一个经常忘记记账的人，我想快速记录一笔消费，这样我能坚持记账         | 从打开App到完成记账<10秒                             | P0     |
| US-004 | 记账用户 | 作为一个有特殊消费习惯的人，我想自定义分类，这样我能按自己的方式管理账单 | 支持创建、编辑、删除自定义分类                       | P1     |

### 1.8.2 AI检索功能


| ID     | 角色     | 用户故事                                                     | 验收标准                              | 优先级 |
| ------ | -------- | ------------------------------------------------------------ | ------------------------------------- | ------ |
| US-101 | 记账用户 | 作为一个想确认历史消费的人，我想问"我上周剪过头发吗？"来查询 | AI正确理解意图，返回上周美容/理发记录 | P0     |
| US-102 | 记账用户 | 作为一个想了解消费情况的人，我想问"这个月餐饮花了多少？"     | AI返回本月餐饮总额和日均              | P0     |
| US-103 | 记账用户 | 作为一个想筛选消费的人，我想问"找出超过100的消费"            | AI返回所有金额>100的记录列表          | P0     |
| US-104 | 记账用户 | 作为一个想对比消费的人，我想问"比上个月多吗？"               | AI对比本月和上月消费并给出结论        | P1     |

### 1.8.3 对话助手功能


| ID     | 角色     | 用户故事                                         | 验收标准                     | 优先级 |
| ------ | -------- | ------------------------------------------------ | ---------------------------- | ------ |
| US-201 | 记账用户 | 作为一个想自然交互的人，我想通过对话了解消费情况 | AI支持多轮对话，理解上下文   | P1     |
| US-202 | 记账用户 | 作为一个想设置预算的人，我想通过对话设置预算     | AI根据历史数据推荐预算并设置 | P1     |
| US-203 | 记账用户 | 一个想得到建议的人，我想让AI分析我的消费习惯     | AI给出可执行的省钱建议       | P2     |

---

## 1.9 约束与假设

### 1.9.1 约束条件


| 约束类型 | 描述              | 影响               |
| -------- | ----------------- | ------------------ |
| 技术约束 | Flutter跨平台框架 | 需要学习Dart语言   |
| 时间约束 | MVP在6周内完成    | 功能范围需严格控制 |
| 资源约束 | 个人开发          | 需要优先核心功能   |
| 平台约束 | iOS/Android双平台 | 需要考虑平台差异   |
| 网络约束 | AI功能需要网络    | 需要离线降级方案   |
| 成本约束 | LLM API调用成本   | 需要缓存和降级策略 |
| 数据约束 | 仅本地存储        | 单设备，无多端同步 |

### 1.9.2 假设条件


| 假设     | 描述                         | 风险                 |
| -------- | ---------------------------- | -------------------- |
| 用户设备 | 用户使用iOS 14+ / Android 8+ | 低端设备性能问题     |
| 网络环境 | 用户有基本的网络连接         | 弱网环境下AI功能受限 |
| 用户输入 | 用户输入中文描述             | 方言、俚语识别难度   |
| AI服务   | AI API服务稳定可用           | 服务不可用时降级为规则引擎 |
| 使用场景 | 个人自用，单设备             | 换手机需手动迁移数据 |

---

## 1.10 风险分析


| 风险           | 概率 | 影响 | 应对策略                             |
| -------------- | ---- | ---- | ------------------------------------ |
| AI准确率不达标 | 中   | 高   | 规则引擎兜底，持续优化Prompt         |
| 用户输入多样化 | 高   | 中   | 支持多种表达方式，AI学习用户习惯     |
| LLM API不稳定  | 中   | 高   | 多服务商备选，规则引擎离线降级       |
| 性能问题       | 中   | 中   | 优化数据库查询，使用缓存，懒加载     |
| 本地数据丢失   | 低   | 高   | 定期CSV导出备份，SQLite事务保证      |
| 开发延期       | 中   | 中   | 优先P0功能，P2可延期，灵活调整计划   |

---

## 1.11 术语表


| 术语                 | 定义                                               |
| -------------------- | -------------------------------------------------- |
| **LLM**              | 大语言模型 (Large Language Model)，如通义千问、GPT |
| **NLU**              | 自然语言理解 (Natural Language Understanding)      |
| **Function Calling** | LLM调用外部函数的能力                              |
| **Rule Engine**      | 基于关键词匹配的快速分类系统                       |
| **Confidence**       | AI对解析结果的确定程度，0-1之间                    |
| **MVP**              | 最小可行产品 (Minimum Viable Product)              |
| **P0/P1/P2**         | 功能优先级，P0必须实现，P1重要，P2可选             |
| **AC**               | 验收标准 (Acceptance Criteria)                     |
| **FR**               | 功能需求 (Functional Requirement)                  |
| **NFR**              | 非功能需求 (Non-Functional Requirement)            |

---

## 1.12 需求追踪矩阵


| 需求ID | 需求描述     | 优先级 | 设计文档             | 开发任务   | 测试用例   | 状态   |
| ------ | ------------ | ------ | -------------------- | ---------- | ---------- | ------ |
| FR-001 | 智能记账输入 | P0     | 04-product-design.md | Week 3     | TC-001~010 | 待开发 |
| FR-002 | AI自动分类   | P0     | 05-architecture.md   | Week 4     | TC-011~020 | 待开发 |
| FR-003 | 账单管理     | P0     | 04-product-design.md | Week 5     | TC-021~030 | 待开发 |
| FR-004 | 分类管理     | P0     | 04-product-design.md | Week 10    | TC-031~040 | 待开发 |
| FR-005 | AI智能检索   | P0     | 05-architecture.md   | Week 7-8   | TC-041~050 | 规划中 |
| FR-006 | AI消费洞察   | P1     | 05-architecture.md   | Week 9     | TC-051~060 | 规划中 |
| FR-007 | AI对话助手   | P1     | 05-architecture.md   | Week 11-12 | TC-061~070 | 规划中 |
| FR-008 | AI智能建议   | P2     | 05-architecture.md   | Week 13-14 | TC-071~080 | 规划中 |
| FR-009 | 预算管理     | P1     | 04-product-design.md | Week 9     | TC-081~090 | 规划中 |
| FR-010 | 数据导出     | P1     | 05-architecture.md   | Week 10    | TC-091~100 | 规划中 |
