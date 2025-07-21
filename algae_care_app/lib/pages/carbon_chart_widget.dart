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

    // 計算 Y 軸的最大值和刻度間隔
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
                          if (value.toInt() >= 0 && value.toInt() < dailyCumulative.length) {
                            final date = dailyCumulative.keys.elementAt(value.toInt());
                            final day = date.split('-').last;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                day,
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