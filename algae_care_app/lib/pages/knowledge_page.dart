import 'package:flutter/material.dart';
import 'dart:math';
import 'quiz_game_page.dart';

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

  final List<Map<String, dynamic>> dailyQuestions = [
    {
      'question': '微藻大量吸收CO₂，減緩暖化。',
    },
    {
      'question': '螺旋藻是最常見的可食用微藻之一。',
    },
    {
      'question': '微藻可用於生產生質燃料與天然色素。',
    },
    {
      'question': '微藻能淨化水質，是天然的水體清道夫。',
    },
    {
      'question': '微藻含有豐富蛋白質與維生素，是超級食物。',
    },
    {
      'question': '微藻養殖有助於減緩全球暖化。',
    },
  ];
  late String _todayQuestion;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.elasticOut)).animate(_animController);
    _randomQuiz();
    dailyQuestions.shuffle();
    _todayQuestion = dailyQuestions.first['question']!;
  }

  void _randomQuiz() {
    final r = Random().nextInt(_quizList.length);
    _quiz = _quizList[r];
    _quizAnswered = false;
    _quizCorrect = false;
    _selectedIndex = null;
    setState(() {});
  }

  void _changeDailyQuestion() {
    setState(() {
      dailyQuestions.shuffle();
      _todayQuestion = dailyQuestions.first['question']!;
    });
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
        'content': '微藻是一種單細胞水生生物，能進行光合作用，吸收二氧化碳並釋放氧氣，是地球重要的碳吸收者。微藻種類繁多，能適應淡水、海水甚至極端環境。',
        'icon': Icons.grass,
        'color': Colors.green[100]
      },
      {
        'title': '微藻的健康益處',
        'content': '微藻富含蛋白質、維生素B群、礦物質、葉綠素與Omega-3脂肪酸，是超級食物，有助免疫力、抗氧化、促進新陳代謝。螺旋藻、小球藻等常見微藻已被廣泛應用於保健食品。',
        'icon': Icons.health_and_safety,
        'color': Colors.teal[50]
      },
      {
        'title': '微藻的環保意義',
        'content': '微藻能大量吸收CO₂，減緩全球暖化。每1公升微藻養殖液一年可吸收約2g二氧化碳。微藻還能淨化廢水，吸收水中多餘的氮、磷，是天然的水體清道夫。',
        'icon': Icons.eco,
        'color': Colors.teal[100]
      },
      {
        'title': '微藻的應用',
        'content': '微藻可用於健康食品、動物飼料、化妝品、甚至生質燃料。常見DIY如微藻果凍、微藻餅乾。微藻萃取物也常被用於高級化妝品與保養品。',
        'icon': Icons.restaurant,
        'color': Colors.orange[50]
      },
      {
        'title': '微藻產業新趨勢',
        'content': '微藻被視為未來綠色產業新星，可用於生產生質柴油、環保塑膠、天然色素。微藻的高生長速率與碳吸收能力，讓其成為永續發展的重要角色。',
        'icon': Icons.trending_up,
        'color': Colors.lightGreen[50]
      },
      {
        'title': '微藻與健康生活',
        'content': '多吃微藻製品（如螺旋藻粉、小球藻錠）有助補充營養、促進腸道健康。微藻中的葉綠素有助於身體排毒，Omega-3脂肪酸則有益心血管。',
        'icon': Icons.favorite,
        'color': Colors.pink[50]
      },
      {
        'title': '微藻養殖步驟',
        'content': '1. 準備乾淨容器與水源\n2. 加入微藻種子與營養液\n3. 提供適當光照與溫度\n4. 定期換水、測pH與溫度\n5. 記錄成長狀態、拍照觀察。',
        'icon': Icons.science,
        'color': Colors.blue[50]
      },
      {
        'title': '趣味冷知識',
        'content': '有些微藻能發光（夜光藻），在夜晚海邊會出現「藍眼淚」奇景。微藻的顏色多變，從綠色、紅色到金黃色都有。微藻的祖先可能是地球最早的多細胞生物。',
        'icon': Icons.lightbulb,
        'color': Colors.yellow[50]
      },
      {
        'title': '微藻與地球氧氣',
        'content': '微藻是地球氧氣的重要來源，貢獻全球約50%的氧氣。沒有微藻，地球生態將大受影響。',
        'icon': Icons.public,
        'color': Colors.cyan[50]
      },
      {
        'title': '微藻與永續發展',
        'content': '微藻可用於碳捕捉、廢水處理、資源循環，是實現永續發展目標（SDGs）的重要工具。',
        'icon': Icons.recycling,
        'color': Colors.green[50]
      },
      {
        'title': '微藻的營養成分',
        'content': '螺旋藻蛋白質含量高達60-70%，小球藻富含葉綠素與維生素B12。微藻還含有多種礦物質與抗氧化物質。',
        'icon': Icons.emoji_food_beverage,
        'color': Colors.lime[50]
      },
      {
        'title': '微藻的趣味應用',
        'content': '微藻可做成冰淇淋、麵包、飲料，甚至用於3D列印食品。微藻顏料可用於天然染色。',
        'icon': Icons.icecream,
        'color': Colors.indigo[50]
      },
      {
        'title': '常見問題Q&A',
        'content': 'Q: 水變綠怎麼辦？\nA: 代表微藻生長旺盛，適度換水即可。\n\nQ: 泡泡太多怎麼處理？\nA: 可減少攪拌或換水。\n\nQ: 微藻死掉怎麼救？\nA: 檢查水質、pH、溫度，適度換水並補充營養。',
        'icon': Icons.question_answer,
        'color': Colors.purple[50]
      },
      {
        'title': '微藻與氣候變遷',
        'content': '微藻能吸收大量CO₂，是對抗氣候變遷的天然幫手。推廣微藻養殖有助於減緩全球暖化。',
        'icon': Icons.cloud,
        'color': Colors.blueGrey[50]
      },
      {
        'title': '環保生活小知識',
        'content': '減少一次性塑膠、節能減碳、多吃植物性食物、步行或騎腳踏車上下班，都是簡單的環保行動。',
        'icon': Icons.directions_bike,
        'color': Colors.lightBlue[50]
      },
      {
        'title': '挑戰任務',
        'content': '完成「連續記錄7天」、「吸碳達人」、「DIY微藻美食」等成就，解鎖更多徽章！',
        'icon': Icons.emoji_events,
        'color': Colors.pink[50]
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '微藻知識小學堂',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 6,
        centerTitle: true,
        leading: Icon(Icons.school, size: 28),
      ),
      body: Column(
        children: [
          Card(
            color: Colors.teal[50],
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.teal[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_todayQuestion, style: const TextStyle(fontSize: 16, color: Colors.teal)),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.green),
                    onPressed: _changeDailyQuestion,
                    tooltip: '換一題',
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: knowledgeList.length,
              separatorBuilder: (context, i) => const Divider(),
              itemBuilder: (context, i) {
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
              },
            ),
          ),
        ],
      ),
    );
  }
} 