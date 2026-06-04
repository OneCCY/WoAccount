# 07 - 测试策略文档 (Technical Specification)

> **版本**: v3.0 | **更新日期**: 2026-06-02 | **状态**: 已更新为本地优先方案

---

## ⚠️ 重要说明

本文档为**高层测试策略**，详细的技术实现文档请参考：

| 模块 | 详细文档 | 内容 |
|------|----------|------|
| 测试策略 | [testing-strategy.md](../superpowers/testing/testing-strategy.md) | 测试金字塔、AI准确率测试、Widget测试、E2E测试 |
| 数据安全 | [data-security.md](../superpowers/security/data-security.md) | 数据库加密、安全存储 |
| 性能优化 | [performance-optimization.md](../superpowers/performance/performance-optimization.md) | 启动优化、内存优化 |

---

## 7.1 测试概述

### 7.1.1 测试目标

| 目标 | 指标 | 目标值 |
|------|------|--------|
| 代码覆盖率 | 单元测试覆盖率 | > 70% |
| AI准确率 | 分类准确率 | > 90% |
| 性能指标 | 启动时间 | < 2s |
| 稳定性 | 崩溃率 | < 1% |
| 用户体验 | 关键流程通过率 | 100% |

### 7.1.2 测试金字塔

```
                    ╱╲
                   ╱  ╲        E2E测试 (10%)
                  ╱    ╲       - 关键流程端到端测试
                 ╱──────╲      - 真实设备测试
                ╱        ╲     
               ╱          ╲    集成测试 (30%)
              ╱            ╲   - Widget测试、API测试
             ╱──────────────╲  - 数据库测试
            ╱                ╲ 
           ╱                  ╲ 单元测试 (60%)
          ╱                    ╲- 业务逻辑测试
         ╱──────────────────────╲- AI准确率测试、工具函数测试
```

---

## 7.2 单元测试 (60%)

### 7.2.1 测试范围

| 模块 | 测试内容 | 测试用例数 | 优先级 |
|------|----------|-----------|--------|
| RuleEngine | 关键词匹配 | 50+ | P0 |
| AmountExtractor | 金额提取 | 30+ | P0 |
| AiService | AI解析结果 | 40+ | P0 |
| TransactionValidator | 数据校验 | 20+ | P0 |
| DateUtils | 日期处理 | 15+ | P1 |
| CurrencyUtils | 货币格式化 | 10+ | P1 |
| AnomalyDetector | 异常检测 | 20+ | P1 |

### 7.2.2 测试用例示例

