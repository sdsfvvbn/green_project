import 'package:flutter/material.dart';

class GrowthChartWidget extends StatelessWidget {
  final List<double> data;
  const GrowthChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('成長曲線資料點數：${data.length}'),
    );
  }
}