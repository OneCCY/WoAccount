# WoAccount 测试策略

> **版本**: v1.0 | **创建日期**: 2026-06-04

---

## 1. 测试金字塔

```
         ╱╲
        ╱  ╲        E2E测试 (10%)
       ╱    ╲       - 关键流程端到端测试
      ╱──────╲
     ╱        ╲     集成测试 (30%)
    ╱          ╲    - API测试、数据库测试
   ╱────────────╲
  ╱              ╲  单元测试 (60%)
 ╱                ╲ - AI准确率测试、业务逻辑测试
╱──────────────────╲
```

---

## 2. 单元测试

### 2.1 AI准确率测试（核心）

```dart
// test/ai/transaction_parse_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:woaccount/core/ai/rule_engine.dart';

void main() {
  group('RuleEngine 记账解析测试', () {
    test('餐饮类 - 午饭拉面', () {
      final result = RuleEngine.parse('午饭拉面25');
      expect(result, isNotNull);
      expect(result!.amount, 25);
      expect(result.category, '餐饮');
      expect(result.confidence, greaterThan(0.7));
    });
    
    test('交通类 - 打车', () {
      final result = RuleEngine.parse('打车去公司28');
      expect(result, isNotNull);
      expect(result!.amount, 28);
      expect(result.category, '交通');
    });
    
    test('住房类 - 房租', () {
      final result = RuleEngine.parse('交房租3500');
      expect(result, isNotNull);
      expect(result!.amount, 3500);
      expect(result.category, '住房');
    });
    
    test('收入类 - 工资', () {
      final result = RuleEngine.parse('发工资12000');
      expect(result, isNotNull);
      expect(result!.amount, 12000);
      expect(result.type, 'income');
      expect(result.category, '工资');
    });
    
    test('无法识别', () {
      final result = RuleEngine.parse('今天天气真好');
      expect(result, isNull);
    });
  });
}
```

### 2.2 LLM解析测试

```dart
// test/ai/llm_parse_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('LLM记账解析测试', () {
    late MockLlmRepository mockRepo;
    late ParseTransactionUseCase useCase;
    
    setUp(() {
      mockRepo = MockLlmRepository();
      useCase = ParseTransactionUseCase(mockRepo);
    });
    
    test('正常解析', () async {
      when(mockRepo.parseTransaction('午饭拉面25')).thenAnswer(
        (_) async => TransactionParseResult(
          amount: 25,
          category: '餐饮',
          subcategory: '午餐',
          description: '午饭拉面',
          confidence: 0.95,
        ),
      );
      
      final result = await useCase.execute('午饭拉面25');
      expect(result.amount, 25);
      expect(result.category, '餐饮');
    });
    
    test('网络错误降级到规则引擎', () async {
      when(mockRepo.parseTransaction(any)).thenThrow(
        LlmException('网络连接失败'),
      );
      
      final result = await useCase.execute('午饭拉面25');
      // 降级到规则引擎
      expect(result, isNotNull);
      expect(result.confidence, lessThan(0.9));
    });
  });
}
```

### 2.3 Repository测试

```dart
// test/data/transaction_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

void main() {
  late AppDatabase database;
  late TransactionRepositoryImpl repository;
  
  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    repository = TransactionRepositoryImpl(database);
  });
  
  tearDown(() async {
    await database.close();
  });
  
  group('TransactionRepository', () {
    test('插入交易记录', () async {
      final id = await repository.insert(TransactionsCompanion.insert(
        amount: 25,
        categoryId: 1,
        transactionDate: DateTime.now(),
        type: 'expense',
      ));
      
      expect(id, greaterThan(0));
    });
    
    test('获取今日交易', () async {
      // 插入测试数据
      await repository.insert(TransactionsCompanion.insert(
        amount: 25,
        categoryId: 1,
        transactionDate: DateTime.now(),
        type: 'expense',
      ));
      
      final transactions = await repository.getToday();
      expect(transactions.length, 1);
      expect(transactions.first.amount, 25);
    });
    
    test('软删除', () async {
      final id = await repository.insert(TransactionsCompanion.insert(
        amount: 25,
        categoryId: 1,
        transactionDate: DateTime.now(),
        type: 'expense',
      ));
      
      await repository.delete(id);
      final transaction = await repository.getById(id);
      expect(transaction, isNull);
    });
  });
}
```

---

## 3. 集成测试

### 3.1 数据库集成测试

```dart
// integration_test/database_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('数据库集成测试', () {
    testWidgets('完整CRUD流程', (tester) async {
      // 1. 插入分类
      // 2. 插入交易记录
      // 3. 查询交易记录
      // 4. 更新交易记录
      // 5. 删除交易记录
      // 6. 验证数据一致性
    });
    
    testWidgets('级联删除', (tester) async {
      // 1. 插入账本
      // 2. 插入关联的交易记录
      // 3. 删除账本
      // 4. 验证交易记录也被删除
    });
  });
}
```

### 3.2 LLM API集成测试

```dart
// integration_test/llm_api_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('LLM API集成测试', () {
    testWidgets('通义千问连接测试', (tester) async {
      // 使用真实API Key测试
      final config = LlmConfig(
        providerId: 'qwen',
        apiKey: const String.fromEnvironment('QWEN_API_KEY'),
        baseUrl: 'https://dashscope.aliyuncs.com/api/v1',
        model: 'qwen-turbo',
      );
      
      final repo = LlmRepositoryImpl(Dio(), MockSettingsRepo());
      await repo.updateConfig(config);
      
      final result = await repo.parseTransaction('午饭拉面25');
      expect(result.amount, 25);
      expect(result.category, '餐饮');
    });
    
    testWidgets('DeepSeek连接测试', (tester) async {
      // 类似测试
    });
  });
}
```

