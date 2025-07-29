import 'package:flutter/material.dart';
import 'dart:math';
import '../services/achievement_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizGamePage extends StatefulWidget {
  const QuizGamePage({super.key});

  @override
  State<QuizGamePage> createState() => _QuizGamePageState();
}

class _QuizGamePageState extends State<QuizGamePage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late final AchievementService _achievementService;

  final List<Map<String, dynamic>> _allQuestions = [
    {
      'question': '微藻的主要營養來源是？',
      'options': ['陽光', '土壤', '空氣', '昆蟲'],
      'answer': 0,
    },
    {
      'question': '微藻最適合的pH值範圍是？',
      'options': ['6.5-7.5', '4.0-5.0', '8.0-9.0', '3.0-4.0'],
      'answer': 0,
    },
    {
      'question': '微藻每天需要的光照時數約為？',
      'options': ['4-6小時', '8-12小時', '2-3小時', '16-18小時'],
      'answer': 1,
    },
    {
      'question': '微藻最適合的溫度範圍是？',
      'options': ['15-20°C', '25-30°C', '35-40°C', '5-10°C'],
      'answer': 1,
    },
    {
      'question': '微藻的繁殖方式主要是？',
      'options': ['分裂', '孵化', '孢子', '嫁接'],
      'answer': 0,
    },
    {
      'question': '螺旋藻屬於哪一類微藻？',
      'options': ['藍綠藻', '紅藻', '褐藻', '綠藻'],
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
      'question': '微藻養殖有什麼環保效益？',
      'options': ['吸收二氧化碳', '產生塑膠', '增加空氣污染', '消耗水資源'],
      'answer': 0,
    },
    {
      'question': '微藻可產生什麼對人體有益的物質？',
      'options': ['維生素', '重金屬', '塑化劑', '酒精'],
      'answer': 0,
    },
    {
      'question': '哪一種微藻常被用於健康食品？',
      'options': ['螺旋藻', '紅藻', '褐藻', '矽藻'],
      'answer': 0,
    },
    {
      'question': '微藻的英文是？',
      'options': ['Algae', 'Fungi', 'Bacteria', 'Virus'],
      'answer': 0,
    },
    {
      'question': '微藻能夠淨化什麼？',
      'options': ['水質', '空氣', '土壤', '金屬'],
      'answer': 0,
    },
    {
      'question': '微藻的光合作用會產生什麼？',
      'options': ['氧氣', '二氧化碳', '甲烷', '氮氣'],
      'answer': 0,
    },
    {
      'question': '微藻可作為哪一種動物的飼料？',
      'options': ['魚類', '貓', '狗', '馬'],
      'answer': 0,
    },
    {
      'question': '微藻養殖時常見的水體顏色變化是？',
      'options': ['綠色', '紅色', '藍色', '黑色'],
      'answer': 0,
    },
    {
      'question': '微藻的細胞壁主要由什麼構成？',
      'options': ['纖維素', '蛋白質', '脂肪', '澱粉'],
      'answer': 0,
    },
    {
      'question': '微藻的繁殖速度通常是？',
      'options': ['很快', '很慢', '不變', '無法繁殖'],
      'answer': 0,
    },
    {
      'question': '微藻可用於哪種新興能源？',
      'options': ['生質能源', '核能', '太陽能', '風能'],
      'answer': 0,
    },
    {
      'question': '微藻的主要生長條件不包括？',
      'options': ['高溫', '光照', '水', '營養鹽'],
      'answer': 0,
    },
    // 新增題目：
    {
      'question': '哪一種微藻常被用於生產Omega-3脂肪酸？',
      'options': ['裂殖壺藻', '螺旋藻', '紅藻', '矽藻'],
      'answer': 0,
    },
    {
      'question': '微藻在水產養殖中常被用來？',
      'options': ['作為餌料', '消毒', '加熱', '降溫'],
      'answer': 0,
    },
    {
      'question': '微藻的光合作用主要吸收哪種氣體？',
      'options': ['二氧化碳', '氧氣', '氮氣', '甲烷'],
      'answer': 0,
    },
    {
      'question': '微藻可用於哪種廢水處理？',
      'options': ['生活污水', '工業廢水', '農業廢水', '以上皆是'],
      'answer': 3,
    },
    {
      'question': '微藻的蛋白質含量約可達？',
      'options': ['50%以上', '10%', '20%', '30%'],
      'answer': 0,
    },
    {
      'question': '哪一種微藻常見於海洋？',
      'options': ['矽藻', '螺旋藻', '綠藻', '紅藻'],
      'answer': 0,
    },
    {
      'question': '微藻可用於生產哪種天然色素？',
      'options': ['葉綠素', '胡蘿蔔素', '藻藍素', '以上皆是'],
      'answer': 3,
    },
    {
      'question': '微藻的生長速率與什麼有關？',
      'options': ['光照', '溫度', '營養鹽', '以上皆是'],
      'answer': 3,
    },
    {
      'question': '微藻可用於哪種新興生物科技？',
      'options': ['生物燃料', '生物塑膠', '生物醫藥', '以上皆是'],
      'answer': 3,
    },
    {
      'question': '微藻的脂肪可用來生產？',
      'options': ['生質柴油', '汽油', '煤油', '天然氣'],
      'answer': 0,
    },
    {
      'question': '微藻的細胞分裂屬於？',
      'options': ['無性生殖', '有性生殖', '孢子生殖', '嫁接'],
      'answer': 0,
    },
    {
      'question': '微藻的生長需要哪些營養鹽？',
      'options': ['氮、磷', '鉀、鈣', '鐵、鋅', '鎂、銅'],
      'answer': 0,
    },
    {
      'question': '微藻可用於哪種健康食品？',
      'options': ['藻油膠囊', '藻粉飲品', '藻片', '以上皆是'],
      'answer': 3,
    },
    {
      'question': '哪一項不是微藻的應用？',
      'options': ['製造塑膠袋', '生產生質燃料', '水質淨化', '健康食品'],
      'answer': 0,
    },
    {
      'question': '微藻的生長過程會釋放什麼？',
      'options': ['氧氣', '二氧化碳', '甲烷', '氨氣'],
      'answer': 0,
    },
    {
      'question': '微藻的生長速率最快可達？',
      'options': ['一天一倍', '一週一倍', '一月一倍', '一年一倍'],
      'answer': 0,
    },
    {
      'question': '微藻的主要生長環境為？',
      'options': ['水中', '土壤', '空氣', '岩石'],
      'answer': 0,
    },
    {
      'question': '微藻的細胞內含有？',
      'options': ['葉綠體', '粒線體', '細胞核', '以上皆是'],
      'answer': 3,
    },
    {
      'question': '微藻的生長會受到什麼影響？',
      'options': ['光照強度', '溫度', '營養鹽濃度', '以上皆是'],
      'answer': 3,
    },
    {
      'question': '微藻的生長可促進什麼？',
      'options': ['碳循環', '水循環', '氮循環', '硫循環'],
      'answer': 0,
    },
    {
      'question': '微藻的生長需要什麼？',
      'options': ['水、光、營養鹽', '土壤、空氣', '沙子、石頭', '金屬、塑膠'],
      'answer': 0,
    },
    {
      'question': '微藻的生長會產生什麼副產品？',
      'options': ['氧氣', '二氧化碳', '甲烷', '氨氣'],
      'answer': 0,
    },
    {
      'question': '微藻的生長速率與什麼有關？',
      'options': ['光照', '溫度', '營養鹽', '以上皆是'],
      'answer': 3,
    },
    {
      'question': '微藻的細胞壁主要由什麼構成？',
      'options': ['纖維素', '蛋白質', '脂肪', '澱粉'],
      'answer': 0,
    },
    {
      'question': '微藻的繁殖方式主要是？',
      'options': ['分裂', '孢子', '嫁接', '有性生殖'],
      'answer': 0,
    },
    {
      'question': '微藻的英文是？',
      'options': ['Algae', 'Fungi', 'Bacteria', 'Virus'],
      'answer': 0,
    },
    {
      'question': '微藻可用於哪種新興能源？',
      'options': ['生質能源', '核能', '太陽能', '風能'],
      'answer': 0,
    },
    {
      'question': '微藻的主要生長條件不包括？',
      'options': ['高溫', '光照', '水', '營養鹽'],
      'answer': 0,
    },
    {
      'question': '微藻的繁殖速度通常是？',
      'options': ['很快', '很慢', '不變', '無法繁殖'],
      'answer': 0,
    },
    {
      'question': '微藻的光合作用會產生什麼？',
      'options': ['氧氣', '二氧化碳', '甲烷', '氮氣'],
      'answer': 0,
    },
    {
      'question': '微藻能夠淨化什麼？',
      'options': ['水質', '空氣', '土壤', '金屬'],
      'answer': 0,
    },
    {
      'question': '微藻可作為哪一種動物的飼料？',
      'options': ['魚類', '貓', '狗', '馬'],
      'answer': 0,
    },
    {
      'question': '微藻養殖時常見的水體顏色變化是？',
      'options': ['綠色', '紅色', '藍色', '黑色'],
      'answer': 0,
    },
    // ...如需更多題目可再補充...
  ];
  late List<Map<String, dynamic>> _questions;
  int _current = 0;
  int _score = 0;
  bool _showResult = false;
  List<int> _userAnswers = [];

  @override
  void initState() {
    super.initState();
    _achievementService = AchievementService.instance;
    _questions = List<Map<String, dynamic>>.from(_allQuestions);
    _questions.shuffle(Random());
    _questions = _questions.take(5).toList();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
    _incrementQuizPlayCount();
  }

  Future<void> _incrementQuizPlayCount() async {
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt('quiz_play_count') ?? 0;
    count++;
    await prefs.setInt('quiz_play_count', count);
    // 檢查成就
    await _achievementService.checkAndUpdateAchievements();
  }

  void _answer(int idx) async {
    if (_showResult) return;
    
    _userAnswers.add(idx);
    setState(() {
      if (idx == _questions[_current]['answer']) {
        _score++;
      }
      if (_current < _questions.length - 1) {
        _current++;
      } else {
        _showResult = true;
      }
    });
    
    // 在setState之後檢查成就
    if (_showResult && _score == _questions.length) {
      // 解鎖成就
      await _achievementService.unlockAchievement('quiz_master');
      print('恭喜解鎖知識達人徽章！');
    }
  }

  void _restart() {
    setState(() {
      _current = 0;
      _score = 0;
      _showResult = false;
      _questions = List<Map<String, dynamic>>.from(_allQuestions);
      _questions.shuffle(Random());
      _questions = _questions.take(5).toList();
      _userAnswers.clear();
    });
    _incrementQuizPlayCount();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '知識挑戰',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 6,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
            Navigator.of(context).pop();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _showResult
              ? SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 64),
                      const SizedBox(height: 16),
                      Text('答對 $_score / ${_questions.length} 題', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      if (_score == _questions.length)
                        const Text('🎉 恭喜獲得「知識達人」徽章！', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      // 顯示每題詳解
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _questions.length,
                        itemBuilder: (context, idx) {
                          final q = _questions[idx];
                          final userAns = _userAnswers.length > idx ? _userAnswers[idx] : null;
                          final correctAns = q['answer'] as int;
                          return Card(
                            color: userAns == correctAns ? Colors.green[50] : Colors.red[50],
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              title: Text('Q${idx + 1}. ${q['question']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('你的答案：${userAns != null ? q['options'][userAns] : '未作答'}', style: TextStyle(color: userAns == correctAns ? Colors.green : Colors.red)),
                                  Text('正確答案：${q['options'][correctAns]}', style: const TextStyle(color: Colors.blue)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _restart,
                        child: const Text('再玩一次'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () async {
                          await _incrementQuizPlayCount();
                          Navigator.pop(context);
                        },
                        child: const Text('返回'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    LinearProgressIndicator(
                      value: (_current + 1) / _questions.length,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '第 ${_current + 1} 題',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _questions[_current]['question'],
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ...List.generate(
                      _questions[_current]['options'].length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () => _answer(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange[50],
                            foregroundColor: Colors.orange[700],
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            _questions[_current]['options'][index],
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
} 