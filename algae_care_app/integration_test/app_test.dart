import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:algae_care_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('藻類照護應用程式整合測試', () {
    testWidgets('完整的使用者流程測試', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. 驗證應用程式啟動
      expect(find.byType(MaterialApp), findsOneWidget);

      // 2. 測試首頁功能
      expect(find.text('記錄'), findsOneWidget);
      expect(find.text('知識'), findsOneWidget);
      expect(find.text('建議'), findsOneWidget);

      // 3. 測試導航到記錄頁面
      await tester.tap(find.text('記錄'));
      await tester.pumpAndSettle();

      // 4. 測試記錄表單
      expect(find.text('藻類名稱'), findsOneWidget);

      // 填寫表單
      await tester.enterText(find.byType(TextFormField).first, '測試藻類');
      await tester.enterText(find.byType(TextFormField).at(1), 'Chlorella');

      // 5. 測試儲存功能
      await tester.tap(find.text('儲存'));
      await tester.pumpAndSettle();

      // 6. 測試返回首頁
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 7. 測試知識頁面
      await tester.tap(find.text('知識'));
      await tester.pumpAndSettle();
      expect(find.text('藻類知識'), findsOneWidget);

      // 8. 測試建議頁面
      await tester.tap(find.text('建議'));
      await tester.pumpAndSettle();
      expect(find.text('個人化建議'), findsOneWidget);
    });

    testWidgets('資料持久化測試', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. 創建一個記錄
      await tester.tap(find.text('記錄'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '持久化測試藻類');
      await tester.enterText(find.byType(TextFormField).at(1), 'Spirulina');

      await tester.tap(find.text('儲存'));
      await tester.pumpAndSettle();

      // 2. 返回首頁
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 3. 重新啟動應用程式（模擬）
      await tester.pumpWidget(const MaterialApp());
      await tester.pumpAndSettle();

      // 4. 驗證資料是否正確保存
      // 這裡需要根據實際的資料儲存機制來驗證
    });
  });
}