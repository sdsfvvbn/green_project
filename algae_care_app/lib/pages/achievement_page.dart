import 'package:flutter/material.dart';

class AchievementPage extends StatelessWidget {
  const AchievementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = [
      // 養殖基礎
      {'title': '首次養殖啟動', 'desc': '建立第一筆微藻日誌', 'unlocked': true, 'icon': Icons.play_circle, 'type': '基礎', 'detail': '只要你建立第一筆日誌，就能解鎖這個成就！'},
      {'title': '連續養殖7天', 'desc': '連續記錄養殖日誌7天', 'unlocked': true, 'icon': Icons.calendar_month, 'type': '基礎', 'detail': '連續7天都有日誌紀錄，展現你的養殖毅力。'},
      {'title': '首次換水', 'desc': '完成第一次換水操作', 'unlocked': true, 'icon': Icons.water_drop, 'type': '基礎', 'detail': '只要你在APP中記錄一次換水，就能獲得。'},
      {'title': '首次拍照記錄', 'desc': '上傳第一張微藻成長照片', 'unlocked': false, 'icon': Icons.camera_alt, 'type': '基礎', 'detail': '拍下你的微藻成長，留下第一個紀錄。'},
      // 成長與環保
      {'title': '吸碳達人', 'desc': '累積吸碳量達5kg', 'unlocked': false, 'icon': Icons.eco, 'type': '環保', 'detail': '只要你的吸碳量累積達5kg，就能獲得這個環保成就。'},
      {'title': '碳中和小尖兵', 'desc': '單月吸碳量達2kg', 'unlocked': false, 'icon': Icons.forest, 'type': '環保', 'detail': '單月吸碳量達2kg，為地球盡一份心力。'},
      {'title': '減碳連線', 'desc': '連續一週每天都有吸碳紀錄', 'unlocked': false, 'icon': Icons.link, 'type': '環保', 'detail': '一週內每天都有吸碳紀錄，持續減碳不間斷。'},
      {'title': '綠色生活推廣者', 'desc': '首次將成果分享到社群', 'unlocked': false, 'icon': Icons.share, 'type': '環保', 'detail': '將你的微藻成果分享到LINE/IG，推廣綠色生活。'},
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
    ];

    final typeColors = {
      '基礎': Colors.green[700],
      '環保': Colors.teal[700],
      '技術': Colors.blue[700],
      '知識': Colors.orange[700],
      '趣味': Colors.purple[700],
    };

    return Scaffold(
      appBar: AppBar(title: const Text('成就徽章'), backgroundColor: Colors.green[700]),
      body: ListView.builder(
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final a = achievements[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: (a['unlocked'] as bool) ? typeColors[a['type'] as String] : Colors.grey[300],
                child: Icon(
                  a['icon'] as IconData?,
                  color: (a['unlocked'] as bool) ? Colors.white : Colors.grey,
                  size: 28,
                ),
              ),
              title: Text(a['title'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: (a['unlocked'] as bool) ? typeColors[a['type'] as String] : Colors.grey)),
              subtitle: Text(a['desc'] as String),
              trailing: (a['unlocked'] as bool)
                  ? const Text('已解鎖', style: TextStyle(color: Colors.green))
                  : const Text('未解鎖', style: TextStyle(color: Colors.grey)),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(a['icon'] as IconData?, color: (a['unlocked'] as bool) ? typeColors[a['type'] as String] : Colors.grey),
                        const SizedBox(width: 8),
                        Text(a['title'] as String),
                      ],
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a['desc'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text('解鎖條件：', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                        Text(a['detail'] as String),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              (a['unlocked'] as bool) ? Icons.emoji_events : Icons.lock_outline,
                              color: (a['unlocked'] as bool) ? Colors.amber : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              (a['unlocked'] as bool) ? '已解鎖' : '尚未解鎖',
                              style: TextStyle(
                                color: (a['unlocked'] as bool) ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('關閉'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
} 