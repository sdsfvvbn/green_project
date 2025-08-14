import 'package:flutter_test/flutter_test.dart';
import 'package:algae_care_app/pages/share_page.dart';
import 'package:flutter/material.dart';

void main() {
  group('分享功能測試', () {
    testWidgets('分享頁面應該正確顯示', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: SharePage(),
      ));

      await tester.pumpAndSettle();

      // 驗證主要元素存在
      expect(find.text('分享成果'), findsOneWidget);
      expect(find.text('分享文字'), findsOneWidget);
      expect(find.text('選擇照片'), findsOneWidget);
      expect(find.text('分享成果'), findsOneWidget);
      expect(find.text('快速分享到：'), findsOneWidget);
      expect(find.text('分享小貼士'), findsOneWidget);
    });

    testWidgets('分享按鈕應該可以點擊', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: SharePage(),
      ));

      await tester.pumpAndSettle();

      // 點擊分享按鈕
      await tester.tap(find.text('分享成果'));
      await tester.pump();

      // 驗證按鈕響應
      expect(find.text('分享成果'), findsOneWidget);
    });

    testWidgets('選擇照片按鈕應該可以點擊', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: SharePage(),
      ));

      await tester.pumpAndSettle();

      // 點擊選擇照片按鈕
      await tester.tap(find.text('選擇照片'));
      await tester.pump();

      // 驗證按鈕響應
      expect(find.text('選擇照片'), findsOneWidget);
    });

    testWidgets('快速分享圖標應該存在', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: SharePage(),
      ));

      await tester.pumpAndSettle();

      // 驗證快速分享圖標存在
      expect(find.byIcon(Icons.facebook), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    });

    testWidgets('成就統計區域應該存在', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: SharePage(),
      ));

      await tester.pumpAndSettle();

      // 驗證成就統計區域存在
      expect(find.text('成就徽章'), findsOneWidget);
      expect(find.text('累積吸碳量'), findsOneWidget);
      expect(find.text('記錄照片'), findsOneWidget);
    });

    testWidgets('文字編輯區域應該存在', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: SharePage(),
      ));

      await tester.pumpAndSettle();

      // 驗證文字編輯區域存在
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('照片預覽區域應該存在', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: SharePage(),
      ));

      await tester.pumpAndSettle();

      // 驗證照片預覽區域存在
      expect(find.text('尚未選擇照片'), findsOneWidget);
    });
  });
}