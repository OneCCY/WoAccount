# 04 - 产品设计文档 (Technical Specification)

> **版本**: v3.2 | **更新日期**: 2026-06-02 | **状态**: 三Tab导航，AI移至我的，语音长按交互

## 4.1 信息架构

### 4.1.1 页面层级结构

```
┌─────────────────────────────────────────────────────────────────┐
│                      WoAccount 页面架构                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Shell (底部导航: 账单 | 记账 | 我的)                           │
│  ├── TransactionListPage (账单列表 - 左Tab)                     │
│  │   ├── FilterBarWidget (筛选栏)                              │
│  │   ├── SearchBarWidget (搜索栏)                              │
│  │   ├── GroupedTransactionListWidget (分组列表)               │
│  │   └── TransactionDetailPage (账单详情)                      │
│  │                                                              │
│  ├── HomePage (记账 - 中Tab，核心入口)                          │
│  │   ├── TransactionInputWidget (记账输入框)                    │
│  │   │   ├── ManualEntryButton (手动记账 - 左侧)               │
│  │   │   ├── TextInputField (文本输入 - 中间)                  │
│  │   │   └── PhotoUploadButton (拍照识别 - 右侧)               │
│  │   ├── AiResultCardWidget (AI解析结果卡片)                    │
│  │   ├── TodayTransactionListWidget (今日账单列表)              │
│  │   ├── InsightCardWidget (今日洞察)                          │
│  │   └── AiEntryWidget (AI助手入口卡片)                        │
│  │                                                              │
│  └── ProfilePage (我的 - 右Tab)                                │
│      ├── UserInfoWidget (用户信息)                              │
│      ├── AiAssistantPage (AI助手 - 全屏对话)                   │
│      │   ├── ChatMessageListWidget (对话列表)                  │
│      │   ├── ChatInputWidget (输入框)                          │
│      │   └── QuickQueryWidget (快捷查询)                      │
│      ├── StatsSection (统计概览 - 整合原统计页)                 │
│      │   ├── SummaryCardWidget (概览卡片)                      │
│      │   ├── PieChartWidget (饼图)                             │
│      │   └── CategoryRankingWidget (分类排行)                  │
│      ├── BudgetSettingPage (预算设置)                           │
│      ├── CategoryManagePage (分类管理)                          │
│      ├── DataExportPage (数据导出)                              │
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

### 4.2.1 首页 - 记账

首页为核心记账入口，左上角切换日/周/月视图，上方内容区可滚动，记账输入栏固定在底部导航上方。

**日视图**：当天交易列表，左右切换日期。

```
┌─────────────────────────────────────────┐
│  [日] [周] [月]       ‹ 6月2日 周一 ›  │
├─────────────────────────────────────────┤
│  📅 6月2日 周一                  ¥71.00 │
│  ─────────────────────────────────────  │
│  🍜 午饭拉面                    -¥25.00 │
│  🚗 打车去公司                  -¥28.00 │
│  ☕ 下午茶咖啡                  -¥18.00 │
│                                         │
│  💡 今日消费已超过日均预算的80%        │
│  🤖 AI 助手入口                        │
├─────────────────────────────────────────┤
│  ┌───┬─────────────────────────┬───────┐│
│  │ ➕ │ 午饭吃了碗拉面25元       │  📷  ││
│  └───┴─────────────────────────┴───────┘│
├─────────────────────────────────────────┤
│  [账单]      [记账]       [我的]        │
└─────────────────────────────────────────┘
```

**周视图（默认）**：展示一周7天每日消费概况卡片，下方为详细列表。

```
┌─────────────────────────────────────────┐
│  [日] [周] [月]     ‹ 6月2日-6月8日 ›  │
├─────────────────────────────────────────┤
│  ┌──┬──┬──┬──┬──┬──┬──┐               │
│  │日│一│二│三│四│五│六│  ← 7天卡片     │
│  │ 1│ 2│ 3│ 4│ 5│ 6│ 7│               │
│  │  │-71│ │  │  │  │  │  ← 今日高亮   │
│  └──┴──┴──┴──┴──┴──┴──┘               │
│  本周支出¥227      本周收入¥0          │
├─────────────────────────────────────────┤
│  📅 6月2日 周一                 支出¥71 │
│  🍜 午饭拉面 -¥25  🚗 打车 -¥28       │
│  ☕ 咖啡 -¥18                          │
├─────────────────────────────────────────┤
│  📅 6月1日 周日                支出¥156 │
│  🛒 超市购物 -¥156                     │
│                                         │
│  💡 本周餐饮支出占比最高               │
│  🤖 AI 助手入口                        │
├─────────────────────────────────────────┤
│  ┌───┬─────────────────────────┬───────┐│
│  │ ➕ │ 午饭吃了碗拉面25元       │  📷  ││
│  └───┴─────────────────────────┴───────┘│
├─────────────────────────────────────────┤
│  [账单]      [记账]       [我的]        │
└─────────────────────────────────────────┘
```

**月视图**：日历网格，每格显示当日收支。

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
│  ┌───┬─────────────────────────┬───────┐│
│  │ ➕ │ 午饭吃了碗拉面25元       │  📷  ││
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

### 4.2.2 AI解析确认卡片

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

### 4.2.3 我的页面 - 个人信息 + AI助手 + 统计概览

我的页面整合AI助手入口和统计功能，顶部显示统计概览，下方为个人设置入口。

```
┌─────────────────────────────────────────┐
│  我的                                   │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  👤 用户头像    用户昵称            ││
│  │                 消费等级 Lv.5       ││
│  └─────────────────────────────────────┘│
│                                         │
├─────────────────────────────────────────┤
│  📊 本月统计                            │
│  ┌─────────────────────────────────────┐│
│  │  总支出        ¥6,540              ││
│  │  总收入        ¥12,000             ││
│  │  结余          ¥5,460              ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  🥧 消费分类占比                    ││
│  │  ┌───────────────────────────────┐ ││
│  │  │         [饼图]                │ ││
│  │  └───────────────────────────────┘ ││
│  │  餐饮 35%  交通 20%  购物 18%      ││
│  │  住房 15%  娱乐 12%               ││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │  🏆 分类排行                        ││
│  │  1. 餐饮    ¥2,340  ████████░░ 35% ││
│  │  2. 交通    ¥1,308  █████░░░░░ 20% ││
│  │  3. 购物    ¥1,177  ████░░░░░░ 18% ││
│  │  4. 住房    ¥981    ███░░░░░░░ 15% ││
│  │  5. 娱乐    ¥785    ██░░░░░░░░ 12% ││
│  └─────────────────────────────────────┘│
│                                         │
│  [查看详细统计]                         │
│                                         │
├─────────────────────────────────────────┤
│  ┌─────────────────────────────────────┐│
│  │  🤖 AI 助手                         ││
│  │  智能记账 · 消费分析 · 问答查询    ││
│  │                              ›      ││
│  └─────────────────────────────────────┘│
│                                         │
├─────────────────────────────────────────┤
│  ⚙️ 设置与管理                          │
│  ─────────────────────────────────────  │
│  💰 预算设置                            │
│  ─────────────────────────────────────  │
│  📂 分类管理                            │
│  ─────────────────────────────────────  │
│  📤 数据导出                            │
│  ─────────────────────────────────────  │
│  ⚙️ 系统设置                            │
│                                         │
├─────────────────────────────────────────┤
│  [账单]      [记账]       [我的]        │
└─────────────────────────────────────────┘
```

**组件规格**:

| 组件 | 功能 | 状态管理 | 数据源 |
|------|------|----------|--------|
| UserInfoWidget | 用户信息 | Riverpod | 本地 |
| AiEntryWidget | AI助手入口 | - | - |
| StatsSection | 统计概览 | Riverpod | SQLite |
| SummaryCardWidget | 概览卡片 | Riverpod | SQLite |
| PieChartWidget | 饼图 | Riverpod | SQLite |
| CategoryRankingWidget | 分类排行 | Riverpod | SQLite |
| ChatMessageListWidget | 对话列表 | Riverpod | 对话历史 |
| ChatInputWidget | 输入框 | 本地State | 用户输入 |
| QuickQueryWidget | 快捷查询 | 本地State | 预设查询 |

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
