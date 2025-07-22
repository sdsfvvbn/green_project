import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/algae_log.dart';
import '../models/algae_profile.dart';
import '../services/database_service.dart';

class CarbonChartWidget extends StatefulWidget {
  final List<AlgaeLog> logs;
  final ValueChanged<double>? onTotalChanged;
  const CarbonChartWidget({super.key, required this.logs, this.onTotalChanged});

  @override
  State<CarbonChartWidget> createState() => _CarbonChartWidgetState();
}

class _CarbonChartWidgetState extends State<CarbonChartWidget> {
  List<AlgaeProfile> _profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profiles = await DatabaseService.instance.getAllProfiles();
    setState(() {
      _profiles = profiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedLogs = List<AlgaeLog>.from(widget.logs)..sort((a, b) => a.date.compareTo(b.date));
    if (sortedLogs.isEmpty) {
      return const Center(child: Text('尚無日誌資料，無法顯示吸碳量圖表'));
    }
    final firstDate = DateTime(sortedLogs.first.date.year, sortedLogs.first.date.month, sortedLogs.first.date.day);
    final now = DateTime.now();
    final days = now.difference(firstDate).inDays + 1;
    final List<DateTime> allDays = List.generate(days, (i) => firstDate.add(Duration(days: i)));
    double total = 0.0;
    final spots = <FlSpot>[];
    int logIdx = 0;
    for (int i = 0; i < allDays.length; i++) {
      final day = allDays[i];
      while (logIdx + 1 < sortedLogs.length && !sortedLogs[logIdx + 1].date.isAfter(day)) {
        logIdx++;
      }
      final log = sortedLogs[logIdx];
      final dayCO2 = (log.waterVolume ?? 1.0) * 2 / 365;
      total += dayCO2;
      spots.add(FlSpot(i.toDouble(), total));
    }
    if (widget.onTotalChanged != null && spots.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onTotalChanged!(spots.last.y);
      });
    }
    final maxY = spots.isNotEmpty ? (spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.1) : 1.0;
    final interval = _calculateInterval(maxY);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('累積吸碳量折線圖', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.shade300,
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: interval,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(2),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < days) {
                            final date = firstDate.add(Duration(days: value.toInt()));
                            final day = date.day;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                day.toString(),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  minX: 0,
                  maxX: spots.isNotEmpty ? spots.length - 1 : 0,
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.white,
                            strokeWidth: 2,
                            strokeColor: Colors.green,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '目前累積吸碳量：${spots.isNotEmpty ? spots.last.y.toStringAsFixed(2) : '0'} kg', 
              style: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateInterval(double maxValue) {
    if (maxValue <= 0) return 0.1;
    
    // 根據最大值選擇合適的間隔
    if (maxValue <= 0.1) return 0.02;
    if (maxValue <= 0.5) return 0.1;
    if (maxValue <= 1) return 0.2;
    if (maxValue <= 5) return 1;
    if (maxValue <= 10) return 2;
    return (maxValue / 5).roundToDouble();
  }
} 