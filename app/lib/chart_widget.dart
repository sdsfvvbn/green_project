import 'package:flutter/material.dart';

class ChartWidget extends StatelessWidget {
  final List<double> data;

  const ChartWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('成長曲線圖表待實現'),
    );
  }
}