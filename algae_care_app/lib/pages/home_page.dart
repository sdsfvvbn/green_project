import 'dart:math';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/achievement_service.dart';
import '../models/algae_log.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'log_list_page.dart';
import 'advice_page.dart';
import 'achievement_page.dart';
import 'knowledge_page.dart';
import 'share_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'carbon_chart_widget.dart';
import 'share_wall_page.dart';
import 'quiz_game_page.dart';
import 'algae_profile_list_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final DatabaseService _databaseService;
  late final AchievementService _achievementService;
  List<AlgaeLog>? _logs;
  double _algaeVolume = 1.0;
  int _logDays = 1;
  double get _monthCO2 {
    final now = DateTime.now();
    // 如果 _logs 尚未載入，直接回傳 0
    if (_logs == null) return 0.0;
    final thisMonthLogs = _logs!
        .where((log) => log.date.year == now.year && log.date.month == now.month)
        .toList();

    if (thisMonthLogs.isEmpty) return 0.0;

    // 找出本月最早的 log 日期
    thisMonthLogs.sort((a, b) => a.date.compareTo(b.date));
    final firstLogDate = thisMonthLogs.first.date;

    // 算從第一筆 log 到今天的天數（含頭尾）
    final days = now.difference(DateTime(firstLogDate.year, firstLogDate.month, firstLogDate.day)).inDays + 1;

    // 用天數 × 單日吸碳量
    return days * _algaeVolume * 2 / 365;
  }
  double _chartTotalCO2 = 0.0;
  final List<String> facts = [
    '微藻一年可吸收自身重量10倍的二氧化碳。',
    '螺旋藻是最常見的可食用微藻之一。',
    '微藻可用於生產生質燃料與天然色素。',
    '1公升微藻養殖液一年可吸收約2g二氧化碳。',
    '微藻能淨化水質，是天然的水體清道夫。',
    '微藻含有豐富蛋白質與維生素，是超級食物。',
    '微藻養殖有助於減緩全球暖化。',
  ];
  late String _currentFact;

  Future<void> _loadAlgaeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _algaeVolume = prefs.getDouble('algae_volume') ?? 1.0;
    });
    _loadLogDays();
  }

  Future<void> _loadLogDays() async {
    final days = await _databaseService.getLogDays();
    setState(() {
      _logDays = days > 0 ? days : 1;
    });
  }

  Future<void> _checkAchievements() async {
    final newlyUnlocked = await _achievementService.checkAndUpdateAchievements();
    if (newlyUnlocked.isNotEmpty) {
      _showAchievementNotification(newlyUnlocked.first);
    }
  }

  void _showAchievementNotification(String achievementId) {
    final achievement = _achievementService.achievements[achievementId];
    if (achievement != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(
                child: Text('🎉 解鎖成就：${achievement['title']}'),
              ),
            ],
          ),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: '查看',
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AchievementPage()),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _currentFact = (facts..shuffle()).first;
    _databaseService = DatabaseService.instance;
    _achievementService = AchievementService.instance;
    _loadLogs();
    _loadAlgaeSettings();
    _loadLogDays();
    // 延遲檢查成就，確保頁面已載入
    Future.delayed(const Duration(milliseconds: 500), _checkAchievements);
  }

  Future<void> _loadLogs() async {
    final logs = await _databaseService.getAllLogs();
    print('getAllLogs 回傳: ${logs.length} 筆');
    for (var log in logs) {
      print('log: ${log.toMap()}');
    }
    setState(() {
      _logs = logs;
    });
  }

  void _changeFact() {
    setState(() {
      _currentFact = (facts..shuffle()).first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '個人化微藻養殖APP',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 6,
        centerTitle: true,
        leading: Icon(Icons.eco, size: 28),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 26),
            tooltip: '設定',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.eco, color: Colors.green[700], size: 64),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.eco, color: Colors.green[700], size: 32),
                    const SizedBox(width: 8),
                    const Text('歡迎來到微藻養殖APP', 
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1
                      )
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '推廣個人化微藻養殖，讓每個人都能輕鬆減碳、愛地球！', 
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 16,
                    letterSpacing: 0.5
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.cloud, color: Colors.teal[700], size: 36),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('本月吸碳量', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          Text('${_monthCO2.toStringAsFixed(2)} kg', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('累積吸碳量', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          Text('${_chartTotalCO2.toStringAsFixed(2)} kg', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // 吸碳量折線圖
              _logs == null
                ? const Center(child: CircularProgressIndicator())
                : _logs!.isEmpty
                    ? const Center(child: Text('尚無日誌資料，無法顯示吸碳量圖表'))
                    : CarbonChartWidget(
                        logs: _logs!, 
                        onTotalChanged: (val) {
                          if (_chartTotalCO2 != val) {
                            setState(() {
                              _chartTotalCO2 = val;
                            });
                          }
                        },
                      ),
              const SizedBox(height: 32),
              // --- 知識小卡片移到這裡 ---
              Card(
                color: Colors.teal[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.teal[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(_currentFact, style: const TextStyle(fontSize: 16, color: Colors.teal, fontWeight: FontWeight.w500)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.green),
                        tooltip: '換一題',
                        onPressed: _changeFact,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 假設有主要功能卡片或列表
              Card(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: ListTile(
                  leading: Icon(Icons.book, color: Colors.green[700], size: 32),
                  title: Text('日誌紀錄', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text('查看與管理你的微藻養殖日誌'),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.green[700]),
                  onTap: () async {
                    final result = await Navigator.pushNamed(context, '/logList');
                    if (result == true) {
                      _loadLogs();
                    }
                  },
                  hoverColor: Colors.green[50],
                ),
              ),
              // 新增 Profile 管理卡片
              Card(
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: ListTile(
                  leading: Icon(Icons.group_work, color: Colors.green[700], size: 32),
                  title: Text('我的微藻', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text('建立、編輯與管理你的藻類資料'),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.green[700]),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AlgaeProfileListPage()),
                  ),
                  hoverColor: Colors.green[50],
                ),
              ),
              Divider(thickness: 1, color: Colors.green[200], indent: 24, endIndent: 24),
              _buildEntryCard(
                context,
                icon: Icons.auto_awesome,
                title: 'AI成長建議',
                color: Colors.orange[100],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvicePage())),
              ),
              const SizedBox(height: 16),
              _buildEntryCard(
                context,
                icon: Icons.emoji_events,
                title: '成就徽章',
                color: Colors.purple[100],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementPage())),
              ),
              const SizedBox(height: 16),
              _buildEntryCard(
                context,
                icon: Icons.menu_book,
                title: '知識小學堂',
                color: Colors.pink[100],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KnowledgePage())),
              ),
              const SizedBox(height: 16),
              _buildEntryCard(
                context,
                icon: Icons.quiz,
                title: '挑戰小遊戲',
                color: Colors.amber[100],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizGamePage())),
              ),
              const SizedBox(height: 16),
              _buildEntryCard(
                context,
                icon: Icons.share,
                title: '社群分享',
                color: Colors.green[100],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SharePage())),
              ),
              const SizedBox(height: 32),
              const Text('今日任務：檢查水色、調整光照、拍照記錄', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, {required IconData icon, required String title, required Color? color, required VoidCallback onTap}) {
    return Card(
      color: color,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28.0, horizontal: 18.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.green[700]),
              const SizedBox(width: 18),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
} 