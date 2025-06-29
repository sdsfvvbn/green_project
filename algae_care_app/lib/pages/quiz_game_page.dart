import 'package:flutter/material.dart';
import 'dart:math';

class QuizGamePage extends StatefulWidget {
  const QuizGamePage({super.key});

  @override
  State<QuizGamePage> createState() => _QuizGamePageState();
}

class _QuizGamePageState extends State<QuizGamePage> {
  final List<Map<String, dynamic>> _allQuestions = [
    {
      'question': '哪一種微藻最常見於食用？',
      'options': ['螺旋藻', '綠藻', '矽藻', '紅藻'],
      'answer': 0,
    },
    {
      'question': '微藻養殖有什麼環保效益？',
      'options': ['吸收二氧化碳', '產生塑膠', '增加空氣污染', '消耗水資源'],
      'answer': 0,
    },
    {
      'question': '微藻可用於下列哪一項？',
      'options': ['生質燃料', '手機製造', '金屬冶煉', '汽車輪胎'],
      'answer': 0,
    },
    {
      'question': '微藻含有什麼營養素？',
      'options': ['蛋白質', '塑化劑', '重金屬', '酒精'],
      'answer': 0,
    },
    {
      'question': '微藻可用於哪種產業？',
      'options': ['食品', '建築', '服裝', '汽車'],
      'answer': 0,
    },
    {
      'question': '下列哪一項不是微藻的特性？',
      'options': ['能光合作用', '能吸碳', '能產生氧氣', '能產生塑膠'],
      'answer': 3,
    },
    {
      'question': '微藻最適合的生長環境是？',
      'options': ['有光有水', '乾燥高溫', '無氧環境', '極低溫'],
      'answer': 0,
    },
    {
      'question': '微藻可用於哪種永續應用？',
      'options': ['減碳', '製造垃圾', '增加污染', '消耗能源'],
      'answer': 0,
    },
    {
      'question': '微藻的細胞形狀多為？',
      'options': ['圓形或橢圓形', '方形', '三角形', '星形'],
      'answer': 0,
    },
    {
      'question': '微藻的繁殖方式主要是？',
      'options': ['分裂', '孵化', '孢子', '嫁接'],
      'answer': 0,
    },
  ];
  late List<Map<String, dynamic>> _questions;
  int _current = 0;
  int _score = 0;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _questions = List<Map<String, dynamic>>.from(_allQuestions);
    _questions.shuffle(Random());
  }

  void _answer(int idx) {
    if (_showResult) return;
    setState(() {
      if (idx == _questions[_current]['answer']) {
        _score++;
      }
      if (_current < _questions.length - 1) {
        _current++;
      } else {
        _showResult = true;
        if (_score == _questions.length) {
          // 連動成就系統（此處可呼叫成就解鎖邏輯）
          print('恭喜解鎖知識達人徽章！');
        }
      }
    });
  }

  void _restart() {
    setState(() {
      _current = 0;
      _score = 0;
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('微藻知識問答'), backgroundColor: Colors.green[700]),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _showResult
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber, size: 64),
                    const SizedBox(height: 16),
                    Text('答對 $_score / ${_questions.length} 題', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    if (_score == _questions.length)
                      const Text('🎉 恭喜獲得「知識達人」徽章！', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _restart,
                      child: const Text('再玩一次'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('返回'),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('第 ${_current + 1} 題', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                    const SizedBox(height: 16),
                    Text(_questions[_current]['question'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    ...List.generate(_questions[_current]['options'].length, (idx) {
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[100],
                            foregroundColor: Colors.green[900],
                          ),
                          onPressed: () => _answer(idx),
                          child: Text(_questions[_current]['options'][idx]),
                        ),
                      );
                    }),
                  ],
                ),
        ),
      ),
    );
  }
} 