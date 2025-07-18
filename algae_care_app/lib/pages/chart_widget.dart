import 'package:flutter/material.dart';

class GrowthChartWidget extends StatelessWidget {
  final List<double> data;

  const GrowthChartWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          value: selectedSpecies,
          items: ['綠藻', '小球藻', '不知道是什麼藻類'].map((e) => DropdownMenuItem(
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
        Text(
          '選擇的品種：${selectedSpecies ?? "未選擇"}',
          style: const TextStyle(fontSize: 16),
        ),
        // TODO：加入 chart 視覺化呈現
      ],
    );
  }
}
