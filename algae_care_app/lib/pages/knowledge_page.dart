import 'package:flutter/material.dart';

class KnowledgePage extends StatefulWidget {
  const KnowledgePage({super.key});

  @override
  State<KnowledgePage> createState() => _KnowledgePageState();
}

class _KnowledgePageState extends State<KnowledgePage> {
  // Q&A互動狀態
  bool _quizAnswered = false;
  bool _quizCorrect = false;
  int? _selectedIndex;

  final _quiz = {
    'question': '微藻養殖最重要的環境條件是什麼？',
    'options': ['光照', 'Wi-Fi', '手機型號', '螢幕亮度'],
    'answer': 0,
    'explain': '微藻需要充足光照進行光合作用，才能健康成長。'
  };

  @override
  Widget build(BuildContext context) {
    final knowledgeList = [
      {
        'title': '微藻是什麼？',
        'content': '微藻是一種單細胞水生生物，能進行光合作用，吸收二氧化碳並釋放氧氣，是地球重要的碳吸收者。',
        'icon': Icons.grass
      },
      {
        'title': '微藻養殖步驟',
        'content': '1. 準備乾淨容器與水源\n2. 加入微藻種子與營養液\n3. 提供適當光照與溫度\n4. 定期換水、測pH與溫度\n5. 記錄成長狀態、拍照觀察',
        'icon': Icons.science
      },
      {
        'title': '微藻的環保意義',
        'content': '微藻能大量吸收CO₂，減緩全球暖化。每1公升微藻養殖液一年可吸收約2g二氧化碳。',
        'icon': Icons.eco
      },
      {
        'title': '微藻的應用',
        'content': '微藻可用於健康食品、動物飼料、化妝品、甚至生質燃料。常見DIY如微藻果凍、微藻餅乾。',
        'icon': Icons.restaurant
      },
      {
        'title': '常見問題Q&A',
        'content': 'Q: 水變綠怎麼辦？\nA: 代表微藻生長旺盛，適度換水即可。\n\nQ: 泡泡太多怎麼處理？\nA: 可減少攪拌或換水。\n\nQ: 微藻死掉怎麼救？\nA: 檢查水質、pH、溫度，適度換水並補充營養。',
        'icon': Icons.question_answer
      },
      {
        'title': '挑戰任務',
        'content': '完成「連續記錄7天」、「吸碳達人」、「DIY微藻美食」等成就，解鎖更多徽章！',
        'icon': Icons.emoji_events
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
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Icon(k['icon'], color: Colors.green[800]),
              ),
              title: Text(k['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(k['content']!),
            );
          } else {
            // Q&A互動區塊
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.teal[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.quiz, color: Colors.teal, size: 28),
                          SizedBox(width: 8),
                          Text('知識小測驗', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(_quiz['question']!, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 12),
                      ...List.generate(_quiz['options']!.length, (idx) {
                        final option = _quiz['options']![idx];
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
                              Icon(
                                _quizCorrect ? Icons.emoji_events : Icons.close,
                                color: _quizCorrect ? Colors.amber : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _quizCorrect ? '恭喜解鎖Q&A達人成就！' : '答錯囉，再試一次！',
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
                          child: Text(_quiz['explain']!, style: const TextStyle(color: Colors.teal)),
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