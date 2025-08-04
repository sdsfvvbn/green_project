import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:algae_care_app/main.dart';
import 'package:algae_care_app/pages/home_page.dart';
import 'package:algae_care_app/pages/log_form_page.dart';

void main() {
  group('主應用程式測試', () {
    testWidgets('應用程式應該正常啟動', (WidgetTester tester) async {
      // 構建應用程式
      await tester.pumpWidget(const MyApp());

      // 等待應用程式完全載入
      await tester.pumpAndSettle();

      // 驗證應用程式已啟動
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });

  group('首頁測試', () {
    testWidgets('首頁應該顯示主要功能按鈕', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: HomePage(),
      ));

      await tester.pumpAndSettle();

      // 驗證主要功能按鈕存在
      expect(find.text('記錄'), findsOneWidget);
      expect(find.text('知識'), findsOneWidget);
      expect(find.text('建議'), findsOneWidget);
    });

    testWidgets('點擊記錄按鈕應該導航到記錄頁面', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: HomePage(),
      ));

      await tester.pumpAndSettle();

      // 點擊記錄按鈕
      await tester.tap(find.text('記錄'));
      await tester.pumpAndSettle();

      // 驗證導航到記錄頁面
      expect(find.byType(LogFormPage), findsOneWidget);
    });
  });

  group('記錄表單測試', () {
    testWidgets('記錄表單應該包含必要欄位', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: LogFormPage(),
      ));

      await tester.pumpAndSettle();

      // 驗證表單欄位存在
      expect(find.text('藻類名稱'), findsOneWidget);
      expect(find.text('物種'), findsOneWidget);
      expect(find.text('日期'), findsOneWidget);
      expect(find.text('筆記'), findsOneWidget);
    });

    testWidgets('應該能夠填寫表單', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: LogFormPage(),
      ));

      await tester.pumpAndSettle();

      // 填寫表單
      await tester.enterText(find.byType(TextFormField).first, '測試藻類');
      await tester.enterText(find.byType(TextFormField).at(1), 'Chlorella');

      // 驗證輸入的內容
      expect(find.text('測試藻類'), findsOneWidget);
      expect(find.text('Chlorella'), findsOneWidget);
    });
  });
}