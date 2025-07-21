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
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
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
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
            ),
          ),
        ),
      ],
    );
  }
}