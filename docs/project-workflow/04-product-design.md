# 04 - 产品设计文档 (Technical Specification)

> **版本**: v4.0 | **更新日期**: 2026-06-03 | **状态**: AI深度整合，智能记账体验

---

## ⚠️ 重要说明

本文档为**高层产品设计**，详细的技术实现文档请参考：

| 模块 | 详细文档 | 内容 |
|------|----------|------|
| UI规范 | [ui-design-system.md](../superpowers/specs/2026-06-04-ui-design-system.md) | 设计原则、字体系统、颜色系统、组件规范、动画规范 |
| 交互流程 | [interaction-flow.md](../superpowers/ux/interaction-flow.md) | 页面导航、手势交互、动画设计、反馈设计 |
| AI能力 | [ai-overview.md](../superpowers/ai/ai-overview.md) | AI能力矩阵、处理流程、数据流 |
| Prompt设计 | [prompt-design.md](../superpowers/llm/prompt-design.md) | 记账解析、AI对话、消费洞察 |

---

## 4.1 信息架构

### 4.1.1 页面层级结构

```
┌─────────────────────────────────────────────────────────────────┐
│                      WoAccount 页面架构                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Shell (底部导航: 账单 | 记账 | 我的)                           │
│  ├── TransactionListPage (账单 - 左Tab)                        │
│  │   ├── ViewSwitcher (日/周/月视图切换)                       │
│  │   │   ├── DayView (日视图 - 当日交易列表)                  │
│  │   │   ├── WeekView (周视图 - 7天卡片+分组列表)             │
│  │   │   └── MonthView (月视图 - 日历网格)                    │
│  │   ├── PeriodNavigator (周期导航)                           │
│  │   ├── InsightCardWidget (洞察卡片)                         │
│  │   ├── BudgetEntryWidget (预算入口 - 搜索栏右侧)            │
│  │   └── TransactionDetailPage (账单详情)                     │
│  │                                                              │
│  ├── HomePage (记账 - 中Tab，核心入口)                          │
│  │   ├── AiEntryWidget (AI助手入口卡片)                        │
│  │   └── TransactionInputWidget (记账输入栏 - 固定底部)        │
│  │       ├── ManualEntryButton (手动记账→全屏记账页)            │
│  │       ├── TextInputField (文本输入 - 中间)                  │
│  │       └── PhotoUploadButton (拍照识别 - 右侧)               │
│  │                                                              │
│  ├── ManualEntryPage (手动记账 - 全屏页面)                      │
│  │   ├── TypeTabs (支出/收入/其他)                             │
│  │   ├── AmountDisplay (金额显示)                              │
│  │   ├── CategoryGrid (分类网格 - 跟随类型切换)                │
│  │   ├── NoteRow (备注+日期)                                   │
│  │   └── NumPad (数字键盘)                                     │
│  │                                                              │
│  └── ProfilePage (我的 - 右Tab)                                │
│      ├── UserInfoWidget (用户信息)                              │
│      ├── FuncButtonBar (功能按钮栏 - 6个)                      │
│      │   ├── PasswordLockPage (密码锁)                         │
│      │   ├── ThemeSwitchSheet (主题切换)                       │
│      │   ├── AccountBookPage (我的账本)                        │
│      │   ├── BudgetManagePage (预算管理)                       │
│      │   │   ├── TotalBudgetCard (总预算卡片)                 │
│      │   │   ├── MonthBudgetView (月预算)                     │
│      │   │   ├── WeekBudgetView (周预算)                      │
│      │   │   └── DayBudgetView (日预算)                       │
│      │   ├── CategoryManagePage (分类管理)                     │
│      │   └── MorePage (更多)                                   │
│      ├── AiAssistantPage (AI助手 - 全屏对话)                   │
│      │   ├── ChatMessageListWidget (对话列表)                  │
│      │   ├── ChatInputWidget (输入框)                          │
│      │   └── QuickQueryWidget (快捷查询)                      │
│      ├── DataBackupPage (数据备份)                              │
│      ├── BillImportPage (账单导入)                              │
│      ├── BillExportPage (账单导出)                              │
│      ├── FeedbackPage (用户反馈)                               │
│      ├── RecycleBinPage (账本回收站)                           │
│      └── SettingsPage (设置)                                    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4.1.2 路由配置

```dart
// lib/config/routes/app_router.dart

