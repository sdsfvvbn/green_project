import 'package:flutter/material.dart';
import '../services/advice_services.dart' as services;
import '../models/algae_log.dart' as models; // 使用 models 別名
import 'package:google_generative_ai/google_generative_ai.dart';
import '../services/database_service.dart' as db;
import '../models/algae_profile.dart';
import 'carbon_chart_widget.dart';

class AdvicePage extends StatefulWidget {
  const AdvicePage({super.key});

  @override
  State<AdvicePage> createState() => _AdvicePageState();
}

class _AdvicePageState extends State<AdvicePage> {
  final services.AdviceService _adviceService = services.AdviceService();
  String _advice = '';
  double _carbonSequestration = 0.0;
  List<models.AlgaeLog> _allLogs = [];
  String? _selectedType;
  List<String> _allTypes = [];
  List<AlgaeProfile> _profiles = [];
  double _algaeVolume = 1.0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadProfiles();
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

  Future<void> _loadProfiles() async {
    final profiles = await db.DatabaseService.instance.getAllProfiles();
    setState(() {
      _profiles = profiles;
      // 計算藻類體積，取第一個profile的體積或預設值
      if (profiles.isNotEmpty) {
        _algaeVolume = profiles.first.waterVolume;
      }
    });
  }

  Future<void> _refreshAnalysis() async {
    final filteredLogs = _selectedType == null
        ? _allLogs
        : _allLogs.where((log) => (log.type ?? '未知品種') == _selectedType).toList();

    // 計算趨勢和異常值
    double avgTemp = 0;
    double avgPH = 0;
    if (filteredLogs.isNotEmpty) {
      avgTemp = filteredLogs.map((e) => e.temperature).reduce((a, b) => a + b) / filteredLogs.length;
      avgPH = filteredLogs.map((e) => e.pH).reduce((a, b) => a + b) / filteredLogs.length;
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'AIzaSyCVMw2sPOKUga72FlhBlaN4ekd4EFqvN-0',
    );

    String prompt = '''
以下是我的微藻養殖日誌資料，請分析並給出專業建議：

日誌記錄：
''';

    // 添加每日記錄
    for (var log in filteredLogs) {
      prompt += '''
日期: ${log.date}
- 溫度: ${log.temperature}°C
- pH值: ${log.pH}
- 水色: ${log.waterColor}
- 品種: ${log.type ?? '未知品種'}
- 光照時間: ${log.lightHours}小時
- 是否換水: ${log.isWaterChanged ? '是' : '否'}
- 是否施肥: ${log.isFertilized ? '是' : '否'}
- 備註: ${log.notes ?? '無'}
''';
    }

    // 添加統計資訊
    prompt += '''
統計資訊：
- 平均溫度: ${avgTemp.toStringAsFixed(1)}°C
- 平均pH值: ${avgPH.toStringAsFixed(1)}
- 記錄天數: ${filteredLogs.length}天

參考範圍：
- 適宜溫度：20-30°C
- 適宜pH值：6.5-8.5
- 建議光照：8-12小時/天

請根據以上資料分析：
1. 目前養殖狀況是否正常？
2. 有哪些需要注意或改善的地方？
3. 對於未來養殖有什麼建議？
4. 如果有異常數據，請指出並給出改善建議。
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final advice = response.text ?? '無法取得建議';
    // 計算吸碳量（根據 log.type 去 profile 找體積）
    double carbon = 0;
    for (var log in filteredLogs) {
      final profile = _profiles.firstWhere(
        (p) => p.species == (log.type ?? ''),
        orElse: () => AlgaeProfile(
          id: null,
          species: log.type ?? '',
          name: null,
          startDate: DateTime(2020, 1, 1),
          length: 1.0,
          width: 1.0,
          waterSource: '',
          lightType: '',
          waterChangeFrequency: 7,
          waterVolume: 1.0,
          fertilizerType: '',
        ),
      );
      carbon += profile.waterVolume * 2 / 365;
    }
        setState(() {
      _advice = advice;
      _carbonSequestration = carbon;
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
                        _advice.replaceAll(RegExp(r'[*#`>-]'), ''),
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
              // 吸碳量折線圖
              _allLogs.isEmpty
                ? const Center(child: Text('尚無日誌資料，無法顯示吸碳量圖表'))
                : CarbonChartWidget(
                    logs: _allLogs,
                    algaeVolume: _algaeVolume,
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