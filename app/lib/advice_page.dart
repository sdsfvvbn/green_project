import 'package:flutter/material.dart';
import 'advice_service.dart'; // 導入 AdviceService
import 'chart_widget.dart';

class AdvicePage extends StatelessWidget {
  final AdviceService adviceService = AdviceService(); // 創建實例

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AI建議與成長曲線')),
      body: Center(
        child: Text(adviceService.getAdvice()), // 使用 AdviceService 的方法
      ),
    );
  }
}