import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Shell路由 (底部导航: 账单 | 记账 | 我的)
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        // 账单列表 (左Tab)
        GoRoute(
          path: '/transactions',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TransactionListPage(),
          ),
          routes: [
            // 账单详情
            GoRoute(
              path: ':id',
              builder: (context, state) => TransactionDetailPage(
                transactionId: state.pathParameters['id']!,
              ),
            ),
          ],
        ),
        // 记账首页 (中Tab - 核心入口)
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomePage(),
          ),
        ),
        // 我的 (右Tab)
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProfilePage(),
          ),
        ),
      ],
    ),
  
    // 非Shell路由
    GoRoute(
      path: '/ai-assistant',
      builder: (context, state) => const AiAssistantPage(),
    ),
    GoRoute(
      path: '/budget-setting',
      builder: (context, state) => const BudgetSettingPage(),
    ),
    GoRoute(
      path: '/category-manage',
      builder: (context, state) => const CategoryManagePage(),
    ),
    GoRoute(
      path: '/data-export',
      builder: (context, state) => const DataExportPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
```

---

## 4.2 核心页面设计

### 4.2.1 记账页 - 快速记账

记账页为中Tab核心入口，极度聚焦于记账输入。页面仅包含AI助手入口和底部固定输入栏，中间留白。

设计原则：**记账页面只做一件事——让用户快速记下一笔。**

```
┌─────────────────────────────────────────┐
│  WoAccount                    ⚙️ 设置   │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  🤖 AI 助手                         ││
│  │  智能记账 · 消费分析 · 问答查询    ││
│  │                              ›      ││
│  └─────────────────────────────────────┘│
│                                         │
│                                         │
│              (留白区域)                 │
│                                         │
│                                         │
├─────────────────────────────────────────┤
│  ┌───┬─────────────────────────┬───────┐│
│  │ ➕ │ 输入消费描述...          │  📷  ││
│  └───┴─────────────────────────┴───────┘│
├─────────────────────────────────────────┤
│  [账单]      [记账]       [我的]        │
└─────────────────────────────────────────┘
```

**记账输入栏规格**:

| 位置 | 元素 | 功能 | 交互 |
|------|------|------|------|
| 左侧 | ➕ 手动记账按钮 | 打开手动记账表单 | 点击 |
| 中间 | 文本输入框 | 输入消费描述 | 输入后AI自动解析 |
| 右侧 | 📷 拍照按钮 | 拍照/相册识别小票 | 点击，调用相机 |

**语音输入交互**:

| 操作 | 响应 | 说明 |
|------|------|------|
| 长按底部"记账"Tab (500ms) | 触发语音输入浮层 | 震动反馈 |
| 松开按钮 | 发送语音，AI解析 | 正常流程 |
| 按住后左上滑动 | 取消语音输入 | 浮层消失，不发送 |
| 按住后右上滑动 | 语音转文字 | 填入文本输入框 |

**组件规格**:

| 组件 | 功能 | 状态管理 | 数据源 |
|------|------|----------|--------|
| TransactionInputWidget | 记账输入栏 | Riverpod | 本地 |
| ManualEntryButton | 手动记账按钮 | - | - |
| TextInputField | 文本输入框 | 本地State | 用户输入 |
| PhotoUploadButton | 拍照识别按钮 | - | 相机/相册 |
| AiResultCardWidget | AI解析结果 | Riverpod | AI服务 |
| TodayTransactionListWidget | 今日列表 | Riverpod | SQLite |
| InsightCardWidget | 洞察卡片 | Riverpod | AI服务 |
| AiEntryWidget | AI助手入口卡片 | - | - |

### 4.2.2 账单页 - 交易记录浏览

账单页为左Tab，展示所有交易记录，支持日/周/月三种视图切换。

**日视图**：当天交易列表，顶部洞察+日统计，无日期头部。

```
┌─────────────────────────────────────────┐
│  [日] [周] [月]       ‹ 6月2日 周一 ›  │
├─────────────────────────────────────────┤
│  💡 今日消费已超过日均预算的80%        │
│                                         │
│  本日支出¥71         本日收入¥0        │
│  ─────────────────────────────────────  │
│  🍜 午饭拉面                    -¥25.00 │
│  🚗 打车去公司                  -¥28.00 │
│  ☕ 下午茶咖啡                  -¥18.00 │
├─────────────────────────────────────────┤
│  [账单]      [记账]       [我的]        │
└─────────────────────────────────────────┘
```

**周视图（默认）**：顶部洞察 → 7天日期卡片(响应式等分) → 周统计 → 按日分组列表。

```
┌─────────────────────────────────────────┐
│  [日] [周] [月]     ‹ 6月2日-6月8日 ›  │
├─────────────────────────────────────────┤
│  💡 本周餐饮支出占比最高，达45%        │
│                                         │
│  ┌──┬──┬──┬──┬──┬──┬──┐               │
│  │日│一│二│三│四│五│六│  ← 响应式等分 │
│  │ 1│ 2│ 3│ 4│ 5│ 6│ 7│               │
│  │  │✓ │  │  │  │  │  │  ← 今日高亮   │
│  └──┴──┴──┴──┴──┴──┴──┘               │
│  本周支出¥227      本周收入¥0          │
│  ─────────────────────────────────────  │
│  📅 6月2日 周一                 支出¥71 │
│  🍜 午饭拉面 -¥25  🚗 打车 -¥28       │
│  ☕ 咖啡 -¥18                          │
├─────────────────────────────────────────┤
│  📅 6月1日 周日                支出¥156 │
│  🛒 超市购物 -¥156                     │
├─────────────────────────────────────────┤
│  [账单]      [记账]       [我的]        │
└─────────────────────────────────────────┘
```

**月视图**：日历网格，每格显示当日收支金额。

```
┌─────────────────────────────────────────┐
│  [日] [周] [月]         ‹ 2025年6月 ›  │
├─────────────────────────────────────────┤
│  总支出¥3,280  总收入¥12,000  结余¥8,720│
├─────────────────────────────────────────┤
│  日  一  二  三  四  五  六             │
│ 26  27  28  29  30  31   1              │
│                              -156       │
│  2   3   4   5   6   7   8             │
│ -71  今天                               │
│  9  10  11  12  13  14  15             │
│-320 -45     -128         +12000        │
│ 16  17  18  19  20  21  22             │
│-890 -56     -210           -178        │
│ 23  24  25  26  27  28  29             │
│     -67             -430               │
│ 30  [1]  [2]  [3]  [4]  [5]           │
│-605                                     │
├─────────────────────────────────────────┤
│  💡 本月日均支出¥109，低于上月12%      │
├─────────────────────────────────────────┤
│  [账单]      [记账]       [我的]        │
└─────────────────────────────────────────┘
```

**组件规格**:

| 组件 | 功能 | 状态管理 | 数据源 |
|------|------|----------|--------|
| ViewSwitcher | 日/周/月切换 | 本地State | - |
| PeriodNavigator | 周期导航(‹ ›) | 本地State | - |
| DayView | 日视图列表 | Riverpod | SQLite |
| WeekView | 周视图卡片+列表 | Riverpod | SQLite |
| MonthView | 月视图日历 | Riverpod | SQLite |
| InsightCardWidget | 洞察卡片 | Riverpod | AI服务 |

---

### 4.2.3 AI解析确认卡片

```
┌─────────────────────────────────────────┐
│  ┌─────────────────────────────────────┐│
│  │         🤖 AI解析结果                ││
│  │  ─────────────────────────────────  ││
│  │                                     ││
│  │  原始输入: 午饭吃了碗拉面25元       ││
│  │                                     ││
│  │  ┌───────────────────────────────┐ ││
│  │  │  💰 金额:     ¥25.00         │ ││
│  │  │  🍜 分类:     餐饮 > 午餐     │ ││
│  │  │  📝 描述:     午饭拉面         │ ││
│  │  │  📅 日期:     2025-01-15      │ ││
│  │  │  ⏱️ 解析:     850ms (LLM)    │ ││
│  │  └───────────────────────────────┘ ││
│  │                                     ││
│  │  置信度: ████████░░ 92%            ││
│  │                                     ││
│  │  [修改分类]  [修改金额]  [修改日期] ││
│  │                                     ││
│  │  [取消]              [确认记账]     ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

**交互规格**:


| 操作           | 响应               | 状态变化     |
| -------------- | ------------------ | ------------ |
| 点击"修改分类" | 弹出分类选择器     | 更新category |
| 点击"修改金额" | 弹出金额输入框     | 更新amount   |
| 点击"修改日期" | 弹出日期选择器     | 更新date     |
| 点击"确认记账" | 保存交易，刷新列表 | 添加到数据库 |
| 点击"取消"     | 关闭卡片，清空输入 | 重置状态     |

### 4.2.3 我的页面 - 个人信息 + 功能入口

我的页面顶部显示用户信息，中间为功能按钮栏和AI助手入口，下方为列表菜单。

```
┌─────────────────────────────────────────┐
│  我的                                   │
├─────────────────────────────────────────┤
│  👤 用户头像    用户昵称                │
│                 记账达人 · 连续记账15天 │
├─────────────────────────────────────────┤
│  🔒      🎨      📒      📂      ⋯    │
│  密码锁  主题切换 我的账本 分类管理 更多│
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────────┐│
│  │  🤖 AI 助手                         ││
│  │  智能记账 · 消费分析 · 问答查询    ││
│  │                              ›      ││
│  └─────────────────────────────────────┘│
├─────────────────────────────────────────┤
│  数据与服务                             │
│  ─────────────────────────────────────  │
│  ☁️ 数据备份                            │
│  ─────────────────────────────────────  │
│  🔄 导入导出                            │
│  ─────────────────────────────────────  │
│  💬 用户反馈                            │
│  ─────────────────────────────────────  │
│  🗑️ 账本回收站                          │
├─────────────────────────────────────────┤
│  ⚙️ 设置                                │
├─────────────────────────────────────────┤
│  [账单]      [记账]       [我的]        │
└─────────────────────────────────────────┘
```

**功能按钮栏规格** (6个):

| 按钮 | 图标 | 功能 | 跳转 |
|------|------|------|------|
| 密码锁 | 🔒 | 设置App密码锁 | 密码锁设置页 |
| 主题切换 | 🎨 | 切换亮色/暗色主题 | BottomSheet选择 |
| 我的账本 | 📒 | 多账本管理 | 账本列表页 |
| 预算管理 | 💰 | 月/周/日预算设置 | 预算管理页 |
| 分类管理 | 📂 | 管理收支分类 | 分类管理页 |
| 更多 | ⋯ | 更多功能入口 | 更多页面 |

**组件规格**:

| 组件 | 功能 | 状态管理 | 数据源 |
|------|------|----------|--------|
| UserInfoWidget | 用户信息 | Riverpod | 本地 |
| FuncButtonBar | 功能按钮栏(5个) | 本地State | - |
| AiEntryWidget | AI助手入口 | - | - |
| ChatMessageListWidget | 对话列表 | Riverpod | 对话历史 |
| ChatInputWidget | 输入框 | 本地State | 用户输入 |
| QuickQueryWidget | 快捷查询 | 本地State | 预设查询 |

### 4.2.4 我的账本 - 多账本管理

支持创建多个独立账本，每个账本拥有独立的分类、预算和交易数据。

```
┌─────────────────────────────────────────┐
│  ← 我的账本                             │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────────┐│
│  │  默认                  [个人账本]   ││
│  │                                     ││
│  │  📒 日常记账                        ││
│  │                                     ││
│  │  本月支出    本月收入     总笔数    ││
│  │  ¥6,540     ¥12,000      328       ││
│  └─────────────────────────────────────┘│
│                                         │
│  其他账本                               │
│  ─────────────────────────────────────  │
│  ✈️ 旅行账本  [旅行]        ¥2,580  ›  │
│     2026年日本旅行              45笔    │
│  ─────────────────────────────────────  │
│  🏠 家庭账本  [家庭]        ¥8,920  ›  │
│     2位成员                    156笔    │
│  ─────────────────────────────────────  │
│  💼 生意账本  [生意]       ¥32,100  ›  │
│     小店日常流水                 89笔    │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │         + 新建账本                  ││
│  └─────────────────────────────────────┘│
│                                         │
│  每个账本独立管理，数据互不影响         │
│  切换账本后，首页、统计等数据随之更新   │
└─────────────────────────────────────────┘
```

**账本类型**:

| 类型 | 图标 | 用途 | 特性 |
|------|------|------|------|
| 个人 | 👤 | 个人日常记账 | 默认类型，单人使用 |
| 家庭 | 🏠 | 家庭共同记账 | 支持邀请成员协作 |
| 旅行 | ✈️ | 旅行专项记账 | 可设置起止日期 |
| 生意 | 💼 | 副业/小店流水 | 独立收支统计 |
| 其他 | 📁 | 自定义用途 | 灵活配置 |

**数据隔离规则**:

| 维度 | 隔离级别 |
|------|----------|
| 交易记录 | 完全隔离 |
| 分类体系 | 完全隔离 |
| 预算设置 | 完全隔离 |
| AI学习 | 跟随账本 |
| 系统设置 | 全局共享 |

---

## 4.3 交互流程

### 4.3.1 记账核心流程

```
┌─────────────────────────────────────────────────────────────────┐
│                      记账流程状态机                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐  │
│  │  Idle   │────▶│ Parsing │────▶│ Confirm │────▶│ Saving  │  │
│  │  空闲    │     │ 解析中  │     │ 确认中  │     │ 保存中  │  │
│  └─────────┘     └─────────┘     └─────────┘     └─────────┘  │
│       │               │               │               │        │
│       │               │               │               ▼        │
│       │               │               │         ┌─────────┐    │
│       │               │               │         │ Success │    │
│       │               │               │         │ 成功    │    │
│       │               │               │         └─────────┘    │
│       │               │               │               │        │
│       │               ▼               ▼               ▼        │
│       │         ┌─────────┐     ┌─────────┐         │          │
│       │         │  Error  │◀────│ Editing │         │          │
│       │         │ 错误    │     │ 编辑中  │         │          │
│       │         └─────────┘     └─────────┘         │          │
│       │               │               │               │        │
│       ◀───────────────┴───────────────┴───────────────┘        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**状态转换表**:


| 当前状态 | 触发事件         | 下一状态 | 动作         |
| -------- | ---------------- | -------- | ------------ |
| Idle     | 用户点击"记一笔" | Parsing  | 调用AI解析   |
| Parsing  | 解析成功         | Confirm  | 显示结果卡片 |
| Parsing  | 解析失败         | Error    | 显示错误提示 |
| Confirm  | 用户点击"确认"   | Saving   | 保存交易     |
| Confirm  | 用户点击"修改"   | Editing  | 显示编辑界面 |
| Confirm  | 用户点击"取消"   | Idle     | 清空输入     |
| Editing  | 用户确认修改     | Confirm  | 更新结果     |
| Saving   | 保存成功         | Success  | 显示成功提示 |
| Saving   | 保存失败         | Error    | 显示错误提示 |
| Success  | 自动延时         | Idle     | 刷新列表     |
| Error    | 用户点击"重试"   | Parsing  | 重新解析     |
| Error    | 用户点击"取消"   | Idle     | 清空输入     |

### 4.3.2 AI查询流程

```
┌─────────────────────────────────────────────────────────────────┐
│                      AI查询流程                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  用户输入: "我上周剪过头发吗？"                                  │
│              │                                                  │
│              ▼                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Step 1: 意图识别 (LLM)                                  │   │
│  │  ├── 意图: existential (存在性查询)                       │   │
│  │  ├── 时间: 上周 (2025-01-06 ~ 2025-01-12)                │   │
│  │  ├── 分类: 美容/理发                                      │   │
│  │  └── 关键词: 剪头发、理发                                 │   │
│  └─────────────────────────┬───────────────────────────────┘   │
│                            │                                    │
│                            ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Step 2: Function Calling                                │   │
│  │  query_transactions({                                    │   │
│  │    start_date: "2025-01-06",                             │   │
│  │    end_date: "2025-01-12",                               │   │
│  │    category: "美容",                                      │   │
│  │    keyword: "理发"                                        │   │
│  │  })                                                      │   │
│  └─────────────────────────┬───────────────────────────────┘   │
│                            │                                    │
│                            ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Step 3: 数据库查询                                      │   │
│  │  SELECT * FROM transactions                              │   │
│  │  WHERE user_id = ?                                       │   │
│  │    AND transaction_date BETWEEN '2025-01-06' AND '2025-01-12' │
│  │    AND (category_id IN (美容ID)                           │   │
│  │         OR description LIKE '%理发%')                    │   │
│  └─────────────────────────┬───────────────────────────────┘   │
│                            │                                    │
│                            ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Step 4: 结果处理                                        │   │
│  │  ├── 有结果: 返回交易列表                                │   │
│  │  └── 无结果: 返回空列表                                  │   │
│  └─────────────────────────┬───────────────────────────────┘   │
│                            │                                    │
│                            ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Step 5: LLM生成回复                                    │   │
│  │  "上周三(1月10日)你在XX理发店消费了38元，是剪头发的费用。" │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4.4 UI设计规范

### 4.4.1 颜色系统

```dart
// lib/core/theme/colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // 主色调
  static const Color primary = Color(0xFF4CAF50);      // 绿色 - 主要操作
  static const Color secondary = Color(0xFF2196F3);    // 蓝色 - 次要操作
  static const Color accent = Color(0xFFFF9800);       // 橙色 - 强调
  
  // 语义色
  static const Color success = Color(0xFF4CAF50);      // 成功
  static const Color warning = Color(0xFFFF9800);      // 警告
  static const Color error = Color(0xFFF44336);        // 错误
  static const Color info = Color(0xFF2196F3);         // 信息
  
  // 收支色
  static const Color income = Color(0xFF4CAF50);       // 收入 - 绿色
  static const Color expense = Color(0xFFF44336);      // 支出 - 红色
  
  // 背景色
  static const Color background = Color(0xFFFFFFFF);   // 主背景
  static const Color surface = Color(0xFFF5F5F5);      // 卡片背景
  static const Color scaffold = Color(0xFFFAFAFA);     // 页面背景
  
  // 文字色
  static const Color textPrimary = Color(0xFF212121);  // 主文字
  static const Color textSecondary = Color(0xFF757575); // 次要文字
  static const Color textHint = Color(0xFFBDBDBD);     // 提示文字
  static const Color textDisabled = Color(0xFFE0E0E0); // 禁用文字
  
  // 分类颜色
  static const Map<String, Color> categoryColors = {
    '餐饮': Color(0xFFFF9800),  // 橙色
    '交通': Color(0xFF2196F3),  // 蓝色
    '购物': Color(0xFFE91E63),  // 粉色
    '住房': Color(0xFF9C27B0),  // 紫色
    '娱乐': Color(0xFF4CAF50),  // 绿色
    '教育': Color(0xFF00BCD4),  // 青色
    '医疗': Color(0xFFF44336),  // 红色
    '社交': Color(0xFFFF5722),  // 深橙
    '其他': Color(0xFF607D8B),  // 灰蓝
  };
  
  // 分类图标
  static const Map<String, String> categoryIcons = {
    '餐饮': '🍜',
    '交通': '🚗',
    '购物': '🛒',
    '住房': '🏠',
    '娱乐': '🎮',
    '教育': '📚',
    '医疗': '💊',
    '社交': '👤',
    '其他': '💰',
  };
}
```

### 4.4.2 字体规范

```dart
// lib/core/theme/text_styles.dart

import 'package:flutter/material.dart';

class AppTextStyles {
  // 标题
  static const TextStyle headline1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );
  
  // 正文
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.15,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.1,
  );
  
  // 辅助
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.4,
  );
  
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    letterSpacing: 1.5,
  );
  
  // 金额
  static const TextStyle amount = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  static const TextStyle amountLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -1,
  );
  
  static const TextStyle amountSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
}
```

### 4.4.3 间距规范

```dart
// lib/core/theme/dimensions.dart

class AppDimensions {
  // 间距
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;
  
  // 圆角
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;
  static const double radiusFull = 999;
  
  // 阴影
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
}
```

### 4.4.4 组件规范

```dart
// lib/shared/widgets/common_card.dart

import 'package:flutter/material.dart';

class CommonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  
  const CommonCard({
    Key? key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
        decoration: BoxDecoration(
          color: color ?? AppColors.surface,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppDimensions.radiusMd,
          ),
          boxShadow: boxShadow ?? AppDimensions.shadowSm,
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppDimensions.spacingMd),
          child: child,
        ),
      ),
    );
  }
}

// lib/shared/widgets/common_button.dart

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  
  const CommonButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _getBackgroundColor(),
        foregroundColor: _getForegroundColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingMd,
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: AppDimensions.spacingSm),
                ],
                Text(text),
              ],
            ),
    );
  }
  
  Color _getBackgroundColor() {
    switch (type) {
      case ButtonType.primary:
        return AppColors.primary;
      case ButtonType.secondary:
        return AppColors.secondary;
      case ButtonType.outline:
        return Colors.transparent;
      case ButtonType.text:
        return Colors.transparent;
    }
  }
  
  Color _getForegroundColor() {
    switch (type) {
      case ButtonType.primary:
        return Colors.white;
      case ButtonType.secondary:
        return Colors.white;
      case ButtonType.outline:
        return AppColors.primary;
      case ButtonType.text:
        return AppColors.primary;
    }
  }
}

enum ButtonType { primary, secondary, outline, text }
```

---

## 4.5 动画规范

### 4.5.1 动画配置

```dart
// lib/core/theme/animations.dart

class AppAnimations {
  // 时长
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  
  // 曲线
  static const Curve curveEaseIn = Curves.easeIn;
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveSpring = Curves.elasticOut;
  
  // 页面切换动画
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Curve pageTransitionCurve = Curves.easeInOut;
  
  // 卡片动画
  static const Duration cardAnimationDuration = Duration(milliseconds: 200);
  static const Curve cardAnimationCurve = Curves.easeOut;
  
  // 列表动画
  static const Duration listItemAnimationDuration = Duration(milliseconds: 250);
  static const Curve listItemAnimationCurve = Curves.easeOut;
}
```

### 4.5.2 动画示例

```dart
// 卡片出现动画
class FadeInCard extends StatelessWidget {
  final Widget child;
  final Duration delay;
  
  const FadeInCard({
    Key? key,
    required this.child,
    this.delay = Duration.zero,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: AppAnimations.cardAnimationDuration,
      curve: AppAnimations.cardAnimationCurve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
```

---

## 4.6 响应式设计

### 4.6.1 断点定义

```dart
// lib/core/theme/breakpoints.dart

class AppBreakpoints {
  static const double mobile = 360;
  static const double tablet = 600;
  static const double desktop = 1024;
  
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < tablet;
  
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet &&
      MediaQuery.of(context).size.width < desktop;
  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktop;
}
```

### 4.6.2 布局适配

```dart
// 响应式布局示例
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  
  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppBreakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= AppBreakpoints.tablet) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}
```

---

## 4.7 无障碍设计

### 4.7.1 无障碍配置

```dart
// 无障碍示例
class AccessibleButton extends StatelessWidget {
  final String label;
  final String hint;
  final VoidCallback onTap;
  
  const AccessibleButton({
    Key? key,
    required this.label,
    required this.hint,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          child: Text(
            label,
            style: AppTextStyles.body1.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
```

### 4.7.2 无障碍检查清单

- [ ]  所有交互元素有Semantics标签
- [ ]  颜色对比度 > 4.5:1
- [ ]  触摸目标 > 48x48dp
- [ ]  支持系统字体缩放
- [ ]  支持屏幕阅读器
- [ ]  焦点顺序合理

---

## 4.8 AI 智能功能体系

### 4.8.1 设计理念

WoAccount 的核心差异化：**AI 不是附加功能，而是记账体验本身**。

市场现状分析：
- 随手记/鲨鱼记账：AI 作为辅助（语音转文字、OCR），核心仍是手动表单
- Copilot Money/Cleo：AI 对话式，但依赖银行连接，不支持手动记账
- YNAB：预算理念强，但无 AI 能力

**WoAccount 定位**：本地优先 + AI 原生，从输入到分析全链路智能化。

```
┌─────────────────────────────────────────────────────────────────┐
│                    WoAccount AI 能力全景                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  输入层                    理解层                    输出层      │
│  ┌──────────────┐        ┌──────────────┐        ┌──────────┐  │
│  │ 自然语言输入  │───────▶│ 意图识别     │───────▶│ 结构化记录│  │
│  │ 语音输入     │───────▶│ 实体提取     │───────▶│ 分类推荐 │  │
│  │ 拍照识别     │───────▶│ 上下文理解   │───────▶│ 智能补全 │  │
│  └──────────────┘        └──────────────┘        └──────────┘  │
│                                                                 │
│  分析层                    交互层                               │
│  ┌──────────────┐        ┌──────────────┐                      │
│  │ 消费模式学习  │───────▶│ 异常检测提醒 │                      │
│  │ 趋势预测     │───────▶│ 智能洞察推送 │                      │
│  │ 预算建议     │───────▶│ 对话式查询   │                      │
│  └──────────────┘        └──────────────┘                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

### 4.8.2 AI 核心功能矩阵

#### P0 - 记账输入智能化

| 功能 | 描述 | 触发方式 | 示例 |
|------|------|----------|------|
| 自然语言记账 | LLM 解析自由文本为结构化记录 | 输入框输入 | "午饭拉面25" → 金额25/餐饮/午餐 |
| 语音记账 | 语音识别 + LLM 解析 | 长按Tab/点击麦克风 | 语音"打车28块" → 金额28/交通/打车 |
| 拍照识别 | OCR + LLM 解析小票/发票 | 点击📷按钮 | 拍摄餐厅小票 → 自动提取多项消费 |
| 智能补全 | 输入时实时推荐分类和金额 | 输入过程 | 输入"星" → 推荐"餐饮/饮料" |
| 重复检测 | 检测疑似重复录入 | 提交时 | 5分钟内相同金额+分类 → 提示确认 |

#### P0 - AI 智能分析

| 功能 | 描述 | 展示位置 | 触发 |
|------|------|----------|------|
| 消费洞察卡片 | 自动生成当日/当周洞察 | 首页底部 | 每次打开App |
| 分类趋势 | 各分类消费趋势对比 | 我的→统计 | 切换月份时 |
| 异常检测 | 检测异常大额或频率突变 | 首页提醒卡片 | 实时 |
| 月末总结 | AI 生成月度消费报告 | 推送通知 + AI页面 | 每月1日 |

#### P1 - AI 对话助手

| 功能 | 描述 | 示例 |
|------|------|------|
| 消费查询 | 自然语言查询历史消费 | "上个月餐饮花了多少" |
| 存在性查询 | 确认某笔消费是否发生 | "我上周剪过头发吗" |
| 趋势分析 | 消费趋势对比分析 | "这个月比上个月多花了多少" |
| 预算管理 | 通过对话设置/调整预算 | "把餐饮预算改成1500" |
| 消费建议 | 个性化省钱建议 | "分析一下我哪里可以省钱" |

#### P2 - 智能预测与建议

| 功能 | 描述 | 价值 |
|------|------|------|
| 月末预测 | 预测本月总消费趋势 | 提前控制支出 |
| 预算建议 | 基于历史数据推荐预算 | 科学分配资金 |
| 周期识别 | 自动识别周期性消费（房租、订阅） | 减少重复录入 |
| 消费健康评分 | 综合评估消费习惯 | 可视化消费健康度 |

---

### 4.8.3 AI 记账流程详解

#### 自然语言解析流程

```
用户输入: "昨天跟朋友吃了火锅AA制，我那份128"
         │
         ▼
┌─────────────────────────────────────────────────────────┐
│  Step 1: LLM 意图识别                                    │
│  ├── 意图: 记账 (expense)                                │
│  ├── 置信度: 95%                                         │
│  └── 上下文: 有"AA制"关键词，需特殊处理                  │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Step 2: 实体提取                                        │
│  ├── 金额: 128.00                                        │
│  ├── 分类: 餐饮 > 火锅                                   │
│  ├── 日期: 昨天 (2026-06-02)                             │
│  ├── 描述: 跟朋友吃火锅                                  │
│  └── 备注: AA制，仅记录自己份额                          │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Step 3: 智能增强                                        │
│  ├── 匹配历史: 上次火锅 2026-05-15，¥156               │
│  ├── 金额校验: 128 在合理范围内                          │
│  └── 重复检测: 未发现重复                                │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Step 4: 确认卡片                                        │
│  ┌───────────────────────────────────────┐               │
│  │  💰 金额: ¥128.00                    │               │
│  │  🍜 分类: 餐饮 > 火锅                │               │
│  │  📝 描述: 跟朋友吃火锅 (AA)          │               │
│  │  📅 日期: 2026-06-02                 │               │
│  │  ⚡ 与上次火锅间隔18天               │               │
│  │                                       │               │
│  │  [修改]               [确认记账]      │               │
│  └───────────────────────────────────────┘               │
└─────────────────────────────────────────────────────────┘
```

#### 拍照识别流程

```
拍照/选择图片
    │
    ▼
┌──────────────────────────┐
│  图片预处理               │
│  ├── 裁剪/旋转校正        │
│  ├── 增强对比度           │
│  └── 去噪                │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│  OCR 文字识别             │
│  └── 本地模型 / 云端API  │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│  LLM 结构化解析           │
│  ├── 提取金额列表         │
│  ├── 提取商品名称         │
│  ├── 推断分类            │
│  └── 识别商家            │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────┐
│  多项消费确认卡片         │
│  ├── 支持逐项确认/修改    │
│  ├── 支持合并为单笔       │
│  └── 支持删除某项         │
└──────────────────────────┘
```

---

### 4.8.4 AI 洞察系统

#### 洞察类型

| 类型 | 触发条件 | 示例 |
|------|----------|------|
| 预警类 | 消费接近/超出预算 | "本月餐饮已花1,200元，达预算80%" |
| 趋势类 | 消费模式变化 | "本周外卖比上周增加45%" |
| 对比类 | 周期对比 | "本月日均消费比上月低12%" |
| 建议类 | 优化机会 | "你每周五在XX店消费，考虑办会员卡" |
| 回顾类 | 里程碑 | "本月已坚持记账30天，消费控制良好" |
| 异常类 | 异常消费 | "今日消费¥580，远超日均¥109" |

#### 洞察卡片设计

```
┌─────────────────────────────────────────┐
│  💡 智能洞察                            │
├─────────────────────────────────────────┤
│                                         │
│  ⚠️ 预警                                │
│  ┌─────────────────────────────────────┐│
│  │  本月餐饮已消费 ¥2,340              ││
│  │  达到预算的 80%                     ││
│  │  ████████░░                        ││
│  │  [查看明细]  [调整预算]             ││
│  └─────────────────────────────────────┘│
│                                         │
│  📊 趋势                                │
│  ┌─────────────────────────────────────┐│
│  │  本周外卖消费比上周增加 45%         ││
│  │  上周: ¥280 → 本周: ¥406           ││
│  │  [查看详情]                         ││
│  └─────────────────────────────────────┘│
│                                         │
│  🎯 回顾                                │
│  ┌─────────────────────────────────────┐│
│  │  恭喜！已连续记账 15 天              ││
│  │  消费控制良好，继续保持              ││
│  └─────────────────────────────────────┘│
│                                         │
└─────────────────────────────────────────┘
```

---

### 4.8.5 月度 AI 报告

每月1日自动生成，推送到AI助手页面。

```
┌─────────────────────────────────────────┐
│  📊 6月消费报告                         │
├─────────────────────────────────────────┤
│                                         │
│  总览                                   │
│  ┌─────────────────────────────────────┐│
│  │  支出  ¥6,540    收入  ¥12,000     ││
│  │  结余  ¥5,460    储蓄率  45.5%      ││
│  └─────────────────────────────────────┘│
│                                         │
│  🏆 本月亮点                            │
│  • 餐饮支出较上月减少 8%               │
│  • 连续记账 30 天                       │
│  • 储蓄率提升 5 个百分点               │
│                                         │
│  ⚠️ 需要关注                            │
│  • 购物支出较上月增加 22%              │
│  • 6月16日单日消费¥890，异常偏高       │
│                                         │
│  💡 AI 建议                            │
│  • 购物预算建议从¥1,200调整为¥1,000   │
│  • 外卖频率过高，建议每周减少2次       │
│                                         │
│  📈 消费趋势图                          │
│  ┌─────────────────────────────────────┐│
│  │  [折线图: 6月每日消费趋势]          ││
│  └─────────────────────────────────────┘│
│                                         │
│  [查看详情]  [分享报告]                  │
└─────────────────────────────────────────┘
```

---

### 4.8.6 记录体验优化

#### 记账成就系统

| 成就 | 条件 | 奖励 |
|------|------|------|
| 初来乍到 | 首次记账 | 🎉 |
| 坚持一周 | 连续记账7天 | ⭐ |
| 记账达人 | 连续记账30天 | 🏆 |
| 理财高手 | 月储蓄率>30% | 💎 |
| 分类大师 | 使用10+分类 | 📂 |
| AI伙伴 | 使用AI功能10次 | 🤖 |

#### 微交互设计

| 场景 | 交互 | 效果 |
|------|------|------|
| 记账成功 | 金额飞入今日列表 | 数字滚动动画 |
| 达成目标 | 屏幕撒花 | confetti 动画 + 震动 |
| 下拉刷新 | 自定义拉伸动画 | 品牌色弹性效果 |
| 删除记录 | 左滑 + 红色按钮 | 滑动惯性 + 确认 |
| 切换视图 | Tab切换 | 淡入淡出 + 轻微缩放 |
| 语音录制 | 脉冲圆环动画 | 波纹扩散效果 |

#### 桌面小组件

| 尺寸 | 内容 | 操作 |
|------|------|------|
| 小 (2x2) | 今日支出金额 | 点击打开App |
| 中 (4x2) | 今日支出 + 最近3笔 | 点击打开App |
| 大 (4x4) | 今日支出 + 本周趋势 + 快速记账 | 直接输入记账 |

---

### 4.8.7 AI 功能技术约束

| 维度 | 约束 | 说明 |
|------|------|------|
| 响应时间 | 自然语言解析 <2s | 用户可接受的等待上限 |
| 准确率 | 分类准确率 >90% | 持续学习提升 |
| 隐私 | 本地优先，云端可选 | 敏感数据不上传 |
| 离线 | 基础记账可用，AI降级 | 规则引擎兜底 |
| 成本 | 单次解析 <$0.01 | DeepSeek 低成本方案 |
| 缓存 | 相同输入命中缓存 | LRU + 24h 过期 |
