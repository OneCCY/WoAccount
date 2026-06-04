# WoAccount - AI 智能记账

> 只需说一句话，AI 帮你记账。
>
> 本地优先 · 零分类操作 · 多模型支持 · 数据安全

---

## 产品简介

WoAccount 是一款 AI 驱动的个人记账应用。用户只需输入自然语言描述（如"午饭拉面25"），AI 自动识别金额、分类并完成记账。无需手动选择分类，无需繁琐操作。

**核心理念**: 不是"有 AI 功能的记账 App"，而是"AI 驱动的记账体验"。

### 核心功能

| 功能 | 优先级 | 说明 |
|------|--------|------|
| 智能记账输入 | P0 | 自然语言输入，AI 自动解析金额、分类、日期 |
| 自动分类 | P0 | 规则引擎 + LLM 双路径，准确率 >90% |
| 分类管理 | P0 | 9 大默认分类，支持自定义二级分类 |
| 账单列表 | P0 | 按时间、分类查看，支持搜索和筛选 |
| 消费统计 | P1 | 图表展示消费趋势和分类占比 |
| 预算管理 | P1 | 月度预算设置，超支提醒 |
| AI 对话助手 | P1 | 自然语言查询历史账单 |
| AI 消费洞察 | P1 | 异常检测、趋势分析、主动推送 |
| 数据导出 | P2 | CSV/Excel 导出 |
| 语音输入 | P2 | 语音记账，转文字后 AI 解析 |
| 拍照识别 | P2 | 拍照识别小票自动记账 |

---

## 技术架构

```
┌──────────────────────────────────────────────────────┐
│                   Flutter App                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐           │
│  │  首页     │  │  账单     │  │  我的     │           │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘           │
│       └──────────────┼──────────────┘                │
│  ┌───────────────────▼───────────────────────────┐   │
│  │           Riverpod 状态管理                     │   │
│  └───────────────────┬───────────────────────────┘   │
│  ┌───────────────────▼───────────────────────────┐   │
│  │           Repository 层 (Clean Architecture)    │   │
│  └───────┬───────────────┬───────────────┬───────┘   │
│          ▼               ▼               ▼           │
│    ┌──────────┐   ┌──────────┐   ┌──────────┐       │
│    │  SQLite   │   │ LLM API  │   │ 规则引擎  │       │
│    │  (Drift)  │   │ (多模型)  │   │  (离线)   │       │
│    └──────────┘   └──────────┘   └──────────┘       │
└──────────────────────────────────────────────────────┘
```

### 技术栈

| 层级 | 技术 | 版本 | 说明 |
|------|------|------|------|
| 框架 | Flutter | 3.44.1 | 跨平台 UI 框架 |
| 语言 | Dart | 3.12.1 | 编程语言 |
| 状态管理 | Riverpod | 2.6.1 | 响应式状态管理 + 依赖注入 |
| 路由 | GoRouter | 14.8.1 | 声明式路由 |
| 数据库 | Drift (SQLite) | 2.28.2 | 类型安全 ORM，响应式查询 |
| HTTP | Dio | 5.9.2 | HTTP 客户端，支持拦截器和重试 |
| 图表 | fl_chart | 0.70.2 | 纯 Dart 图表库 |
| 安全存储 | flutter_secure_storage | — | API Key 安全存储 |

### AI 服务

| 角色 | 模型 | 说明 |
|------|------|------|
| 默认 | 通义千问 (qwen-turbo) | 阿里云，国内直连，性价比高 |
| 备选 | DeepSeek (deepseek-chat) | 推理能力强，价格最低 |
| 备选 | 智谱 AI (GLM-4-flash) | 免费额度 |
| 兜底 | 本地规则引擎 | 离线可用，30+ 关键词规则 |

**Fallback 策略**: 规则引擎 → DeepSeek → 通义千问 → 规则引擎降级

---

## 项目结构

