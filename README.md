# WoAccount - AI智能记账App

> **架构策略**: 本地优先 (Local-First)，个人开发者自用场景
>
> **技术栈**: Flutter + SQLite (Drift) + LLM API (通义千问) + 本地规则引擎，无后端服务

---

## 核心功能

- **智能记账**: 输入"午饭拉面25"，AI自动识别金额和分类
- **AI对话助手**: 自然语言查询历史账单
- **消费洞察**: AI主动分析消费规律和异常
- **预算管理**: 设置月度预算，超支提醒

---

## 文档目录

| 序号 | 文档 | 描述 |
|------|------|------|
| 01 | [需求分析](docs/project-workflow/01-requirements.md) | 项目背景、目标用户、功能清单、验收标准 |
| 02 | [市场调研](docs/project-workflow/02-market-research.md) | 市场概况、竞品分析、差异化定位 |
| 03 | [技术选型](docs/project-workflow/03-tech-stack.md) | 技术栈方案对比与选择 |
| 04 | [产品设计](docs/project-workflow/04-product-design.md) | 信息架构、页面设计、交互流程、UI规范 |
| 05 | [架构设计](docs/project-workflow/05-architecture.md) | 系统架构、目录结构、数据库设计、模块设计 |
| 06 | [开发计划](docs/project-workflow/06-development-plan.md) | 开发阶段、任务分解、里程碑定义 |
| 07 | [测试策略](docs/project-workflow/07-testing-strategy.md) | 测试金字塔、测试用例、AI准确率测试 |
| 08 | [部署发布](docs/project-workflow/08-deployment.md) | CI/CD、构建流程 |
| 09 | [迭代运营](docs/project-workflow/09-iteration.md) | 版本规划、迭代策略 |
| -- | [项目工作流总览](docs/project-workflow/PROJECT_WORKFLOW.md) | 全流程概览 |

---

## 技术栈

| 层级 | 技术 | 版本 |
|------|------|------|
| 前端框架 | Flutter | 3.x |
| 编程语言 | Dart | 3.x |
| 状态管理 | Riverpod | 2.x |
| 本地数据库 | SQLite (Drift) | 2.x |
| AI服务 | LLM API (通义千问) + 本地规则引擎 | - |

---

## 项目结构

```
lib/
├── main.dart
├── app.dart
├── core/              # 主题、常量、工具类、错误处理
├── features/          # 功能模块 (Clean Architecture)
│   ├── transaction/   # 记账
│   ├── category/      # 分类管理
│   ├── stats/         # 统计图表
│   ├── ai/            # AI解析、规则引擎、对话
│   ├── budget/        # 预算管理
│   └── settings/      # 设置
├── shared/            # 共享数据库、通用Widget
└── config/            # 路由、依赖注入、环境配置
```

---

## 外部资源

- [Flutter 官方文档](https://flutter.dev/docs)
- [通义千问 API](https://help.aliyun.com/zh/dashscope/)
- [Riverpod 文档](https://riverpod.dev/)
- [Drift 文档](https://drift.simonbinder.eu/)