```dart
// test/features/ai/rule_engine_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wo_account/features/ai/domain/services/rule_engine.dart';

void main() {
  group('RuleEngine', () {
    late RuleEngine ruleEngine;
    
    setUp(() {
      ruleEngine = RuleEngine();
    });
    
    group('餐饮分类', () {
      test('应识别"吃"相关关键词', () async {
        final result = await ruleEngine.match('中午吃了碗拉面');
        expect(result, isNotNull);
        expect(result!.category, equals('餐饮'));
        expect(result.confidence, greaterThan(0.8));
      });
      
      test('应识别"饭"相关关键词', () async {
        final result = await ruleEngine.match('晚饭花了50');
        expect(result, isNotNull);
        expect(result!.category, equals('餐饮'));
      });
      
      test('应识别外卖相关', () async {
        final result = await ruleEngine.match('点了个外卖');
        expect(result, isNotNull);
        expect(result!.category, equals('餐饮'));
      });
      
      test('应识别饮品相关', () async {
        final result = await ruleEngine.match('买了杯奶茶');
        expect(result, isNotNull);
        expect(result!.category, equals('餐饮'));
        expect(result!.subcategory, equals('饮料'));
      });
      
      test('应识别零食相关', () async {
        final result = await ruleEngine.match('买了包薯片');
        expect(result, isNotNull);
        expect(result!.category, equals('餐饮'));
        expect(result!.subcategory, equals('零食'));
      });
    });
    
    group('交通分类', () {
      test('应识别打车相关', () async {
        final result = await ruleEngine.match('打车去公司');
        expect(result, isNotNull);
        expect(result!.category, equals('交通'));
        expect(result!.subcategory, equals('打车'));
      });
      
      test('应识别公交地铁', () async {
        final result = await ruleEngine.match('坐地铁回家');
        expect(result, isNotNull);
        expect(result!.category, equals('交通'));
      });
      
      test('应识别加油相关', () async {
        final result = await ruleEngine.match('加油300');
        expect(result, isNotNull);
        expect(result!.category, equals('交通'));
        expect(result!.subcategory, equals('自驾'));
      });
    });
    
    group('购物分类', () {
      test('应识别购物相关', () async {
        final result = await ruleEngine.match('在淘宝买了件衣服');
        expect(result, isNotNull);
        expect(result!.category, equals('购物'));
      });
    });
    
    group('住房分类', () {
      test('应识别房租相关', () async {
        final result = await ruleEngine.match('交房租3500');
        expect(result, isNotNull);
        expect(result!.category, equals('住房'));
        expect(result!.subcategory, equals('房租'));
      });
      
      test('应识别水电费', () async {
        final result = await ruleEngine.match('交电费200');
        expect(result, isNotNull);
        expect(result!.category, equals('住房'));
      });
    });
    
    group('未匹配情况', () {
      test('无法识别时应返回null', () async {
        final result = await ruleEngine.match('今天天气不错');
        expect(result, isNull);
      });
    });
  });
}

// test/features/ai/amount_extractor_test.dart

void main() {
  group('AmountExtractor', () {
    test('应提取整数金额', () {
      expect(AmountExtractor.extract('午饭25'), equals(25.0));
    });
    
    test('应提取小数金额', () {
      expect(AmountExtractor.extract('打车23.5'), equals(23.5));
    });
    
    test('应提取带元的金额', () {
      expect(AmountExtractor.extract('花了100元'), equals(100.0));
    });
    
    test('应提取带块的金额', () {
      expect(AmountExtractor.extract('花了50块'), equals(50.0));
    });
    
    test('应提取带¥符号的金额', () {
      expect(AmountExtractor.extract('消费¥58'), equals(58.0));
    });
    
    test('无金额时应返回null', () {
      expect(AmountExtractor.extract('吃了碗面'), isNull);
    });
    
    test('应提取第一个金额', () {
      expect(AmountExtractor.extract('买了2件共100元'), equals(2.0));
    });
    
    test('应处理大金额', () {
      expect(AmountExtractor.extract('买了台电脑8999'), equals(8999.0));
    });
  });
}
```

### 7.2.3 AI准确率测试

