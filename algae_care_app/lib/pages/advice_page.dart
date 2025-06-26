import 'package:flutter/material.dart';

class AdvicePage extends StatelessWidget {
  const AdvicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI建議/成長曲線'), backgroundColor: Colors.orange[700]),
      body: const Center(
        child: Text('這裡是AI建議/成長曲線頁（B組功能）', style: TextStyle(fontSize: 20)),
      ),
    );
  }
} 