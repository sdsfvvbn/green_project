import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GrowthChartWidget extends StatefulWidget {
  final List<double> data;
  const GrowthChartWidget({super.key, required this.data});

  @override
  State<GrowthChartWidget> createState() => _GrowthChartWidgetState();
}

class _GrowthChartWidgetState extends State<GrowthChartWidget> {
  String? selectedSpecies;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          value: selectedSpecies,
          items: ['綠藻', '小球藻', '藍綠藻', '其他'].map((e) => DropdownMenuItem(
            value: e,
            child: Text(e),
          )).toList(),
          onChanged: (value) {
            setState(() {
              selectedSpecies = value;
              // TODO：這裡可以加入依品種更新 chart 資料的邏輯
            });
          },
        ),
        const SizedBox(height: 16),
        Flexible(
          child: SizedBox(
            height: 260,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: true),
                minX: 0,
                maxX: widget.data.isNotEmpty ? widget.data.length - 1 : 0,
                minY: 0,
                maxY: widget.data.isNotEmpty ? (widget.data.reduce((a, b) => a > b ? a : b) * 1.1) : 1,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < widget.data.length; i++)
                        FlSpot(i.toDouble(), widget.data[i]),
                    ],
                    isCurved: true,
                    barWidth: 3,
                    color: Colors.green,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}