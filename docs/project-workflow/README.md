# WoAccount 项目工作流文档

> **版本**: v3.0 | **更新日期**: 2026-06-02 | **状态**: 已更新为本地优先方案

---

## 文档目录

| 序号 | 文档 | 描述 | 状态 |
|------|------|------|------|
| - | [PROJECT_WORKFLOW.md](PROJECT_WORKFLOW.md) | 项目总览文档 | v3.0 |
| 01 | [需求分析](01-requirements.md) | 功能需求、非功能需求、AI规格、数据流 | v3.0 |
| 02 | [市场调研](02-market-research.md) | 市场概况、竞品分析、技术差异化、SWOT分析 | v3.0 |
| 03 | [技术选型](03-tech-stack.md) | 技术栈对比、依赖清单、AI服务架构、安全策略 | v3.0 |
| 04 | [产品设计](04-product-design.md) | 信息架构、页面设计、交互流程、UI规范 | v3.0 |
| 05 | [架构设计](05-architecture.md) | Clean Architecture、数据库设计、模块设计 | v3.0 |
| 06 | [开发计划](06-development-plan.md) | 任务分解、里程碑定义、开发规范 | v3.0 |
| 07 | [测试策略](07-testing-strategy.md) | 测试金字塔、单元测试、集成测试、性能测试 | v3.0 |
| 08 | [部署发布](08-deployment.md) | CI/CD配置、构建流程 | v3.0 |
| 09 | [迭代运营](09-iteration.md) | 版本规划、迭代策略 | v3.0 |

---

## 项目概述

**WoAccount** 是一个 AI 驱动的智能记账 App：

- **零分类操作**: 用户只需输入描述，AI 自动分类
- **自然语言输入**: 支持"午饭拉面25"、"打车去公司23.5"等表达
- **AI Agent**: 支持自然语言查询、消费洞察、对话助手
- **本地优先**: 数据存储在本地 SQLite，保护用户隐私

---

## 技术架构

```
┌─────────────────────────────────────────────────────────┐
│                      Flutter App                         │
│  状态管理: Riverpod | 路由: go_router | 图表: fl_chart   │
├─────────────────────────────────────────────────────────┤
│                      本地数据库                          │
│                    SQLite (Drift)                        │
├─────────────────────────────────────────────────────────┤
│                      AI 服务                             │
│  规则引擎 (离线) + LLM API (通义千问) + Function Calling │
└─────────────────────────────────────────────────────────┘
```

---

## v3.0 更新内容

**架构策略调整为本地优先 (Local-First)**：

- 移除 Supabase 后端 (PostgreSQL、Auth、Realtime、Storage)
- 移除 Firebase 监控 (Crashlytics、Analytics)
- 移除用户认证系统 (登录/注册、JWT、Token管理)
- 移除云同步和多设备同步
- 移除 Row Level Security
- 保留 Clean Architecture 分层，未来可扩展

---

## 外部资源

- [Flutter 文档](https://flutter.dev/docs)
- [通义千问 API](https://help.aliyun.com/zh/dashscope/)
- [Riverpod 文档](https://riverpod.dev/)
- [Drift 文档](https://drift.simonbinder.eu/)

---

## 更新日志

| 日期 | 版本 | 更新内容 |
|------|------|----------|
| 2026-06-02 | v3.0 | 架构调整为本地优先，移除 Supabase/Firebase/认证系统 |
| 2025-01-15 | v2.0 | 重写所有文档，增加技术深度，新增AI Agent规格 |
| 2025-01-15 | v1.0 | 创建项目工作流文档体系 |