```dart
// test/features/ai/ai_accuracy_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wo_account/features/ai/domain/services/ai_service.dart';

/// AI测试用例
final List<AiTestCase> aiTestCases = [
  // 餐饮类
  AiTestCase(input: '午饭吃了碗拉面25', expectedCategory: '餐饮', expectedAmount: 25.0),
  AiTestCase(input: '晚饭火锅158', expectedCategory: '餐饮', expectedAmount: 158.0),
  AiTestCase(input: '点了个外卖35', expectedCategory: '餐饮', expectedAmount: 35.0),
  AiTestCase(input: '买了杯奶茶18', expectedCategory: '餐饮', expectedAmount: 18.0),
  AiTestCase(input: '早餐包子豆浆8', expectedCategory: '餐饮', expectedAmount: 8.0),
  AiTestCase(input: '下午茶咖啡28', expectedCategory: '餐饮', expectedAmount: 28.0),
  AiTestCase(input: '零食薯片12', expectedCategory: '餐饮', expectedAmount: 12.0),
  
  // 交通类
  AiTestCase(input: '打车去公司23.5', expectedCategory: '交通', expectedAmount: 23.5),
  AiTestCase(input: '地铁4块', expectedCategory: '交通', expectedAmount: 4.0),
  AiTestCase(input: '加油300', expectedCategory: '交通', expectedAmount: 300.0),
  AiTestCase(input: '高铁票155', expectedCategory: '交通', expectedAmount: 155.0),
  AiTestCase(input: '停车费10', expectedCategory: '交通', expectedAmount: 10.0),
  
  // 购物类
  AiTestCase(input: '买了件T恤199', expectedCategory: '购物', expectedAmount: 199.0),
  AiTestCase(input: '超市购物156', expectedCategory: '购物', expectedAmount: 156.0),
  AiTestCase(input: '淘宝买了双鞋359', expectedCategory: '购物', expectedAmount: 359.0),
  
  // 住房类
  AiTestCase(input: '交房租3500', expectedCategory: '住房', expectedAmount: 3500.0),
  AiTestCase(input: '水电费120', expectedCategory: '住房', expectedAmount: 120.0),
  AiTestCase(input: '物业费280', expectedCategory: '住房', expectedAmount: 280.0),
  
  // 娱乐类
  AiTestCase(input: '电影票45', expectedCategory: '娱乐', expectedAmount: 45.0),
  AiTestCase(input: '游戏充值68', expectedCategory: '娱乐', expectedAmount: 68.0),
  AiTestCase(input: 'KTV消费200', expectedCategory: '娱乐', expectedAmount: 200.0),
  
  // 教育类
  AiTestCase(input: '买了本书58', expectedCategory: '教育', expectedAmount: 58.0),
  AiTestCase(input: '课程费用2999', expectedCategory: '教育', expectedAmount: 2999.0),
  
  // 医疗类
  AiTestCase(input: '挂号费50', expectedCategory: '医疗', expectedAmount: 50.0),
  AiTestCase(input: '买药花了89', expectedCategory: '医疗', expectedAmount: 89.0),
  
  // 社交类
  AiTestCase(input: '给妈妈发红包200', expectedCategory: '社交', expectedAmount: 200.0),
  AiTestCase(input: '朋友聚餐AA制88', expectedCategory: '社交', expectedAmount: 88.0),
  AiTestCase(input: '生日礼物150', expectedCategory: '社交', expectedAmount: 150.0),
];

class AiTestCase {
  final String input;
  final String expectedCategory;
  final double expectedAmount;
  
  const AiTestCase({
    required this.input,
    required this.expectedCategory,
    required this.expectedAmount,
  });
}

void main() {
  group('AI分类准确率测试', () {
    late AiService aiService;
    int correctCategory = 0;
    int correctAmount = 0;
    int total = aiTestCases.length;
    
    setUp(() {
      aiService = AiServiceImpl(
        ruleEngine: RuleEngine(),
        llmApi: LlmApiServiceImpl(
          apiKey: 'test-key',
          baseUrl: 'https://test.api.com',
        ),
        categoryRepo: MockCategoryRepository(),
        transactionRepo: MockTransactionRepository(),
      );
    });
    
    test('分类准确率应大于90%', () async {
      for (final testCase in aiTestCases) {
        try {
          final result = await aiService.parseInput(testCase.input);
          
          if (result.category.name == testCase.expectedCategory) {
            correctCategory++;
          }
          
          if (result.amount == testCase.expectedAmount) {
            correctAmount++;
          }
        } catch (e) {
          print('Failed to parse: ${testCase.input}, error: $e');
        }
      }
      
      final categoryAccuracy = correctCategory / total;
      final amountAccuracy = correctAmount / total;
      
      print('分类准确率: ${(categoryAccuracy * 100).toStringAsFixed(1)}%');
      print('金额准确率: ${(amountAccuracy * 100).toStringAsFixed(1)}%');
      
      expect(categoryAccuracy, greaterThan(0.9));
      expect(amountAccuracy, greaterThan(0.95));
    });
  });
}
```

---

## 7.3 集成测试 (30%)

### 7.3.1 Widget测试

