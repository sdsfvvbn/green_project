import 'package:flutter/material.dart';
import '../services/advice_services.dart' as services;
import '../pages/chart_widget.dart' as chart;
import '../models/algae_log.dart' as models; // 使用 models 別名

class AdvicePage extends StatefulWidget {
  const AdvicePage({super.key});

  @override
  State<AdvicePage> createState() => _AdvicePageState();
}

class _AdvicePageState extends State<AdvicePage> {
  final services.AdviceService _adviceService = services.AdviceService();
  String _advice = '';
  double _carbonSequestration = 0.0;
  List<double> _growthData = [];

@override
 void initState() {
   super.initState();
   _loadData();
 }
  void _loadData() async {
    // 使用 models.AlgaeLog 明確指定來源，並提供所有必要欄位
    List<models.AlgaeLog> logs = [
      models.AlgaeLog(
        date: DateTime.now(),
        temperature: 25.0,
        waterColor: 'green', // 必須提供
        pH: 7.0,            // 必須提供
        lightHours: 12,      // 必須提供
      ),
    ];

    final advice = await _adviceService.getAdviceFromGemini(logs);
    final carbon = await _adviceService.calculateCarbonSequestration(logs);
    final growth = await _adviceService.getGrowthData(logs);

    setState(() {
      _advice = advice;
      _carbonSequestration = carbon;
      _growthData = growth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('成長建議與數據'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI 建議',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _advice.isEmpty ? '正在生成建議...' : _advice,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '吸碳量',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.green[800],
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_carbonSequestration.toStringAsFixed(2)} 公斤 CO₂/年',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '成長曲線',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.green[800],
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: chart.GrowthChartWidget(data: _growthData),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}