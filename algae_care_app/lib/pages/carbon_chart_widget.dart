import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/algae_log.dart';

class CarbonChartWidget extends StatelessWidget {
  final List<AlgaeLog> logs;
  final double algaeVolume;
  const CarbonChartWidget({super.key, required this.logs, required this.algaeVolume});

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Center(child: Text('尚無日誌資料，無法顯示吸碳量圖表'));
    }
    // 依日期排序
    final sortedLogs = List<AlgaeLog>.from(logs)..sort((a, b) => a.date.compareTo(b.date));
    // 以日期為key，計算每日累積吸碳量
    final Map<String, double> dailyCumulative = {};
    double total = 0;
    for (var log in sortedLogs) {
      // 單日吸碳量 = 體積 * 2g / 365
      final dayCO2 = algaeVolume * 2 / 365;
      total += dayCO2;
      final key = "${log.date.year}-${log.date.month}-${log.date.day}";
      dailyCumulative[key] = total;
    }
    final spots = <FlSpot>[];
    int i = 0;
    for (var entry in dailyCumulative.entries) {
      spots.add(FlSpot(i.toDouble(), entry.value));
      i++;
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
            const Text('累積吸碳量折線圖', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: spots.isNotEmpty ? spots.length - 1 : 0,
                  minY: 0,
                  maxY: spots.isNotEmpty ? (spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.1) : 1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
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
            Text('目前累積吸碳量：${spots.isNotEmpty ? spots.last.y.toStringAsFixed(2) : '0'} kg', style: const TextStyle(color: Colors.teal)),
          ],
        ),
      ),
    );
  }
} 