```dart
// test/presentation/widgets/transaction_input_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wo_account/features/transaction/presentation/widgets/transaction_input.dart';

void main() {
  group('TransactionInput Widget', () {
    testWidgets('应显示输入框', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TransactionInput(),
            ),
          ),
        ),
      );
      
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('输入消费描述...'), findsOneWidget);
    });
    
    testWidgets('应显示记账按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TransactionInput(),
            ),
          ),
        ),
      );
      
      expect(find.text('记一笔'), findsOneWidget);
    });
    
    testWidgets('输入内容后按钮应可点击', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TransactionInput(),
            ),
          ),
        ),
      );
      
      // 输入内容
      await tester.enterText(find.byType(TextField), '午饭25');
      await tester.pump();
      
      // 点击按钮
      await tester.tap(find.text('记一笔'));
      await tester.pump();
      
      // 验证按钮可点击
      expect(find.text('记一笔'), findsOneWidget);
    });
  });
}
```

### 7.3.2 数据库测试

```dart
// test/data/database/transaction_dao_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wo_account/shared/database/app_database.dart';

void main() {
  late AppDatabase database;
  
  setUp(() {
    database = AppDatabase.inMemory();
  });
  
  tearDown(() async {
    await database.close();
  });
  
  group('TransactionDAO', () {
    test('应能添加交易记录', () async {
      final transaction = await database.transactionDao.addTransaction(
        TransactionsCompanion.insert(
          amount: 25.0,
          description: '午饭拉面',
          categoryId: 1,
          transactionDate: DateTime.now(),
        ),
      );
      
      expect(transaction.id, isPositive);
      expect(transaction.amount, equals(25.0));
      expect(transaction.description, equals('午饭拉面'));
    });
    
    test('应能查询交易列表', () async {
      // 添加测试数据
      await database.transactionDao.addTransaction(
        TransactionsCompanion.insert(
          amount: 25.0,
          description: '午饭拉面',
          categoryId: 1,
          transactionDate: DateTime.now(),
        ),
      );
      
      await database.transactionDao.addTransaction(
        TransactionsCompanion.insert(
          amount: 35.0,
          description: '打车',
          categoryId: 2,
          transactionDate: DateTime.now(),
        ),
      );
      
      // 查询
      final transactions = await database.transactionDao.getTransactions(
        startDate: DateTime.now().startOfDay,
        endDate: DateTime.now().endOfDay,
      );
      
      expect(transactions.length, equals(2));
    });
    
    test('应能按分类筛选', () async {
      // 添加不同分类的数据
      await database.transactionDao.addTransaction(
        TransactionsCompanion.insert(
          amount: 25.0,
          description: '午饭',
          categoryId: 1,
          transactionDate: DateTime.now(),
        ),
      );
      
      await database.transactionDao.addTransaction(
        TransactionsCompanion.insert(
          amount: 35.0,
          description: '打车',
          categoryId: 2,
          transactionDate: DateTime.now(),
        ),
      );
      
      // 筛选分类1
      final transactions = await database.transactionDao.getTransactions(
        startDate: DateTime.now().startOfDay,
        endDate: DateTime.now().endOfDay,
        categoryId: 1,
      );
      
      expect(transactions.length, equals(1));
      expect(transactions.first.description, equals('午饭'));
    });
    
    test('应能删除交易', () async {
      final transaction = await database.transactionDao.addTransaction(
        TransactionsCompanion.insert(
          amount: 25.0,
          description: '午饭拉面',
          categoryId: 1,
          transactionDate: DateTime.now(),
        ),
      );
      
      await database.transactionDao.deleteTransaction(transaction.id);
      
      final found = await database.transactionDao.getTransaction(transaction.id);
      expect(found, isNull);
    });
    
    test('应能更新交易', () async {
      final transaction = await database.transactionDao.addTransaction(
        TransactionsCompanion.insert(
          amount: 25.0,
          description: '午饭拉面',
          categoryId: 1,
          transactionDate: DateTime.now(),
        ),
      );
      
      await database.transactionDao.updateTransaction(
        transaction.copyWith(amount: 30.0),
      );
      
      final updated = await database.transactionDao.getTransaction(transaction.id);
      expect(updated!.amount, equals(30.0));
    });
  });
}
```

