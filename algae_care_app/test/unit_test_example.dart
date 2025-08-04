import 'package:flutter_test/flutter_test.dart';
import 'package:algae_care_app/models/algae_profile.dart';
import 'package:algae_care_app/services/database_service.dart';

void main() {
  group('AlgaeProfile 測試', () {
    test('應該正確創建 AlgaeProfile', () {
      final profile = AlgaeProfile(
        id: 1,
        name: '測試藻類',
        species: 'Chlorella',
        startDate: DateTime.now(),
        notes: '測試筆記',
      );

      expect(profile.name, '測試藻類');
      expect(profile.species, 'Chlorella');
      expect(profile.notes, '測試筆記');
    });

    test('應該正確轉換為 Map', () {
      final profile = AlgaeProfile(
        id: 1,
        name: '測試藻類',
        species: 'Chlorella',
        startDate: DateTime(2024, 1, 1),
        notes: '測試筆記',
      );

      final map = profile.toMap();
      expect(map['name'], '測試藻類');
      expect(map['species'], 'Chlorella');
      expect(map['notes'], '測試筆記');
    });
  });

  group('DatabaseService 測試', () {
    test('應該正確初始化資料庫', () async {
      // 這裡可以測試資料庫初始化邏輯
      // 注意：實際測試時可能需要模擬資料庫
    });
  });
}