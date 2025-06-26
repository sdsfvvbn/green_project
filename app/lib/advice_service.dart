class AdviceService {
  // 模擬日誌數據
  List<Map<String, dynamic>> logs = [
    {'growth_rate': 0.5, 'temperature': 25, 'humidity': 60},
    {'growth_rate': 0.7, 'temperature': 22, 'humidity': 65},
  ];

  // 簡單的if-else建議邏輯
  String getAdvice() {
    var latestLog = logs.last;
    if (latestLog['growth_rate'] < 0.6) {
      return '建議增加澆水頻率，並確保光照充足。';
    } else {
      return '植物生長狀況良好，請繼續保持！';
    }
  }

  // 吸碳量計算
  double calculateCarbonSequestration() {
    const carbonPerPlantPerMonth = 0.5; // 每株植物每月吸碳量（kg）
    int plantCount = logs.length; // 模擬植物數量
    return plantCount * carbonPerPlantPerMonth;
  }

  // 圖表數據
  List<double> getChartData() {
    return logs.map((log) => log['growth_rate'] as double).toList();
  }
}