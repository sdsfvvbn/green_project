import 'package:flutter/material.dart';
import '../services/advice_services.dart' as services;
import '../pages/chart_widget.dart' as chart;
import '../models/algae_log.dart' as models; // 使用 models 別名
import 'package:google_generative_ai/google_generative_ai.dart';
import '../services/database_service.dart' as db;

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
  List<models.AlgaeLog> _allLogs = [];
  String? _selectedType;
  List<String> _allTypes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 從資料庫取得所有日誌
    final logs = await db.DatabaseService.instance.getAllLogs();
    print('取得日誌資料: $logs'); // 這一行會把日誌資料印出來
    // 取得所有品種（type）
    final types = logs.map((e) => e.type ?? '未知品種').toSet().toList();
    setState(() {
      _allLogs = logs;
      _allTypes = types;
      _selectedType = types.isNotEmpty ? types.first : null;
    });
    _refreshAnalysis();
  }

  Future<void> _refreshAnalysis() async {
    // 根據選擇的品種過濾資料
    final filteredLogs = _selectedType == null
        ? _allLogs
        : _allLogs.where((log) => (log.type ?? '未知品種') == _selectedType).toList();
    // 直接呼叫 Gemini AI
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'AIzaSyCVMw2sPOKUga72FlhBlaN4ekd4EFqvN-0',
    );
    String prompt = '以下是我的海藻日誌資料：\n';
    for (var log in filteredLogs) {
      prompt += '日期:  {log.date}, 溫度:  {log.temperature}, 水色:  {log.waterColor}, 品種:  {log.type}\n';
    }
    prompt += '請根據這些資料給我一個養殖建議。';
    final response = await model.generateContent([Content.text(prompt)]);
    final advice = response.text ?? '無法取得建議';
    final carbon = await _adviceService.calculateCarbonSequestration(filteredLogs);
    final growth = await _adviceService.getGrowthData(filteredLogs);
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
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 品種選擇下拉選單
              if (_allTypes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: DropdownButton<String>(
                    value: _selectedType,
                    hint: const Text('請選擇藻類品種'),
                    items: _allTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                      _refreshAnalysis();
                    },
                  ),
                ),
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
              // 新增：自訂填空格與送出按鈕
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _CustomAdviceInput(
                    onSubmit: (species, environment, problem) async {
                      // 新增：組合日誌資料
                      String prompt = '以下是我的海藻日誌資料：\n';
                      for (var log in _allLogs) {
                        prompt += '日期: ${log.date}, 溫度: ${log.temperature}, 水色: ${log.waterColor}, 品種: ${log.type}\n';
                      }
                      prompt += '\n另外，這是我的補充資料：\n';
                      prompt += '品種: $species\n';
                      prompt += '養殖環境: $environment\n';
                      prompt += '遇到的問題: $problem\n';
                      prompt += '請根據所有資料給我一個養殖建議。';
                      final model = GenerativeModel(
                        model: 'gemini-1.5-flash',
                        apiKey: 'AIzaSyCVMw2sPOKUga72FlhBlaN4ekd4EFqvN-0',
                      );
                      setState(() {
                        _advice = 'AI 正在分析您的補充資料...';
                      });
                      final response = await model.generateContent([Content.text(prompt)]);
                      setState(() {
                        _advice = response.text ?? '無法取得建議';
                      });
                    },
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
                        '成長曲線',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.green[800],
                                fontWeight: FontWeight.bold,
                              ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200, // 你可以根據需求調整高度
                        child: chart.GrowthChartWidget(data: _growthData),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 新增：自訂填空格元件
class _CustomAdviceInput extends StatefulWidget {
  final Future<void> Function(String species, String environment, String problem) onSubmit;
  const _CustomAdviceInput({required this.onSubmit});

  @override
  State<_CustomAdviceInput> createState() => _CustomAdviceInputState();
}

class _CustomAdviceInputState extends State<_CustomAdviceInput> {
  String? _species;
  final TextEditingController _environmentController = TextEditingController();
  final TextEditingController _problemController = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButton<String>(
          value: _species,
          hint: const Text('請選擇品種'),
          items: ['綠藻', '小球藻', '藍綠色', '其他'].map((e) => DropdownMenuItem(
            value: e,
            child: Text(e),
          )).toList(),
          onChanged: (value) {
            setState(() {
              _species = value;
            });
          },
        ),
        TextField(
          controller: _environmentController,
          decoration: const InputDecoration(labelText: '養殖環境（例如水溫、鹽度等）'),
        ),
        TextField(
          controller: _problemController,
          decoration: const InputDecoration(labelText: '遇到的問題（例如生長不良、病蟲害等）'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading
                ? null
                : () async {
                    setState(() => _loading = true);
                    await widget.onSubmit(
                      _species ?? '',
                      _environmentController.text,
                      _problemController.text,
                    );
                    setState(() => _loading = false);
                  },
            child: _loading ? const CircularProgressIndicator() : const Text('送出'),
          ),
        ),
      ],
    );
  }
}