import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../services/achievement_service.dart';
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
  List<Map<String, dynamic>> _achievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.15).chain(CurveTween(curve: Curves.elasticInOut)).animate(_controller);
    _controller.repeat(reverse: true);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final db = DatabaseService.instance;
    final achievementService = AchievementService.instance;
    
    final logs = await db.getAllLogs();
    final days = await db.getLogDays();
    
    // 檢查並更新成就狀態
    final newlyUnlocked = await achievementService.checkAndUpdateAchievements();
    
    // 如果有新解鎖的成就，顯示通知
    if (newlyUnlocked.isNotEmpty) {
      _showAchievementUnlockedDialog(newlyUnlocked);
    }
    
    // 獲取所有成就狀態
    final achievements = await achievementService.getAllAchievements();
    
    setState(() {
      _algaeVolume = prefs.getDouble('algae_volume') ?? 1.0;
      _logDays = days > 0 ? days : 1;
      _logs = logs;
      _achievements = achievements;
      _isLoading = false;
    });
  }

  void _showAchievementUnlockedDialog(List<String> newlyUnlocked) {
    final achievementService = AchievementService.instance;
    final achievement = achievementService.achievements[newlyUnlocked.first];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnim,
              child: Icon(
                _getIconData(achievement!['icon']),
                color: Colors.amber,
                size: 48,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '🎉 成就解鎖！',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              achievement['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              achievement['detail'],
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('太棒了！'),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'play_circle':
        return Icons.play_circle;
      case 'calendar_month':
        return Icons.calendar_month;
      case 'water_drop':
        return Icons.water_drop;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'eco':
        return Icons.eco;
      case 'forest':
        return Icons.forest;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'share':
        return Icons.share;
      case 'question_answer':
        return Icons.question_answer;
      case 'check_circle':
        return Icons.check_circle;
      case 'psychology':
        return Icons.psychology;
      case 'photo_camera':
        return Icons.photo_camera;
      default:
        return Icons.star;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final typeColors = {
      '基礎': Colors.green[700],
      '環保': Colors.teal[700],
      '技術': Colors.blue[700],
      '知識': Colors.orange[700],
      '趣味': Colors.purple[700],
    };
    
    final typeNames = ['基礎', '環保', '技術', '知識', '趣味'];
    
    // 分組成就
    Map<String, List<Map<String, dynamic>>> grouped = {for (var t in typeNames) t: []};
    for (var a in _achievements) {
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: '重新整理',
          ),
        ],
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
            // 成就統計卡片
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '成就進度',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_achievements.where((a) => a['unlocked']).length} / ${_achievements.length} 個成就已解鎖',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                                child: Icon(_getIconData(a['icon']), color: Colors.white, size: 28),
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              child: Icon(_getIconData(a['icon']), color: Colors.grey, size: 28),
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