---

## 7.4 E2E测试 (10%)

### 7.4.1 测试场景

| 场景 | 测试步骤 | 预期结果 |
|------|----------|----------|
| 完整记账流程 | 输入 → AI解析 → 确认 → 保存 | 账单列表更新 |
| 编辑账单 | 点击账单 → 修改 → 保存 | 数据更新正确 |
| 删除账单 | 左滑 → 删除 → 确认 | 账单从列表消失 |
| 分类筛选 | 点击分类 → 查看列表 | 只显示该分类 |
| 搜索功能 | 输入关键词 → 搜索 | 显示匹配结果 |
| AI查询 | 输入查询 → 查看结果 | 结果正确显示 |

### 7.4.2 E2E测试代码

```dart
// test/e2e/transaction_flow_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:wo_account/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('记账流程 E2E测试', () {
    testWidgets('完整记账流程', (WidgetTester tester) async {
      // 启动App
      app.main();
      await tester.pumpAndSettle();
      
      // 输入记账内容
      final inputFinder = find.byKey(Key('transaction_input'));
      await tester.enterText(inputFinder, '午饭吃了碗拉面25');
      
      // 点击记账按钮
      final buttonFinder = find.byKey(Key('add_transaction_button'));
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle(Duration(seconds: 3));
      
      // 验证AI解析结果卡片显示
      expect(find.byKey(Key('ai_result_card')), findsOneWidget);
      expect(find.text('¥25.00'), findsOneWidget);
      expect(find.text('餐饮'), findsOneWidget);
      
      // 点击确认
      final confirmFinder = find.byKey(Key('confirm_button'));
      await tester.tap(confirmFinder);
      await tester.pumpAndSettle();
      
      // 验证账单列表更新
      expect(find.text('午饭拉面'), findsOneWidget);
      expect(find.text('¥25.00'), findsOneWidget);
    });
    
    testWidgets('AI查询流程', (WidgetTester tester) async {
      // 启动App
      app.main();
      await tester.pumpAndSettle();
      
      // 先添加一笔记录
      final inputFinder = find.byKey(Key('transaction_input'));
      await tester.enterText(inputFinder, '理发38');
      await tester.tap(find.byKey(Key('add_transaction_button')));
      await tester.pumpAndSettle(Duration(seconds: 3));
      await tester.tap(find.byKey(Key('confirm_button')));
      await tester.pumpAndSettle();
      
      // 导航到AI助手页面
      await tester.tap(find.byKey(Key('ai_tab')));
      await tester.pumpAndSettle();
      
      // 输入查询
      final chatInput = find.byKey(Key('chat_input'));
      await tester.enterText(chatInput, '我今天剪过头发吗？');
      await tester.tap(find.byKey(Key('send_button')));
      await tester.pumpAndSettle(Duration(seconds: 3));
      
      // 验证查询结果
      expect(find.textContaining('理发'), findsOneWidget);
      expect(find.textContaining('38'), findsOneWidget);
    });
  });
}
```

---

## 7.5 性能测试

### 7.5.1 性能指标

| 指标 | 目标 | 测试方法 | 阈值 |
|------|------|----------|------|
| 冷启动时间 | < 1.5s | 性能测试 | 2s |
| 热启动时间 | < 0.5s | 性能测试 | 1s |
| AI解析时间 | < 1.5s | 单元测试 | 3s |
| 列表滚动FPS | 60fps | 性能测试 | 55fps |
| 内存占用 | < 100MB | 性能测试 | 150MB |
| 包体积 | < 20MB | 构建 | 30MB |

### 7.5.2 性能测试代码

