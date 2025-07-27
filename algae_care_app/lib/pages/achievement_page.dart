import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../models/algae_log.dart';

class AchievementPage extends StatefulWidget {
  const AchievementPage({super.key});

  @override
  State<AchievementPage> createState() => _AchievementPageState();
}

class _AchievementPageState extends State<AchievementPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  double _algaeVolume = 1.0;
  int _logDays = 1;
  double get _totalCO2 => _algaeVolume * 2 * _logDays / 365;
  List<AlgaeLog> _logs = [];
  bool _shareAchievementUnlocked = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.elasticInOut)).animate(_controller);
    _controller.repeat(reverse: true);
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final db = DatabaseService.instance;
    final logs = await db.getAllLogs();
    final days = await db.getLogDays();
    setState(() {
      _algaeVolume = prefs.getDouble('algae_volume') ?? 1.0;
      _logDays = days > 0 ? days : 1;
      _logs = logs;
      _shareAchievementUnlocked = prefs.getBool('share_achievement_unlocked') ?? false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final achievements = [
      // 養殖基礎
      {'title': '首次養殖啟動', 'desc': '建立第一筆微藻日誌', 'unlocked': true, 'icon': Icons.play_circle, 'type': '基礎', 'detail': '只要你建立第一筆日誌，就能解鎖這個成就！'},
      {'title': '連續養殖7天', 'desc': '連續記錄養殖日誌7天', 'unlocked': true, 'icon': Icons.calendar_month, 'type': '基礎', 'detail': '連續7天都有日誌紀錄，展現你的養殖毅力。'},
      {'title': '首次換水', 'desc': '完成第一次換水操作', 'unlocked': true, 'icon': Icons.water_drop, 'type': '基礎', 'detail': '只要你在APP中記錄一次換水，就能獲得。'},
      {'title': '首次拍照記錄', 'desc': '上傳第一張微藻成長照片', 'unlocked': false, 'icon': Icons.camera_alt, 'type': '基礎', 'detail': '拍下你的微藻成長，留下第一個紀錄。'},
      // 成長與環保
      {'title': '吸碳達人', 'desc': '累積吸碳量達5kg', 'unlocked': _totalCO2 >= 5, 'icon': Icons.eco, 'type': '環保', 'detail': '只要你的吸碳量累積達5kg，就能獲得這個環保成就。'},
      {'title': '碳中和小尖兵', 'desc': '累積吸碳量達10kg', 'unlocked': _totalCO2 >= 10, 'icon': Icons.forest, 'type': '環保', 'detail': '吸碳量達10kg，為地球盡一份心力。'},
      {'title': '碳英雄', 'desc': '累積吸碳量達20kg', 'unlocked': _totalCO2 >= 20, 'icon': Icons.emoji_events, 'type': '環保', 'detail': '吸碳量達20kg，成為碳英雄！'},
      {'title': '減碳連線', 'desc': '連續一週每天都有吸碳紀錄', 'unlocked': false, 'icon': Icons.link, 'type': '環保', 'detail': '一週內每天都有吸碳紀錄，持續減碳不間斷。'},
      {'title': '綠色生活推廣者', 'desc': '首次將成果分享到社群', 'unlocked': _shareAchievementUnlocked, 'icon': Icons.share, 'type': '環保', 'detail': '將你的微藻成果分享到LINE/IG/FB，推廣綠色生活。'},
      // 養殖技術
      {'title': '最佳光照管理', 'desc': '光照時數連續一週達標', 'unlocked': false, 'icon': Icons.wb_sunny, 'type': '技術', 'detail': '一週內每天光照時數都達標，養殖技術一流。'},
      {'title': 'pH守護者', 'desc': 'pH值維持理想一週', 'unlocked': false, 'icon': Icons.science, 'type': '技術', 'detail': '一週內pH值都在理想範圍，微藻健康成長。'},
      {'title': '溫度調控高手', 'desc': '溫度紀錄穩定一週', 'unlocked': false, 'icon': Icons.thermostat, 'type': '技術', 'detail': '一週內溫度紀錄穩定，養殖環境佳。'},
      // 知識
      {'title': '知識小學堂全破', 'desc': '閱讀所有微藻知識內容', 'unlocked': false, 'icon': Icons.menu_book, 'type': '知識', 'detail': '將知識小學堂所有內容都看過一遍，知識滿分。'},
      {'title': 'Q&A達人', 'desc': '正確回答知識小學堂Q&A', 'unlocked': false, 'icon': Icons.question_answer, 'type': '知識', 'detail': '答對知識小學堂的小測驗，成為Q&A達人。'},
      // 創新趣味
      {'title': 'DIY微藻美食', 'desc': '上傳微藻料理照片', 'unlocked': false, 'icon': Icons.restaurant, 'type': '趣味', 'detail': '上傳你用微藻做的料理照片，展現創意。'},
      {'title': '自製養殖設備', 'desc': '上傳自製養殖裝置照片', 'unlocked': false, 'icon': Icons.build, 'type': '趣味', 'detail': '自製養殖設備並上傳照片，動手實作。'},
      {'title': '參加微藻挑戰賽', 'desc': '參與官方/社群舉辦的微藻挑戰活動', 'unlocked': false, 'icon': Icons.emoji_events, 'type': '趣味', 'detail': '參加微藻相關挑戰賽，與大家一起成長。'},
      // 新增主題成就
      {'title': '每日打卡達人', 'desc': '連續每日打卡10天', 'unlocked': false, 'icon': Icons.check_circle, 'type': '基礎', 'detail': '連續10天打卡，培養好習慣。'},
      {'title': '知識挑戰王', 'desc': '答對5題知識小學堂', 'unlocked': false, 'icon': Icons.psychology, 'type': '知識', 'detail': '知識小學堂答對5題，知識力UP!'},
      {'title': '社群分享高手', 'desc': '分享成果至3個平台', 'unlocked': false, 'icon': Icons.public, 'type': '環保', 'detail': '將成果分享到LINE/IG/FB，推廣綠生活。'},
      {'title': '微藻美照達人', 'desc': '上傳5張微藻成長照片', 'unlocked': false, 'icon': Icons.photo_camera, 'type': '趣味', 'detail': '累積上傳5張微藻照片，記錄美好成長。'},
      {'title': 'DIY創意王', 'desc': '完成3項DIY微藻應用', 'unlocked': false, 'icon': Icons.lightbulb, 'type': '趣味', 'detail': 'DIY微藻果凍、餅乾、面膜等，創意無限。'},
    ];

    final typeColors = {
      '基礎': Colors.green[700],
      '環保': Colors.teal[700],
      '技術': Colors.blue[700],
      '知識': Colors.orange[700],
      '趣味': Colors.purple[700],
    };
    final typeNames = ['基礎', '環保', '技術', '知識', '趣味'];
    // 分組
    Map<String, List<Map<String, dynamic>>> grouped = {for (var t in typeNames) t: []};
    for (var a in achievements) {
      grouped[a['type']]!.add(a);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '成就徽章',
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
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            for (var type in typeNames)
              if (grouped[type]!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.emoji_events, color: typeColors[type], size: 24),
                          const SizedBox(width: 8),
                          Text('$type成就', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: typeColors[type])),
                        ],
                      ),
                    ),
                    ...grouped[type]!.map((a) => Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: a['unlocked']
                          ? ScaleTransition(
                              scale: _scaleAnim,
                              child: CircleAvatar(
                                backgroundColor: typeColors[a['type']],
                                child: Icon(a['icon'], color: Colors.white, size: 28),
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              child: Icon(a['icon'], color: Colors.grey, size: 28),
                            ),
                        title: Text(a['title'], style: TextStyle(fontWeight: FontWeight.bold, color: a['unlocked'] ? typeColors[a['type']] : Colors.grey)),
                        subtitle: Text(a['desc']),
                        trailing: a['unlocked']
                          ? const Text('已解鎖', style: TextStyle(color: Colors.green))
                          : const Text('未解鎖', style: TextStyle(color: Colors.grey)),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(a['title']),
                              content: Text(a['detail']),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('關閉'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )),
                  ],
                ),
          ],
        ),
      ),
    );
  }
} 