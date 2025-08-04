# Flutter 應用程式測試命令

## 1. 執行所有測試
```bash
flutter test
```

## 2. 執行特定測試檔案
```bash
# 執行單元測試
flutter test test/unit_test_example.dart

# 執行 Widget 測試
flutter test test/widget_tests.dart

# 執行整合測試
flutter test integration_test/app_test.dart
```

## 3. 執行測試並顯示詳細資訊
```bash
flutter test --verbose
```

## 4. 執行測試並生成覆蓋率報告
```bash
flutter test --coverage
```

## 5. 在特定平台上執行測試
```bash
# 在 Android 模擬器上執行
flutter test --device-id <device-id>

# 在 iOS 模擬器上執行
flutter test --device-id <device-id>
```

## 6. 執行整合測試（需要實體裝置或模擬器）
```bash
flutter drive --target=integration_test/app_test.dart
```

## 7. 檢查測試覆蓋率
```bash
# 安裝 lcov（如果尚未安裝）
# Windows: choco install lcov
# macOS: brew install lcov
# Linux: sudo apt-get install lcov

# 生成覆蓋率報告
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 8. 持續整合測試
```bash
# 在 CI/CD 環境中執行
flutter test --coverage --reporter=json
```

## 測試最佳實踐

### 1. 測試命名規範
- 測試函數名稱應該清楚描述測試的目的
- 使用 `test()` 進行單元測試
- 使用 `testWidgets()` 進行 Widget 測試
- 使用 `group()` 組織相關的測試

### 2. 測試結構
```dart
void main() {
  group('功能名稱', () {
    setUp(() {
      // 測試前的準備工作
    });

    tearDown(() {
      // 測試後的清理工作
    });

    test('測試描述', () {
      // 測試邏輯
    });
  });
}
```

### 3. 常見測試模式
- **Arrange**: 準備測試資料
- **Act**: 執行被測試的功能
- **Assert**: 驗證結果

### 4. 測試資料庫相關功能
```dart
// 使用測試資料庫
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    // 初始化測試資料庫
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
}
```

### 5. 模擬外部依賴
```dart
// 使用 mockito 進行模擬
import 'package:mockito/mockito.dart';

class MockDatabaseService extends Mock implements DatabaseService {}
```

## 故障排除

### 常見問題
1. **測試失敗**: 檢查測試環境和依賴項
2. **Widget 測試超時**: 增加 `pumpAndSettle()` 等待時間
3. **整合測試失敗**: 確保有可用的模擬器或實體裝置

### 調試技巧
```bash
# 顯示詳細的測試輸出
flutter test --verbose

# 在特定測試上設置斷點
flutter test --start-paused
```