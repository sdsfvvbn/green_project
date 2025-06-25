import 'package:flutter/material.dart';
import 'dart:math';

class KnowledgePage extends StatefulWidget {
  const KnowledgePage({super.key});

  @override
  State<KnowledgePage> createState() => _KnowledgePageState();
}

class _KnowledgePageState extends State<KnowledgePage> with SingleTickerProviderStateMixin {
  // Q&A互動狀態
  bool _quizAnswered = false;
  bool _quizCorrect = false;
  int? _selectedIndex;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  final _quizList = [
    {
      'question': '微藻養殖最重要的環境條件是什麼？',
      'options': ['光照', 'Wi-Fi', '手機型號', '螢幕亮度'],
      'answer': 0,
      'explain': '微藻需要充足光照進行光合作用，才能健康成長。'
    },
    {
      'question': '哪一項不是微藻的應用？',
      'options': ['健康食品', '生質燃料', '手機殼', '化妝品'],
      'answer': 2,
      'explain': '微藻可做食品、燃料、化妝品，但不會做手機殼。'
    },
    {
      'question': '微藻吸收CO₂的主要過程是？',
      'options': ['光合作用', '呼吸作用', '發酵', '蒸發'],
      'answer': 0,
      'explain': '微藻靠光合作用吸收CO₂並釋放氧氣。'
    },
    {
      'question': '微藻DIY應用不包括？',
      'options': ['果凍', '餅乾', '面膜', '汽車輪胎'],
      'answer': 3,
      'explain': '汽車輪胎不是微藻DIY應用。'
    },
    {
      'question': '微藻對環境的最大貢獻是？',
      'options': ['吸收CO₂', '產生塑膠', '增加噪音', '消耗水資源'],
      'answer': 0,
      'explain': '微藻大量吸收CO₂，減緩暖化。'
    },
  ];
  late Map<String, dynamic> _quiz;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.elasticOut)).animate(_animController);
    _randomQuiz();
  }

  void _randomQuiz() {
    final r = Random().nextInt(_quizList.length);
    _quiz = _quizList[r];
    _quizAnswered = false;
    _quizCorrect = false;
    _selectedIndex = null;
    setState(() {});
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final knowledgeList = [
      {
        'title': '微藻是什麼？',
        'content': '微藻是一種單細胞水生生物，能進行光合作用，吸收二氧化碳並釋放氧氣，是地球重要的碳吸收者。',
        'icon': Icons.grass,
        'color': Colors.green[100]
      },
      {
        'title': '微藻的健康益處',
        'content': '微藻富含蛋白質、維生素、礦物質，是超級食物，有助免疫力與新陳代謝。',
        'icon': Icons.health_and_safety,
        'color': Colors.teal[50]
      },
      {
        'title': '微藻養殖步驟',
        'content': '1. 準備乾淨容器與水源\n2. 加入微藻種子與營養液\n3. 提供適當光照與溫度\n4. 定期換水、測pH與溫度\n5. 記錄成長狀態、拍照觀察',
        'icon': Icons.science,
        'color': Colors.blue[50]
      },
      {
        'title': '微藻的環保意義',
        'content': '微藻能大量吸收CO₂，減緩全球暖化。每1公升微藻養殖液一年可吸收約2g二氧化碳。',
        'icon': Icons.eco,
        'color': Colors.teal[100]
      },
      {
        'title': '微藻的應用',
        'content': '微藻可用於健康食品、動物飼料、化妝品、甚至生質燃料。常見DIY如微藻果凍、微藻餅乾。',
        'icon': Icons.restaurant,
        'color': Colors.orange[50]
      },
      {
        'title': '趣味冷知識',
        'content': '有些微藻能發光（夜光藻）、有些可做成天然顏料，甚至能當生物燃料！',
        'icon': Icons.lightbulb,
        'color': Colors.yellow[50]
      },
      {
        'title': '常見問題Q&A',
        'content': 'Q: 水變綠怎麼辦？\nA: 代表微藻生長旺盛，適度換水即可。\n\nQ: 泡泡太多怎麼處理？\nA: 可減少攪拌或換水。\n\nQ: 微藻死掉怎麼救？\nA: 檢查水質、pH、溫度，適度換水並補充營養。',
        'icon': Icons.question_answer,
        'color': Colors.purple[50]
      },
      {
        'title': '挑戰任務',
        'content': '完成「連續記錄7天」、「吸碳達人」、「DIY微藻美食」等成就，解鎖更多徽章！',
        'icon': Icons.emoji_events,
        'color': Colors.pink[50]
      },
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('微藻知識小學堂'), backgroundColor: Colors.green[700]),
      body: ListView.separated(
        itemCount: knowledgeList.length + 1,
        separatorBuilder: (context, i) => const Divider(),
        itemBuilder: (context, i) {
          if (i < knowledgeList.length) {
            final k = knowledgeList[i];
            return Card(
              color: k['color'] as Color?,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: Icon(k['icon'] as IconData, color: Colors.green[800], size: 32),
                title: Text(k['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(k['content'] as String),
              ),
            );
          } else {
            // Q&A互動區塊
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.teal[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.quiz, color: Colors.teal, size: 28),
                          SizedBox(width: 8),
                          Text('每日一題', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(_quiz['question'], style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 12),
                      ...List.generate(_quiz['options'].length, (idx) {
                        final option = _quiz['options'][idx];
                        final isSelected = _selectedIndex == idx;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected ? Colors.teal[300] : Colors.teal[100],
                              foregroundColor: Colors.black,
                            ),
                            onPressed: _quizAnswered
                                ? null
                                : () {
                                    setState(() {
                                      _selectedIndex = idx;
                                      _quizAnswered = true;
                                      _quizCorrect = idx == _quiz['answer'];
                                      if (_quizCorrect) _animController.forward(from: 0);
                                    });
                                  },
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(option),
                            ),
                          ),
                        );
                      }),
                      if (_quizAnswered)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Row(
                            children: [
                              _quizCorrect
                                  ? ScaleTransition(
                                      scale: _scaleAnim,
                                      child: const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                                    )
                                  : const Icon(Icons.close, color: Colors.red, size: 32),
                              const SizedBox(width: 8),
                              Text(
                                _quizCorrect ? '恭喜答對，解鎖Q&A達人成就！' : '答錯囉，再試一次！',
                                style: TextStyle(
                                  color: _quizCorrect ? Colors.teal[800] : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_quizAnswered)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(_quiz['explain'], style: const TextStyle(color: Colors.teal)),
                        ),
                      if (_quizAnswered && !_quizCorrect)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _quizAnswered = false;
                                _selectedIndex = null;
                              });
                            },
                            child: const Text('再試一次'),
                          ),
                        ),
                      if (_quizAnswered && _quizCorrect)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('換一題'),
                            onPressed: () {
                              _randomQuiz();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
} 