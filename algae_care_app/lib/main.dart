import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'pages/home_page.dart';
import 'pages/log_list_page.dart';
import 'pages/algae_profile_list_page.dart';
// import 'services/notification_service.dart';
import 'package:provider/provider.dart';

import 'font_size_notifier.dart';
import 'l10n/app_localizations.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  
  // 桌面平台才初始化 FFI
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // 初始化通知服務
  // await NotificationService.instance.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => ThemeNotifier()), // 移除深色模式
        ChangeNotifierProvider(create: (_) => FontSizeNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FontSizeNotifier>(
      builder: (context, fontSizeNotifier, child) {
        return MaterialApp(
          title: '微藻照護APP',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'NotoSansTC',
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green, primary: Colors.green),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 4,
              centerTitle: true,
              titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            cardTheme: CardThemeData(
              color: Colors.white, // 淺色模式卡片應該是白色
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                elevation: 2,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green, width: 2), borderRadius: BorderRadius.circular(12)),
              labelStyle: const TextStyle(color: Colors.green),
            ),
            snackBarTheme: const SnackBarThemeData(
              backgroundColor: Colors.green,
              contentTextStyle: TextStyle(color: Colors.white, fontSize: 16),
              behavior: SnackBarBehavior.floating,
            ),
            dividerTheme: const DividerThemeData(
              color: Colors.green,
              thickness: 1,
            ),
            iconTheme: const IconThemeData(color: Colors.green, size: 24),
            useMaterial3: true,
          ),
          supportedLocales: const [Locale('zh')],
          localizationsDelegates: [
            const AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: fontSizeNotifier.scale,
              ),
              child: child!,
            );
          },
          home: const HomePage(),
          routes: {
            '/logList': (context) => const LogListPage(),
            // 其他頁面可依需求補上
          },
        );
      },
    );
  }
}