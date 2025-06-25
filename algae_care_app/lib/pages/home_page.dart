import 'dart:math';
import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/algae_log.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'log_list_page.dart';
import 'advice_page.dart';
import 'achievement_page.dart';
import 'knowledge_page.dart';
import 'share_page.dart';
import 'algae_settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'carbon_chart_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final DatabaseService _databaseService;
  List<AlgaeLog> _logs = [];
  double _algaeVolume = 1.0;
  int _logDays = 1;
  double get _monthCO2 => _algaeVolume * 2 / 12;
  double get _totalCO2 => _algaeVolume * 2 * _logDays / 365;

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

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService.instance;
    _loadLogs();
    _loadAlgaeSettings();
    _loadLogDays();
  }

  Future<void> _loadLogs() async {
    final logs = await _databaseService.getAllLogs();
    setState(() {
      _logs = logs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> facts = [
      '微藻一年可吸收自身重量10倍的二氧化碳。',
      '螺旋藻是最常見的可食用微藻之一。',
      '微藻可用於生產生質燃料與天然色素。',
      '1公升微藻養殖液一年可吸收約2g二氧化碳。',
      '微藻能淨化水質，是天然的水體清道夫。',
      '微藻含有豐富蛋白質與維生素，是超級食物。',
      '微藻養殖有助於減緩全球暖化。',
    ];
    final randomFact = (facts..shuffle()).first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('個人化微藻養殖APP'),
        backgroundColor: Colors.green[700],
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '微藻養殖設定',
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AlgaeSettingsPage()));
              _loadAlgaeSettings();
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
                child: SizedBox(
                  height: 80,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.eco, color: Colors.green[700], size: 64),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.eco, color: Colors.green[700], size: 32),
                  const SizedBox(width: 8),
                  const Text('歡迎來到微藻養殖APP', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('推廣個人化微藻養殖，讓每個人都能輕鬆減碳、愛地球！', style: TextStyle(color: Colors.teal)),
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
                          Text('${_monthCO2.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('累積吸碳量', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          Text('${_totalCO2.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.water_drop, color: Colors.white),
                  label: const Text('編輯微藻養殖設定', style: TextStyle(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                    minimumSize: const Size(220, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => const AlgaeSettingsPage()));
                    _loadAlgaeSettings();
                  },
                ),
              ),
              // 吸碳量折線圖
              (_logs.isEmpty && _logs != null)
                ? const Center(child: Text('尚無日誌資料，無法顯示吸碳量圖表'))
                : (_logs.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : CarbonChartWidget(logs: _logs, algaeVolume: _algaeVolume)),
              const SizedBox(height: 32),
              _buildEntryCard(
                context,
                icon: Icons.edit_note,
                title: '日誌紀錄',
                desc: '每日養殖狀態、照片上傳',
                color: Colors.blue[100],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LogListPage())),
              ),
              const SizedBox(height: 16),
              _buildEntryCard(
                context,
                icon: Icons.auto_awesome,
                title: 'AI建議/成長曲線',
                desc: '個人化建議、成長數據圖表',
                color: Colors.orange[100],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdvicePage())),
              ),
              const SizedBox(height: 16),
              _buildEntryCard(
                context,
                icon: Icons.emoji_events,
                title: '成就徽章',
                desc: '解鎖微藻主題成就',
                color: Colors.purple[100],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AchievementPage())),
              ),
              const SizedBox(height: 16),
              _buildEntryCard(
                context,
                icon: Icons.menu_book,
                title: '知識小學堂',
                desc: '學習微藻知識、每日一題',
                color: Colors.orange[100],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KnowledgePage())),
              ),
              const SizedBox(height: 16),
              _buildEntryCard(
                context,
                icon: Icons.share,
                title: '社群分享',
                desc: '成果卡片、照片、社群推廣',
                color: Colors.green[100],
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SharePage())),
              ),
              const SizedBox(height: 32),
              const Text('今日任務：檢查水色、調整光照、拍照記錄', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              Card(
                color: Colors.teal[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb, color: Colors.teal[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(randomFact, style: const TextStyle(fontSize: 16, color: Colors.teal)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, {required IconData icon, required String title, required String desc, required Color? color, required VoidCallback onTap}) {
    return Card(
      color: color,
      child: ListTile(
        leading: Icon(icon, size: 36, color: Colors.green[700]),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(desc),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
} 