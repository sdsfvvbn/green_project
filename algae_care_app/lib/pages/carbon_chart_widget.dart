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
    // 3. 取得日誌的濃度資料（根據水色自動給定預設濃度）
    Map<DateTime, double> logConMap = {};
    for (var log in sortedLogs) {
      double? con = log.concentration;
      if (con == null) {
        // 根據水色給預設值
        String color = log.waterColor;
        if (color == '淡綠色') {
          con = 0.1;
        } else if (color == '綠色') {
          con = 0.5;
        } else if (color == '黃綠色') {
          con = 0.5;
        } else if (color == '其他') {
          con = 0.5;
        } else if (color == '黃色') {
          con = 0.8;
        } else if (color == '深綠色') {
          con = 0.9;
        }
      }
      if (con != null) {
        logConMap[DateTime(log.date.year, log.date.month, log.date.day)] = con;
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
    List<double> dailyCarbon = [];
    for (int i = 0; i < simCon.length; i++) {
      double dailyCO2 = widget.volume * 10; // 每日吸碳量 = 體積 * 10 g
      dailyCarbon.add(dailyCO2);
    }
    // 7. 計算累積吸碳量
    List<double> cumulativeCarbon = [];
    double sum = 0;
    for (int i = 0; i < dailyCarbon.length; i++) {
      sum += dailyCarbon[i];
      cumulativeCarbon.add(sum);
    }
    // 8. 聚合資料（日/月/年）
    List<FlSpot> spots = [];
    List<String> xLabels = [];
    if (widget.viewMode == 'day') {
      DateTime today = DateTime.now();
      DateTime firstDate = allDays.isNotEmpty ? allDays.first : today;
      int diffDays = today.difference(firstDate).inDays + 1;
      int showDays = diffDays < 30 ? diffDays : 30;
      List<DateTime> showDayList = List.generate(showDays, (i) => today.subtract(Duration(days: showDays - 1 - i)));
      List<double> showCumulative = [];
      double lastValue = 0;
      for (int i = 0; i < showDayList.length; i++) {
        DateTime d = showDayList[i];
        int idx = allDays.indexWhere((ad) => ad.year == d.year && ad.month == d.month && ad.day == d.day);
        if (idx != -1) {
          lastValue = cumulativeCarbon[idx];
        }
        showCumulative.add(lastValue);
      }
      int interval = 5;
      for (int i = 0; i < showDayList.length; i++) {
        if (i % interval == 0 || i == showDayList.length - 1) {
          xLabels.add(DateFormat('MM/dd').format(showDayList[i]));
        }
      }
      setState(() {
        _allDays = showDayList;
        _concentrationSim = simCon;
        _carbonSim = showCumulative;
        _totalCO2 = showCumulative.isNotEmpty ? showCumulative.last : 0;
      });
      if (widget.onTotalChanged != null) {
        widget.onTotalChanged!(_totalCO2);
      }
      return;
    } else if (widget.viewMode == 'month') {
      Map<String, double> monthMap = {};
      for (int i = 0; i < allDays.length; i++) {
        String ym = DateFormat('yyyy-MM').format(allDays[i]);
        monthMap[ym] = (monthMap[ym] ?? 0) + dailyCarbon[i];
      }
      int idx = 0;
      double cumulative = 0;
      for (var entry in monthMap.entries) {
        cumulative += entry.value;
        spots.add(FlSpot(idx.toDouble(), cumulative));
        xLabels.add(entry.key);
        idx++;
      }
    } else if (widget.viewMode == 'year') {
      Map<String, double> yearMap = {};
      for (int i = 0; i < allDays.length; i++) {
        String y = DateFormat('yyyy').format(allDays[i]);
        yearMap[y] = (yearMap[y] ?? 0) + dailyCarbon[i];
      }
      int idx = 0;
      double cumulative = 0;
      for (var entry in yearMap.entries) {
        cumulative += entry.value;
        spots.add(FlSpot(idx.toDouble(), cumulative));
        xLabels.add(entry.key);
        idx++;
      }
    }
    // 9. 更新狀態
    setState(() {
      _allDays = allDays;
      _concentrationSim = simCon;
      _carbonSim = spots.map((e) => e.y).toList(); // 只存圖表要用的累積值
      // 計算累積總量
      _totalCO2 = spots.isNotEmpty ? spots.last.y : 0;
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
      // 只顯示最近30天
      int showDays = 30;
      int totalDays = _carbonSim.length;
      int startIdx = totalDays > showDays ? totalDays - showDays : 0;
      int interval = (showDays > 6) ? 5 : 1;
      for (int i = startIdx; i < _carbonSim.length; i++) {
        if ((i - startIdx) % interval == 0 || i == _carbonSim.length - 1) {
          xLabels.add(DateFormat('MM/dd').format(_allDays[i]));
        }
      }
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
            const SizedBox(height: 4),
            Text('單位：公克(g) / 公斤(kg)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
                          String label;
                          if (value >= 1000) {
                            label = '${(value / 1000).toStringAsFixed(1)}kg';
                          } else {
                            label = '${value.toInt()}g';
                          }
                          return Text(label, style: const TextStyle(fontSize: 10));
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
            Text('目前累積吸碳量：${_totalCO2 >= 1000 ? '${(_totalCO2 / 1000).toStringAsFixed(2)} kg' : '${_totalCO2.toInt()} g'}', style: const TextStyle(color: Colors.teal)),
          ],
        ),
      ),
    );
  }
}