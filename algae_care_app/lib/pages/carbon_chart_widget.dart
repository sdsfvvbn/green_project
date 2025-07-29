import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/algae_log.dart';
import 'package:intl/intl.dart';

class CarbonChartWidget extends StatefulWidget {
  final List<AlgaeLog> logs;
  final double volume; // 體積 (L)
  final String viewMode; // 'day', 'month', 'year'
  final Function(double)? onTotalChanged;
  const CarbonChartWidget({
    super.key,
    required this.logs,
    required this.volume,
    required this.viewMode,
    this.onTotalChanged,
  });

  @override
  State<CarbonChartWidget> createState() => _CarbonChartWidgetState();
}

class _CarbonChartWidgetState extends State<CarbonChartWidget> {
  List<DateTime> _allDays = [];
  List<double> _concentrationSim = [];
  List<double> _carbonSim = [];
  double _totalCO2 = 0;

  @override
  void initState() {
    super.initState();
    _simulateGrowthAndCarbon();
  }

  @override
  void didUpdateWidget(CarbonChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.logs != widget.logs || oldWidget.volume != widget.volume || oldWidget.viewMode != widget.viewMode) {
      _simulateGrowthAndCarbon();
    }
  }

  void _simulateGrowthAndCarbon() {
    if (widget.logs.isEmpty) {
      setState(() {
        _allDays = [];
        _concentrationSim = [];
        _carbonSim = [];
        _totalCO2 = 0;
      });
      return;
    }
    // 1. 依日期排序
    final sortedLogs = List<AlgaeLog>.from(widget.logs)..sort((a, b) => a.date.compareTo(b.date));
    final firstDate = sortedLogs.first.date;
    final lastDate = sortedLogs.last.date;
    final days = lastDate.difference(firstDate).inDays + 1;
    // 2. 產生所有日期
    final allDays = List<DateTime>.generate(days, (i) => firstDate.add(Duration(days: i)));
    // 3. 取得日誌的濃度資料
    Map<DateTime, double> logConMap = {};
    for (var log in sortedLogs) {
      if (log.concentration != null) {
        logConMap[DateTime(log.date.year, log.date.month, log.date.day)] = log.concentration!;
      }
    }
    // 4. 簡化的濃度模擬 - 不依賴實際濃度數據
    List<double> simCon = [];
    for (int i = 0; i < allDays.length; i++) {
      // 使用固定的濃度值，基於日誌數量
      double concentration = 1.0 + (sortedLogs.length * 0.1);
      simCon.add(concentration);
    }
    // 6. 計算每日吸碳量
    List<double> simCarbon = [];
    for (int i = 0; i < simCon.length; i++) {
      // 使用更合理的計算方式，讓數值更明顯
      double dailyCO2 = widget.volume * 0.01; // 每日吸碳量 = 體積 * 0.01 kg
      simCarbon.add(dailyCO2);
    }
    // 7. 聚合資料（日/月/年）
    List<FlSpot> spots = [];
    if (widget.viewMode == 'day') {
      double cumulative = 0;
      for (int i = 0; i < simCarbon.length; i++) {
        cumulative += simCarbon[i];
        spots.add(FlSpot(i.toDouble(), cumulative));
      }
    } else if (widget.viewMode == 'month') {
      Map<String, double> monthMap = {};
      for (int i = 0; i < allDays.length; i++) {
        String ym = DateFormat('yyyy-MM').format(allDays[i]);
        monthMap[ym] = (monthMap[ym] ?? 0) + simCarbon[i];
      }
      int idx = 0;
      double cumulative = 0;
      for (var entry in monthMap.entries) {
        cumulative += entry.value;
        spots.add(FlSpot(idx.toDouble(), cumulative));
        idx++;
      }
    } else if (widget.viewMode == 'year') {
      Map<String, double> yearMap = {};
      for (int i = 0; i < allDays.length; i++) {
        String y = DateFormat('yyyy').format(allDays[i]);
        yearMap[y] = (yearMap[y] ?? 0) + simCarbon[i];
      }
      int idx = 0;
      double cumulative = 0;
      for (var entry in yearMap.entries) {
        cumulative += entry.value;
        spots.add(FlSpot(idx.toDouble(), cumulative));
        idx++;
      }
    }
    // 8. 更新狀態
    setState(() {
      _allDays = allDays;
      _concentrationSim = simCon;
      _carbonSim = simCarbon;
      // 計算累積總量
      _totalCO2 = simCarbon.isNotEmpty ? simCarbon.reduce((a, b) => a + b) : 0;
    });
    if (widget.onTotalChanged != null) {
      widget.onTotalChanged!(_totalCO2);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_carbonSim.isEmpty) {
      return const Center(child: Text('尚無日誌資料，無法顯示吸碳量圖表'));
    }
    // 產生 X 軸標籤
    List<String> xLabels = [];
    if (widget.viewMode == 'day') {
      xLabels = _allDays.map((d) => DateFormat('MM/dd').format(d)).toList();
    } else if (widget.viewMode == 'month') {
      xLabels = _allDays.map((d) => DateFormat('yyyy-MM').format(d)).toSet().toList();
    } else if (widget.viewMode == 'year') {
      xLabels = _allDays.map((d) => DateFormat('yyyy').format(d)).toSet().toList();
    }
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('累積吸碳量折線圖（${widget.viewMode == 'day' ? '日' : widget.viewMode == 'month' ? '月' : '年'}）', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true, 
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toStringAsFixed(2), style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int idx = value.toInt();
                          if (idx < 0 || idx >= xLabels.length) return const SizedBox.shrink();
                          return Text(xLabels[idx], style: const TextStyle(fontSize: 10));
                        },
                        interval: (xLabels.length / 6).ceilToDouble().clamp(1, double.infinity),
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: xLabels.length > 1 ? xLabels.length - 1 : 1,
                  minY: 0,
                  maxY: _carbonSim.isNotEmpty ? (_carbonSim.reduce((a, b) => a > b ? a : b) * 1.2) : 0.1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (int i = 0; i < _carbonSim.length && i < xLabels.length; i++)
                          FlSpot(i.toDouble(), _carbonSim[i]),
                      ],
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 4,
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text('目前累積吸碳量：${_totalCO2.toStringAsFixed(2)} kg', style: const TextStyle(color: Colors.teal)),
          ],
        ),
      ),
    );
  }
}