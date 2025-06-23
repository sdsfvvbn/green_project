import 'package:flutter/material.dart';

class LogPage extends StatelessWidget {
  const LogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('日誌紀錄'), backgroundColor: Colors.blue[700]),
      body: const Center(
        child: Text('這裡是日誌紀錄頁（A組功能）', style: TextStyle(fontSize: 20)),
      ),
    );
  }
} 