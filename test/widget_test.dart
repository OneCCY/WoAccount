import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wo_account/main.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WoAccountApp(),
      ),
    );

    // 验证底部导航栏存在
    expect(find.text('记账'), findsOneWidget);
    expect(find.text('账单'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
  });
}
