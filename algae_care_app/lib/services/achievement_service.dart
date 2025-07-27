import 'package:shared_preferences/shared_preferences.dart';
import '../models/algae_log.dart';
import 'database_service.dart';

class AchievementService {
  static final AchievementService instance = AchievementService._internal();
  factory AchievementService() => instance;
  AchievementService._internal();

  // 成就定義
  static const Map<String, Map<String, dynamic>> _achievements = {
    'first_log': {
      'title': '首次養殖啟動',
      'desc': '建立第一筆微藻日誌',
      'icon': 'play_circle',
      'type': '基礎',
      'detail': '只要你建立第一筆日誌，就能解鎖這個成就！'
    },
    'seven_days': {
      'title': '連續養殖7天',
      'desc': '連續記錄養殖日誌7天',
      'icon': 'calendar_month',
      'type': '基礎',
      'detail': '連續7天都有日誌紀錄，展現你的養殖毅力。'
    },
    'log_30_days': {
      'title': '堅持一個月',
      'desc': '累積30天日誌紀錄',
      'icon': 'calendar_month',
      'type': '基礎',
      'detail': '連續或累積30天都有日誌紀錄，養成好習慣。'
    },
    'first_water_change': {
      'title': '首次換水',
      'desc': '完成第一次換水操作',
      'icon': 'water_drop',
      'type': '基礎',
      'detail': '只要你在APP中記錄一次換水，就能獲得。'
    },
    'log_water_change_5': {
      'title': '換水小能手',
      'desc': '累積5次換水紀錄',
      'icon': 'water_drop',
      'type': '基礎',
      'detail': '累積5次換水，維護微藻健康。'
    },
    'first_photo': {
      'title': '首次拍照記錄',
      'desc': '上傳第一張微藻成長照片',
      'icon': 'camera_alt',
      'type': '基礎',
      'detail': '拍下你的微藻成長，留下第一個紀錄。'
    },
    'photo_master': {
      'title': '微藻美照達人',
      'desc': '上傳5張微藻成長照片',
      'icon': 'photo_camera',
      'type': '趣味',
      'detail': '累積上傳5張微藻照片，記錄美好成長。'
    },
    'photo_10': {
      'title': '攝影小達人',
      'desc': '上傳10張微藻照片',
      'icon': 'photo_camera',
      'type': '趣味',
      'detail': '累積上傳10張微藻照片，記錄成長點滴。'
    },
    'log_fertilize': {
      'title': '施肥紀錄',
      'desc': '首次記錄施肥',
      'icon': 'science',
      'type': '基礎',
      'detail': '記錄一次施肥，促進微藻成長。'
    },
    'carbon_5kg': {
      'title': '吸碳達人',
      'desc': '累積吸碳量達5kg',
      'icon': 'eco',
      'type': '環保',
      'detail': '只要你的吸碳量累積達5kg，就能獲得這個環保成就。'
    },
    'carbon_10kg': {
      'title': '碳中和小尖兵',
      'desc': '累積吸碳量達10kg',
      'icon': 'forest',
      'type': '環保',
      'detail': '吸碳量達10kg，為地球盡一份心力。'
    },
    'carbon_20kg': {
      'title': '碳英雄',
      'desc': '累積吸碳量達20kg',
      'icon': 'emoji_events',
      'type': '環保',
      'detail': '吸碳量達20kg，成為碳英雄！'
    },
    'share_achievement': {
      'title': '首次社群分享',
      'desc': '首次將成果分享到社群',
      'icon': 'share',
      'type': '環保',
      'detail': '將你的微藻成果分享到LINE/IG/FB，推廣綠色生活。'
    },
    'share_3_platforms': {
      'title': '社群分享高手',
      'desc': '分享到3個不同平台',
      'icon': 'public',
      'type': '環保',
      'detail': '將成果分享到LINE/IG/FB三個平台，推廣綠生活。'
    },
    'quiz_master': {
      'title': '挑戰小遊戲全對',
      'desc': '挑戰小遊戲全數答對',
      'icon': 'question_answer',
      'type': '知識',
      'detail': '挑戰小遊戲所有題目全對，成為知識王者。'
    },
    'quiz_5_correct': {
      'title': '挑戰小遊戲高手',
      'desc': '挑戰小遊戲答對5題',
      'icon': 'psychology',
      'type': '知識',
      'detail': '挑戰小遊戲答對5題，知識力UP!'
    },
    'diy_algae': {
      'title': 'DIY創意王',
      'desc': '完成1次DIY微藻應用',
      'icon': 'lightbulb',
      'type': '趣味',
      'detail': 'DIY微藻果凍、餅乾、面膜等，創意無限。'
    },
    'challenge_event': {
      'title': '挑戰參與者',
      'desc': '參加一次官方/社群挑戰',
      'icon': 'emoji_events',
      'type': '趣味',
      'detail': '參加微藻相關挑戰賽，與大家一起成長。'
    },
    'profile_complete': {
      'title': '個人檔案達人',
      'desc': '完整填寫個人檔案',
      'icon': 'person',
      'type': '基礎',
      'detail': '填寫暱稱、頭像、簡介，展現自我。'
    },
    'log_with_note': {
      'title': '心得分享',
      'desc': '日誌含心得',
      'icon': 'edit_note',
      'type': '基礎',
      'detail': '日誌中有心得文字，分享你的想法。'
    },
  };

