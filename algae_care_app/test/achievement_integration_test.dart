import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:algae_care_app/services/achievement_service.dart';
import 'package:algae_care_app/services/database_service.dart';
import 'package:algae_care_app/models/algae_log.dart';

void main() {
  group('成就系統整合測試', () {
    late AchievementService achievementService;
    late DatabaseService databaseService;

    setUpAll(() async {
      achievementService = AchievementService.instance;
      databaseService = DatabaseService.instance;

      // 重置所有成就狀態
      await achievementService.resetAllAchievements();
    });

    test('首次日誌成就測試', () async {
      // 創建第一筆日誌
      final log = AlgaeLog(
        id: 1,
        date: DateTime.now(),
        waterVolume: 1.0,
        waterColor: '綠色',
        isWaterChanged: false,
        isFertilized: false,
        notes: '測試日誌',
      );

      await databaseService.createLog(log);

      // 檢查成就
      final newlyUnlocked = await achievementService.checkAndUpdateAchievements();
      expect(newlyUnlocked.contains('first_log'), true);

      // 驗證成就已解鎖
      final isUnlocked = await achievementService.isAchievementUnlocked('first_log');
      expect(isUnlocked, true);
    });

    test('拍照成就測試', () async {
      // 創建帶有照片的日誌
      final logWithPhoto = AlgaeLog(
        id: 2,
        date: DateTime.now(),
        waterVolume: 1.0,
        waterColor: '綠色',
        photoPath: '/test/photo.jpg',
        isWaterChanged: false,
        isFertilized: false,
      );

      await databaseService.createLog(logWithPhoto);

      // 檢查成就
      final newlyUnlocked = await achievementService.checkAndUpdateAchievements();
      expect(newlyUnlocked.contains('first_photo'), true);
    });

    test('換水成就測試', () async {
      // 創建換水日誌
      final waterChangeLog = AlgaeLog(
        id: 3,
        date: DateTime.now(),
        waterVolume: 1.0,
        waterColor: '綠色',
        isWaterChanged: true,
        isFertilized: false,
      );

      await databaseService.createLog(waterChangeLog);

      // 檢查成就
      final newlyUnlocked = await achievementService.checkAndUpdateAchievements();
      expect(newlyUnlocked.contains('first_water_change'), true);
    });

    test('施肥成就測試', () async {
      // 創建施肥日誌
      final fertilizeLog = AlgaeLog(
        id: 4,
        date: DateTime.now(),
        waterVolume: 1.0,
        waterColor: '綠色',
        isWaterChanged: false,
        isFertilized: true,
      );

      await databaseService.createLog(fertilizeLog);

      // 檢查成就
      final newlyUnlocked = await achievementService.checkAndUpdateAchievements();
      expect(newlyUnlocked.contains('log_fertilize'), true);
    });

    test('心得分享成就測試', () async {
      // 創建帶有筆記的日誌
      final noteLog = AlgaeLog(
        id: 5,
        date: DateTime.now(),
        waterVolume: 1.0,
        waterColor: '綠色',
        notes: '今天微藻生長得很好！',
        isWaterChanged: false,
        isFertilized: false,
      );

      await databaseService.createLog(noteLog);

      // 檢查成就
      final newlyUnlocked = await achievementService.checkAndUpdateAchievements();
      expect(newlyUnlocked.contains('log_with_note'), true);
    });

    test('分享成就測試', () async {
      final prefs = await SharedPreferences.getInstance();

      // 模擬分享到不同平台
      await prefs.setBool('share_achievement_unlocked', true);
      await prefs.setInt('share_platform_count', 3);

      // 檢查成就
      final newlyUnlocked = await achievementService.checkAndUpdateAchievements();
      expect(newlyUnlocked.contains('share_achievement'), true);
      expect(newlyUnlocked.contains('share_3_platforms'), true);
    });

    test('小遊戲成就測試', () async {
      final prefs = await SharedPreferences.getInstance();

      // 模擬小遊戲結果
      await prefs.setBool('quiz_all_correct', true);
      await prefs.setInt('quiz_play_count', 5);

      // 檢查成就
      final newlyUnlocked = await achievementService.checkAndUpdateAchievements();
      expect(newlyUnlocked.contains('quiz_master'), true);
      expect(newlyUnlocked.contains('quiz_5_correct'), true);
    });

    test('吸碳量成就測試', () async {
      final prefs = await SharedPreferences.getInstance();

      // 設置藻類體積
      await prefs.setDouble('algae_volume', 10.0);

      // 創建多筆日誌來增加吸碳量
      for (int i = 0; i < 100; i++) {
        final log = AlgaeLog(
          id: 10 + i,
          date: DateTime.now().add(Duration(days: i)),
          waterVolume: 10.0,
          waterColor: '綠色',
          isWaterChanged: false,
          isFertilized: false,
        );
        await databaseService.createLog(log);
      }

      // 檢查成就
      final newlyUnlocked = await achievementService.checkAndUpdateAchievements();
      expect(newlyUnlocked.contains('carbon_5kg'), true);
    });

    test('連續天數成就測試', () async {
      // 創建連續7天的日誌
      for (int i = 0; i < 7; i++) {
        final log = AlgaeLog(
          id: 200 + i,
          date: DateTime.now().subtract(Duration(days: 6 - i)),
          waterVolume: 1.0,
          waterColor: '綠色',
          isWaterChanged: false,
          isFertilized: false,
        );
        await databaseService.createLog(log);
      }

      // 檢查成就
      final newlyUnlocked = await achievementService.checkAndUpdateAchievements();
      expect(newlyUnlocked.contains('seven_days'), true);
    });

    test('所有成就狀態測試', () async {
      final achievements = await achievementService.getAllAchievements();

      // 驗證所有成就都有正確的結構
      for (final achievement in achievements) {
        expect(achievement['id'], isNotNull);
        expect(achievement['title'], isNotNull);
        expect(achievement['desc'], isNotNull);
        expect(achievement['icon'], isNotNull);
        expect(achievement['type'], isNotNull);
        expect(achievement['detail'], isNotNull);
        expect(achievement['unlocked'], isA<bool>());
      }
    });

    test('已解鎖成就數量測試', () async {
      final unlockedCount = await achievementService.getUnlockedAchievementCount();
      expect(unlockedCount, isA<int>());
      expect(unlockedCount, greaterThanOrEqualTo(0));
    });
  });
}