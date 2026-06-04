import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:wo_account/main.dart';
import 'package:wo_account/config/database/app_database.dart';
import 'package:wo_account/config/di/providers.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
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

    await tester.pumpAndSettle();

    // 验证底部导航栏
    expect(find.text('账单'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);

    // 验证首页组件
    expect(find.text('AI 助手'), findsOneWidget);
    expect(find.text('午饭吃了碗拉面25元'), findsOneWidget);
  });
}