```dart
// test/performance/benchmark_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:wo_account/shared/database/app_database.dart';

void main() {
  group('性能基准测试', () {
    test('数据库查询性能', () async {
      final database = AppDatabase.inMemory();
      
      // 插入1000条测试数据
      for (int i = 0; i < 1000; i++) {
        await database.transactionDao.addTransaction(
          TransactionsCompanion.insert(
            amount: Random().nextDouble() * 1000,
            description: '测试交易 $i',
            categoryId: Random().nextInt(9) + 1,
            transactionDate: DateTime.now().subtract(
              Duration(days: Random().nextInt(30)),
            ),
          ),
        );
      }
      
      // 测试查询性能
      final stopwatch = Stopwatch()..start();
      
      final transactions = await database.transactionDao.getTransactions(
        startDate: DateTime.now().subtract(Duration(days: 30)),
        endDate: DateTime.now(),
        limit: 50,
      );
      
      stopwatch.stop();
      
      print('查询耗时: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      
      await database.close();
    });
    
    test('AI解析性能', () async {
      final aiService = AiServiceImpl(
        ruleEngine: RuleEngine(),
        llmApi: MockLlmApiService(),
        categoryRepo: MockCategoryRepository(),
        transactionRepo: MockTransactionRepository(),
      );
      
      final stopwatch = Stopwatch()..start();
      
      await aiService.parseInput('午饭吃了碗拉面25');
      
      stopwatch.stop();
      
      print('AI解析耗时: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
    
    test('规则引擎性能', () async {
      final ruleEngine = RuleEngine();
      
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 1000; i++) {
        await ruleEngine.match('午饭吃了碗拉面25');
      }
      
      stopwatch.stop();
      
      print('规则引擎1000次匹配耗时: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });
}
```

---

## 7.6 测试工具

### 7.6.1 依赖配置

```yaml
# pubspec.yaml

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  
  # Mock框架
  mockito: ^5.4.4
  build_runner: ^2.4.8
  
  # 测试工具
  test: ^1.24.9
  
  # 覆盖率
  coverage: ^1.7.2
```

### 7.6.2 Mock生成

```dart
// test/mocks/mocks.dart

import 'package:mockito/annotations.dart';
import 'package:wo_account/features/ai/domain/services/ai_service.dart';
import 'package:wo_account/features/transaction/domain/repositories/transaction_repo.dart';
import 'package:wo_account/features/category/domain/repositories/category_repo.dart';

@GenerateMocks([
  AiService,
  TransactionRepository,
  CategoryRepository,
  LlmApiService,
])
void main() {}
```

---

## 7.7 测试报告

### 7.7.1 报告模板

```
测试报告
========

测试日期: 2025-01-15
测试版本: v1.0.0
测试人员: xxx

一、测试概览
- 总用例数: 150
- 通过: 145
- 失败: 3
- 跳过: 2
- 通过率: 96.7%

二、测试详情
1. 单元测试: 90个，通过88个
   - RuleEngine: 50个，通过49个
   - AmountExtractor: 30个，通过30个
   - AiService: 10个，通过9个

2. 集成测试: 40个，通过38个
   - Widget测试: 20个，通过19个
   - 数据库测试: 20个，通过19个

3. E2E测试: 20个，通过19个
   - 记账流程: 10个，通过10个
   - 查询流程: 10个，通过9个

三、AI准确率测试
- 分类准确率: 92.3% ✓
- 金额准确率: 96.7% ✓

四、性能测试
- 冷启动: 1.2s ✓
- AI解析: 1.5s ✓
- 数据库查询: 45ms ✓
- 列表滚动: 60fps ✓

五、遗留问题
1. [Bug] 某些方言描述解析失败
2. [Bug] 特殊符号金额提取错误

六、结论
测试通过，可进入下一阶段。
```

---

## 7.8 持续集成

### 7.8.1 GitHub Actions配置

```yaml
# .github/workflows/test.yml

name: Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run unit tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```
