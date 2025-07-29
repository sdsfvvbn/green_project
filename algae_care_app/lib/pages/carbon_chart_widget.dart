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
    // 4. 初始濃度
    double initialCon = logConMap[DateTime(firstDate.year, firstDate.month, firstDate.day)] ?? 1.0;
    // 5. 濃度模擬
    List<double> simCon = [];
    double curCon = initialCon;
    for (int i = 0; i < allDays.length; i++) {
      final d = allDays[i];
      // 如果這天有日誌，直接用日誌濃度
      if (logConMap.containsKey(DateTime(d.year, d.month, d.day))) {
        curCon = logConMap[DateTime(d.year, d.month, d.day)]!;
      } else {
        // 推論 growth rate
        double growthRate = 0.3;
        // 前7天用0.3，之後用日誌推論
        if (i >= 7) {
          // 找最近兩筆日誌
          DateTime? prevDate;
          double? prevCon;
          for (int j = i - 1; j >= 0; j--) {
            if (logConMap.containsKey(DateTime(allDays[j].year, allDays[j].month, allDays[j].day))) {
              prevDate = allDays[j];
              prevCon = logConMap[DateTime(allDays[j].year, allDays[j].month, allDays[j].day)];
              break;
            }
          }
          DateTime? nextDate;
          double? nextCon;
          for (int j = i; j < allDays.length; j++) {
            if (logConMap.containsKey(DateTime(allDays[j].year, allDays[j].month, allDays[j].day))) {
              nextDate = allDays[j];
              nextCon = logConMap[DateTime(allDays[j].year, allDays[j].month, allDays[j].day)];
              break;
            }
          }
          if (prevDate != null && nextDate != null && prevCon != null && nextCon != null && nextDate.isAfter(prevDate)) {
            growthRate = (nextCon - prevCon) / nextDate.difference(prevDate).inDays;
          }
        }
        curCon += growthRate;
      }
      simCon.add(curCon);
    }
    // 6. 計算每日吸碳量
    List<double> simCarbon = [];
    for (int i = 0; i < simCon.length; i++) {
      double dryWeight = simCon[i] * widget.volume / 1000.0;
      double co2 = dryWeight * 0.5 * 3.67;
      simCarbon.add(co2);
    }
    // 7. 聚合資料（日/月/年）
    List<FlSpot> spots = [];
    if (widget.viewMode == 'day') {
      for (int i = 0; i < simCarbon.length; i++) {
        spots.add(FlSpot(i.toDouble(), simCarbon[i]));
      }
    } else if (widget.viewMode == 'month') {
      Map<String, double> monthMap = {};
      for (int i = 0; i < allDays.length; i++) {
        String ym = DateFormat('yyyy-MM').format(allDays[i]);
        monthMap[ym] = simCarbon[i];
      }
      int idx = 0;
      for (var entry in monthMap.entries) {
        spots.add(FlSpot(idx.toDouble(), entry.value));
        idx++;
      }
    } else if (widget.viewMode == 'year') {
      Map<String, double> yearMap = {};
      for (int i = 0; i < allDays.length; i++) {
        String y = DateFormat('yyyy').format(allDays[i]);
        yearMap[y] = simCarbon[i];
      }
      int idx = 0;
      for (var entry in yearMap.entries) {
        spots.add(FlSpot(idx.toDouble(), entry.value));
        idx++;
      }
    }
    // 8. 更新狀態
    setState(() {
      _allDays = allDays;
      _concentrationSim = simCon;
      _carbonSim = simCarbon;
      _totalCO2 = simCarbon.isNotEmpty ? simCarbon.last : 0;
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
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
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
                  maxY: _carbonSim.isNotEmpty && _carbonSim.length > 1 ? (_carbonSim.reduce((a, b) => a > b ? a : b) * 1.1) : (_carbonSim.isNotEmpty ? _carbonSim.first * 1.1 : 1),
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