---

## 4. Widget测试

### 4.1 页面Widget测试

```dart
// test/presentation/transaction_list_page_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('TransactionListPage', () {
    testWidgets('显示交易列表', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionProvider.overrideWith(
              (ref) => MockTransactionNotifier([
                Transaction(amount: 25, category: '餐饮'),
                Transaction(amount: 28, category: '交通'),
              ]),
            ),
          ],
          child: MaterialApp(
            home: TransactionListPage(),
          ),
        ),
      );
      
      expect(find.text('¥25.00'), findsOneWidget);
      expect(find.text('¥28.00'), findsOneWidget);
    });
    
    testWidgets('空状态显示', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionProvider.overrideWith(
              (ref) => MockTransactionNotifier([]),
            ),
          ],
          child: MaterialApp(
            home: TransactionListPage(),
          ),
        ),
      );
      
      expect(find.text('暂无交易记录'), findsOneWidget);
    });
  });
}
```

### 4.2 组件Widget测试

```dart
// test/widgets/primary_button_test.dart

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('显示文本', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PrimaryButton(text: '确认', onPressed: () {}),
        ),
      );
      
      expect(find.text('确认'), findsOneWidget);
    });
    
    testWidgets('点击触发回调', (tester) async {
      bool clicked = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: PrimaryButton(
            text: '确认',
            onPressed: () => clicked = true,
          ),
        ),
      );
      
      await tester.tap(find.text('确认'));
      expect(clicked, true);
    });
    
    testWidgets('加载状态显示', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PrimaryButton(
            text: '确认',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

---

## 5. E2E测试

### 5.1 记账流程E2E测试

```dart
// e2e_test/transaction_flow_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('记账流程E2E测试', () {
    testWidgets('完整记账流程', (tester) async {
      await tester.pumpWidget(MyApp());
      
      // 1. 点击手动记账按钮
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // 2. 选择分类
      await tester.tap(find.text('餐饮'));
      await tester.pumpAndSettle();
      
      // 3. 输入金额
      await tester.tap(find.text('1'));
      await tester.tap(find.text('0'));
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();
      
      // 4. 点击完成
      await tester.tap(find.text('完成'));
      await tester.pumpAndSettle();
      
      // 5. 验证交易记录
      expect(find.text('¥100.00'), findsOneWidget);
    });
    
    testWidgets('AI记账流程', (tester) async {
      await tester.pumpWidget(MyApp());
      
      // 1. 输入描述
      await tester.enterText(
        find.byType(TextField),
        '午饭拉面25',
      );
      await tester.pumpAndSettle();
      
      // 2. 等待AI解析
      await tester.pump(Duration(seconds: 2));
      
      // 3. 确认记账
      await tester.tap(find.text('确认记账'));
      await tester.pumpAndSettle();
      
      // 4. 验证
      expect(find.text('¥25.00'), findsOneWidget);
    });
  });
}
```

---

## 6. 测试覆盖率

### 6.1 覆盖率目标

| 模块 | 目标覆盖率 | 说明 |
|------|------------|------|
| AI规则引擎 | 90%+ | 核心功能 |
| Repository层 | 80%+ | 数据访问 |
| UseCase层 | 80%+ | 业务逻辑 |
| Widget层 | 60%+ | UI组件 |
| 整体 | 70%+ | - |

### 6.2 生成覆盖率报告

```bash
# 运行测试并生成覆盖率
flutter test --coverage

# 生成HTML报告
genhtml coverage/lcov.info -o coverage/html

# 打开报告
open coverage/html/index.html
```

---

## 7. 测试数据管理

### 7.1 测试数据工厂

```dart
// test/helpers/test_data_factory.dart

class TestDataFactory {
  static Transaction createTransaction({
    double amount = 25,
    String category = '餐饮',
    String type = 'expense',
  }) {
    return Transaction(
      id: 1,
      amount: amount,
      category: category,
      type: type,
      transactionDate: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }
  
  static List<Transaction> createTransactionList(int count) {
    return List.generate(count, (index) => createTransaction(
      amount: (index + 1) * 10,
    ));
  }
}
```

### 7.2 Mock对象

```dart
// test/mocks/mock_repositories.dart

class MockTransactionRepository extends Mock implements TransactionRepository {}
class MockLlmRepository extends Mock implements LlmRepository {}
class MockNetworkInfo extends Mock implements NetworkInfo {}
```

---

## 8. 持续集成

### 8.1 GitHub Actions配置

```yaml
# .github/workflows/test.yml

name: Tests

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
          channel: 'stable'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Analyze code
        run: flutter analyze
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

---

## 9. 测试清单

### 9.1 功能测试

- [ ] 自然语言记账解析
- [ ] 规则引擎解析
- [ ] 本地OCR识别
- [ ] LLM API调用
- [ ] 离线降级
- [ ] 交易CRUD
- [ ] 分类管理
- [ ] 预算管理
- [ ] 统计图表

### 9.2 异常测试

- [ ] 网络断开
- [ ] API Key无效
- [ ] 请求超时
- [ ] 数据库错误
- [ ] 输入格式错误

### 9.3 性能测试

- [ ] 大数据量列表滚动
- [ ] 数据库查询性能
- [ ] AI解析响应时间
- [ ] 内存泄漏检测