```
lib/
├── core/                              # 核心模块（全局共享）
│   ├── theme/                         # 主题系统
│   │   ├── app_colors.dart            # 颜色系统（Cupertino 风格）
│   │   ├── app_text_styles.dart       # 字体层级
│   │   └── app_theme.dart             # 主题定义
│   ├── constants/                     # 常量定义
│   ├── error/                         # 异常与失败类型
│   ├── extensions/                    # Dart 扩展方法
│   ├── utils/                         # 工具类
│   └── widgets/                       # 公共组件
│
├── features/                          # 功能模块（Feature-First）
│   ├── home/                          # 首页（记账入口）
│   ├── transaction/                   # 交易记录
│   │   ├── data/repositories/         # Repository 实现
│   │   ├── domain/repositories/       # Repository 接口
│   │   └── presentation/              # 页面和组件
│   ├── category/                      # 分类管理
│   ├── budget/                        # 预算管理
│   ├── ai_assistant/                  # AI 助手
│   └── settings/                      # 设置
│
├── config/                            # 配置层
│   ├── database/app_database.dart     # Drift 数据库定义
│   ├── di/providers.dart              # Riverpod 依赖注入
│   └── routes/app_router.dart         # GoRouter 路由
│
└── main.dart                          # 应用入口
```

---

## 数据库设计

5 张核心表，Drift ORM 类型安全：

| 表名 | 说明 | 关键字段 |
|------|------|----------|
| `transactions` | 交易记录 | amount, categoryId, transactionDate, aiConfidence |
| `categories` | 分类体系 | name, icon, color, parentId (二级分类), isSystem |
| `budgets` | 预算 | amount, categoryId, year, month |
| `ai_training_records` | AI 学习数据 | inputText, predictedCategoryId, actualCategoryId |
| `conversation_messages` | 对话历史 | role, content, functionName |

默认分类: 🍜餐饮 · 🚗交通 · 🛒购物 · 🏠住房 · 🎮娱乐 · 📚教育 · 💊医疗 · 👤社交 · 💰其他

---

## 开发规范

### 架构原则

- **Clean Architecture**: Presentation → Domain ← Data，Domain 层零外部依赖
- **Feature-First**: 按功能模块组织，每个模块独立的 data/domain/presentation
- **Repository 模式**: 接口定义在 Domain 层，实现在 Data 层
- **Riverpod DI**: 通过 `@riverpod` 注解自动生成 Provider

### 代码规范

```dart
// 命名规范
class TransactionService {}          // 类: PascalCase
final transactionList = [];          // 变量: camelCase
const maxRetryCount = 3;             // 常量: camelCase (Dart 推荐)
// 文件: snake_case.dart
```

### Git 提交规范

```
<type>[optional scope]: <description>

类型: feat / fix / docs / style / refactor / perf / test / build / ci / chore
范围: ai / transaction / category / stats / budget / settings / db / config
```

---

## 性能目标

| 指标 | 目标 | 说明 |
|------|------|------|
| 冷启动时间 | <2s | 从启动到可交互 |
| 帧率 | 60fps | 流畅滚动和动画 |
| 内存占用 | <150MB | 正常使用场景 |
| 数据库查询 | <100ms | 带索引的常用查询 |
| AI 响应时间 | <3s | 包含网络请求 |
| 分类准确率 | >90% | 规则引擎 + LLM |

---

## 安全策略

- **本地优先**: 所有数据存储在设备本地，不上传云端
- **数据库加密**: SQLCipher 加密，密钥存储在系统安全区
- **API Key 保护**: flutter_secure_storage (iOS Keychain / Android Keystore)
- **软删除**: 30 天清理阈值，支持数据恢复
- **备份加密**: AES 加密导出文件

---

## 测试策略

```
         ╱╲
        ╱  ╲        E2E 测试 (10%) - 关键流程端到端
       ╱──────╲
      ╱        ╲     集成测试 (30%) - 数据库 CRUD, LLM API
     ╱────────────╲
    ╱              ╲  单元测试 (60%) - 规则引擎, Repository, UseCase
   ╱────────────────╲

覆盖率目标: 70%+
```