  // 公開的getter來訪問成就定義
  Map<String, Map<String, dynamic>> get achievements => _achievements;

  // 檢查成就是否解鎖
  Future<bool> isAchievementUnlocked(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('achievement_$achievementId') ?? false;
  }

  // 解鎖成就
  Future<void> unlockAchievement(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('achievement_$achievementId', true);
  }

  // 檢查並更新成就狀態
  Future<List<String>> checkAndUpdateAchievements() async {
    final List<String> newlyUnlocked = [];
    final db = DatabaseService.instance;
    final prefs = await SharedPreferences.getInstance();
    final logs = await db.getAllLogs();
    final days = await db.getLogDays();
    final algaeVolume = prefs.getDouble('algae_volume') ?? 1.0;
    final totalCO2 = algaeVolume * 2 * days / 365;

    // 1. 首次日誌
    if (!await isAchievementUnlocked('first_log') && logs.isNotEmpty) {
      await unlockAchievement('first_log');
      newlyUnlocked.add('first_log');
    }
    // 2. 連續養殖7天
    if (!await isAchievementUnlocked('seven_days') && days >= 7) {
      await unlockAchievement('seven_days');
      newlyUnlocked.add('seven_days');
    }
    // 3. 堅持一個月
    if (!await isAchievementUnlocked('log_30_days') && days >= 30) {
      await unlockAchievement('log_30_days');
      newlyUnlocked.add('log_30_days');
    }
    // 4. 首次換水
    if (!await isAchievementUnlocked('first_water_change') && logs.any((log) => log.isWaterChanged == 1)) {
      await unlockAchievement('first_water_change');
      newlyUnlocked.add('first_water_change');
    }
    // 5. 換水小能手
    if (!await isAchievementUnlocked('log_water_change_5') && logs.where((log) => log.isWaterChanged == 1).length >= 5) {
      await unlockAchievement('log_water_change_5');
      newlyUnlocked.add('log_water_change_5');
    }
    // 6. 首次拍照
    if (!await isAchievementUnlocked('first_photo') && logs.any((log) => log.photoPath != null && log.photoPath!.isNotEmpty)) {
      await unlockAchievement('first_photo');
      newlyUnlocked.add('first_photo');
    }
    // 7. 微藻美照達人
    if (!await isAchievementUnlocked('photo_master') && logs.where((log) => log.photoPath != null && log.photoPath!.isNotEmpty).length >= 5) {
      await unlockAchievement('photo_master');
      newlyUnlocked.add('photo_master');
    }
    // 8. 攝影小達人
    if (!await isAchievementUnlocked('photo_10') && logs.where((log) => log.photoPath != null && log.photoPath!.isNotEmpty).length >= 10) {
      await unlockAchievement('photo_10');
      newlyUnlocked.add('photo_10');
    }
    // 9. 施肥紀錄
    if (!await isAchievementUnlocked('log_fertilize') && logs.any((log) => log.isFertilized == 1)) {
      await unlockAchievement('log_fertilize');
      newlyUnlocked.add('log_fertilize');
    }
    // 10. 吸碳達人
    if (!await isAchievementUnlocked('carbon_5kg') && totalCO2 >= 5) {
      await unlockAchievement('carbon_5kg');
      newlyUnlocked.add('carbon_5kg');
    }
    // 11. 碳中和小尖兵
    if (!await isAchievementUnlocked('carbon_10kg') && totalCO2 >= 10) {
      await unlockAchievement('carbon_10kg');
      newlyUnlocked.add('carbon_10kg');
    }
    // 12. 碳英雄
    if (!await isAchievementUnlocked('carbon_20kg') && totalCO2 >= 20) {
      await unlockAchievement('carbon_20kg');
      newlyUnlocked.add('carbon_20kg');
    }
    // 13. 首次社群分享
    if (!await isAchievementUnlocked('share_achievement') && (prefs.getBool('share_achievement_unlocked') ?? false)) {
      await unlockAchievement('share_achievement');
      newlyUnlocked.add('share_achievement');
    }
    // 14. 社群分享高手
    if (!await isAchievementUnlocked('share_3_platforms') && (prefs.getInt('share_platform_count') ?? 0) >= 3) {
      await unlockAchievement('share_3_platforms');
      newlyUnlocked.add('share_3_platforms');
    }
    // 15. 挑戰小遊戲全對
    if (!await isAchievementUnlocked('quiz_master') && (prefs.getBool('quiz_all_correct') ?? false)) {
      await unlockAchievement('quiz_master');
      newlyUnlocked.add('quiz_master');
    }
    // 16. 挑戰小遊戲高手
    if (!await isAchievementUnlocked('quiz_5_correct') && (prefs.getInt('quiz_5_correct') ?? 0) >= 1) {
      await unlockAchievement('quiz_5_correct');
      newlyUnlocked.add('quiz_5_correct');
    }
    // 17. DIY創意王
    if (!await isAchievementUnlocked('diy_algae') && (prefs.getBool('diy_algae_done') ?? false)) {
      await unlockAchievement('diy_algae');
      newlyUnlocked.add('diy_algae');
    }
    // 18. 挑戰參與者
    if (!await isAchievementUnlocked('challenge_event') && (prefs.getBool('challenge_event_done') ?? false)) {
      await unlockAchievement('challenge_event');
      newlyUnlocked.add('challenge_event');
    }
    // 19. 個人檔案達人
    if (!await isAchievementUnlocked('profile_complete')) {
      final nickname = prefs.getString('profile_nickname') ?? '';
      final bio = prefs.getString('profile_bio') ?? '';
      final avatar = prefs.getString('profile_avatar') ?? '';
      if (nickname.isNotEmpty && bio.isNotEmpty && avatar.isNotEmpty) {
        await unlockAchievement('profile_complete');
        newlyUnlocked.add('profile_complete');
      }
    }
    // 20. 心得分享
    if (!await isAchievementUnlocked('log_with_note') && logs.any((log) => log.notes != null && log.notes!.trim().isNotEmpty)) {
      await unlockAchievement('log_with_note');
      newlyUnlocked.add('log_with_note');
    }
    return newlyUnlocked;
  }

  // 獲取所有成就狀態
  Future<List<Map<String, dynamic>>> getAllAchievements() async {
    final List<Map<String, dynamic>> result = [];
    
    for (final entry in achievements.entries) {
      final achievementId = entry.key;
      final achievement = entry.value;
      final isUnlocked = await isAchievementUnlocked(achievementId);
      
      result.add({
        'id': achievementId,
        'title': achievement['title'],
        'desc': achievement['desc'],
        'icon': achievement['icon'],
        'type': achievement['type'],
        'detail': achievement['detail'],
        'unlocked': isUnlocked,
      });
    }
    
    return result;
  }

  // 獲取已解鎖的成就數量
  Future<int> getUnlockedAchievementCount() async {
    int count = 0;
    for (final achievementId in achievements.keys) {
      if (await isAchievementUnlocked(achievementId)) {
        count++;
      }
    }
    return count;
  }

  // 重置所有成就（用於測試）
  Future<void> resetAllAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    for (final achievementId in achievements.keys) {
      await prefs.remove('achievement_$achievementId');
    }
  }
} 