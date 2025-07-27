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
    'first_water_change': {
      'title': '首次換水',
      'desc': '完成第一次換水操作',
      'icon': 'water_drop',
      'type': '基礎',
      'detail': '只要你在APP中記錄一次換水，就能獲得。'
    },
    'first_photo': {
      'title': '首次拍照記錄',
      'desc': '上傳第一張微藻成長照片',
      'icon': 'camera_alt',
      'type': '基礎',
      'detail': '拍下你的微藻成長，留下第一個紀錄。'
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
      'title': '綠色生活推廣者',
      'desc': '首次將成果分享到社群',
      'icon': 'share',
      'type': '環保',
      'detail': '將你的微藻成果分享到LINE/IG/FB，推廣綠色生活。'
    },
    'quiz_master': {
      'title': 'Q&A達人',
      'desc': '正確回答知識小學堂Q&A',
      'icon': 'question_answer',
      'type': '知識',
      'detail': '答對知識小學堂的小測驗，成為Q&A達人。'
    },
    'daily_checkin_10': {
      'title': '每日打卡達人',
      'desc': '連續每日打卡10天',
      'icon': 'check_circle',
      'type': '基礎',
      'detail': '連續10天打卡，培養好習慣。'
    },
    'quiz_5_correct': {
      'title': '知識挑戰王',
      'desc': '答對5題知識小學堂',
      'icon': 'psychology',
      'type': '知識',
      'detail': '知識小學堂答對5題，知識力UP!'
    },
    'photo_master': {
      'title': '微藻美照達人',
      'desc': '上傳5張微藻成長照片',
      'icon': 'photo_camera',
      'type': '趣味',
      'detail': '累積上傳5張微藻照片，記錄美好成長。'
    },
    // 新增成就
    'log_30_days': {
      'title': '堅持一個月',
      'desc': '累積30天日誌紀錄',
      'icon': 'calendar_month',
      'type': '基礎',
      'detail': '連續或累積30天都有日誌紀錄，養成好習慣。'
    },
    'photo_10': {
      'title': '攝影小達人',
      'desc': '上傳10張微藻照片',
      'icon': 'photo_camera',
      'type': '趣味',
      'detail': '累積上傳10張微藻照片，記錄成長點滴。'
    },
    'share_3_platforms': {
      'title': '社群分享高手',
      'desc': '分享到3個不同平台',
      'icon': 'public',
      'type': '環保',
      'detail': '將成果分享到LINE/IG/FB三個平台，推廣綠生活。'
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
    'log_with_photo': {
      'title': '圖文並茂',
      'desc': '日誌含照片',
      'icon': 'insert_photo',
      'type': '基礎',
      'detail': '日誌中有照片，記錄更生動。'
    },
    'log_with_note': {
      'title': '心得分享',
      'desc': '日誌含心得',
      'icon': 'edit_note',
      'type': '基礎',
      'detail': '日誌中有心得文字，分享你的想法。'
    },
    'log_water_change_5': {
      'title': '換水小能手',
      'desc': '累積5次換水紀錄',
      'icon': 'water_drop',
      'type': '基礎',
      'detail': '累積5次換水，維護微藻健康。'
    },
    'log_fertilize': {
      'title': '施肥紀錄',
      'desc': '首次記錄施肥',
      'icon': 'science',
      'type': '基礎',
      'detail': '記錄一次施肥，促進微藻成長。'
    },
    'log_temp_stable': {
      'title': '溫度穩定王',
      'desc': '連續7天溫度紀錄穩定',
      'icon': 'thermostat',
      'type': '技術',
      'detail': '一週內溫度紀錄穩定，養殖環境佳。'
    },
    'log_ph_stable': {
      'title': 'pH守護者',
      'desc': '連續7天pH值穩定',
      'icon': 'science',
      'type': '技術',
      'detail': '一週內pH值都在理想範圍，微藻健康成長。'
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

    // 檢查首次養殖啟動
    if (!await isAchievementUnlocked('first_log')) {
      final logs = await db.getAllLogs();
      if (logs.isNotEmpty) {
        await unlockAchievement('first_log');
        newlyUnlocked.add('first_log');
      }
    }

    // 檢查連續養殖7天
    if (!await isAchievementUnlocked('seven_days')) {
      final days = await db.getLogDays();
      if (days >= 7) {
        await unlockAchievement('seven_days');
        newlyUnlocked.add('seven_days');
      }
    }

    // 檢查首次換水
    if (!await isAchievementUnlocked('first_water_change')) {
      final logs = await db.getAllLogs();
      final hasWaterChange = logs.any((log) => log.isWaterChanged == 1);
      if (hasWaterChange) {
        await unlockAchievement('first_water_change');
        newlyUnlocked.add('first_water_change');
      }
    }

    // 檢查首次拍照
    if (!await isAchievementUnlocked('first_photo')) {
      final logs = await db.getAllLogs();
      final hasPhoto = logs.any((log) => log.photoPath != null && log.photoPath!.isNotEmpty);
      if (hasPhoto) {
        await unlockAchievement('first_photo');
        newlyUnlocked.add('first_photo');
      }
    }

    // 檢查吸碳成就
    final prefs = await SharedPreferences.getInstance();
    final algaeVolume = prefs.getDouble('algae_volume') ?? 1.0;
    final days = await db.getLogDays();
    final totalCO2 = algaeVolume * 2 * days / 365;

    if (!await isAchievementUnlocked('carbon_5kg') && totalCO2 >= 5) {
      await unlockAchievement('carbon_5kg');
      newlyUnlocked.add('carbon_5kg');
    }

    if (!await isAchievementUnlocked('carbon_10kg') && totalCO2 >= 10) {
      await unlockAchievement('carbon_10kg');
      newlyUnlocked.add('carbon_10kg');
    }

    if (!await isAchievementUnlocked('carbon_20kg') && totalCO2 >= 20) {
      await unlockAchievement('carbon_20kg');
      newlyUnlocked.add('carbon_20kg');
    }

    // 檢查分享成就
    if (!await isAchievementUnlocked('share_achievement')) {
      final shareUnlocked = prefs.getBool('share_achievement_unlocked') ?? false;
      if (shareUnlocked) {
        await unlockAchievement('share_achievement');
        newlyUnlocked.add('share_achievement');
      }
    }

    // 檢查每日打卡達人
    if (!await isAchievementUnlocked('daily_checkin_10')) {
      final days = await db.getLogDays();
      if (days >= 10) {
        await unlockAchievement('daily_checkin_10');
        newlyUnlocked.add('daily_checkin_10');
      }
    }

    // 檢查拍照達人
    if (!await isAchievementUnlocked('photo_master')) {
      final logs = await db.getAllLogs();
      final photoCount = logs.where((log) => log.photoPath != null && log.photoPath!.isNotEmpty).length;
      if (photoCount >= 5) {
        await unlockAchievement('photo_master');
        newlyUnlocked.add('photo_master');
      }
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