---

## 开发路线图

| 阶段 | 时间 | 核心内容 |
|------|------|----------|
| **Phase 1 MVP** | Week 1-6 | 项目搭建、数据库、记账输入、AI 分类、账单列表 |
| **Phase 2 AI Agent** | Week 7-10 | AI 智能检索、消费洞察、预算管理、云同步 |
| **Phase 3 进阶** | Week 11-14 | AI 对话助手、智能建议、数据导出、多账户 |
| **Phase 4 发布** | Week 15-16 | 性能优化、安全审计、应用商店提交 |

---

## 文档

### 技术实现文档（开发时遵循）

| 模块 | 文档 | 说明 |
|------|------|------|
| 前端架构 | [frontend-architecture.md](docs/superpowers/architecture/frontend-architecture.md) | Feature-First 结构、Riverpod 详解、GoRouter |
| 后端架构 | [backend-architecture.md](docs/superpowers/architecture/backend-architecture.md) | Drift 数据库、Repository 模式、Provider |
| AI 能力 | [ai-overview.md](docs/superpowers/ai/ai-overview.md) | 能力矩阵、处理流程、数据流 |
| LLM 架构 | [llm-overview.md](docs/superpowers/llm/llm-overview.md) | 多模型支持、离线策略、缓存 |
| LLM 配置 | [llm-config.md](docs/superpowers/llm/llm-config.md) | 用户配置方案、预设提供商 |
| Prompt 设计 | [prompt-design.md](docs/superpowers/llm/prompt-design.md) | 记账解析、AI 对话、消费洞察 |
| UI 设计系统 | [ui-design-system.md](docs/superpowers/specs/2026-06-04-ui-design-system.md) | 字体、颜色、间距、动画规范 |
| 交互流程 | [interaction-flow.md](docs/superpowers/ux/interaction-flow.md) | 页面导航、手势、动画、反馈 |
| 测试策略 | [testing-strategy.md](docs/superpowers/testing/testing-strategy.md) | 测试金字塔、AI 准确率测试 |
| 数据安全 | [data-security.md](docs/superpowers/security/data-security.md) | 加密、安全存储、备份恢复 |
| 性能优化 | [performance-optimization.md](docs/superpowers/performance/performance-optimization.md) | 启动、列表、内存、网络优化 |

### 项目规划文档

| 文档 | 说明 |
|------|------|
| [项目工作流总览](docs/project-workflow/PROJECT_WORKFLOW.md) | 全流程概览与详细文档索引 |
| [需求分析](docs/project-workflow/01-requirements.md) | 功能清单、用户故事、验收标准 |
| [技术选型](docs/project-workflow/03-tech-stack.md) | 技术栈方案对比与选择 |
| [开发计划](docs/project-workflow/06-development-plan.md) | 阶段划分、任务分解、里程碑 |

---

## 快速开始

### 环境要求

- Flutter SDK ≥ 3.44.1
- Dart SDK ≥ 3.12.1
- Android SDK 36
- JDK 21

### 安装运行

```bash
# 克隆项目
git clone https://github.com/OneCCY/WoAccount.git
cd WoAccount

# 安装依赖
flutter pub get

# 代码生成 (Drift/Riverpod)
dart run build_runner build

# 运行
flutter run
```

### 运行测试

```bash
# 全部测试
flutter test

# 数据库测试
flutter test test/unit/database/

# 查看覆盖率
flutter test --coverage
```

---

## 外部资源

- [Flutter 文档](https://flutter.dev/docs)
- [Riverpod 文档](https://riverpod.dev/)
- [Drift 文档](https://drift.simonbinder.eu/)
- [通义千问 API](https://help.aliyun.com/zh/dashscope/)
- [DeepSeek API](https://platform.deepseek.com/)
