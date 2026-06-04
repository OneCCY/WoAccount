import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:wo_account/main.dart';
import 'package:wo_account/config/database/app_database.dart';
import 'package:wo_account/config/di/providers.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // 使用内存数据库避免真实 I/O
    final testDb = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWith((ref) {
            ref.onDispose(() => testDb.close());
            return testDb;
          }),
        ],
        child: const WoAccountApp(),
      ),
    );

    // 等待异步加载完成
    await tester.pumpAndSettle();

    // 验证底部导航栏存在
    expect(find.text('账单'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    // 验证首页 AI 输入框存在
    expect(find.text('记一笔账... 如：午饭拉面25'), findsOneWidget);

    // 验证今日账单标题
    expect(find.text('今日账单'), findsOneWidget);
  });
}
