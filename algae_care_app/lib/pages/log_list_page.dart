import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/algae_log.dart';
import '../services/database_service.dart';
import 'log_form_page.dart';

class LogListPage extends StatefulWidget {
  const LogListPage({super.key});

  @override
  State<LogListPage> createState() => _LogListPageState();
}

class _LogListPageState extends State<LogListPage> {
  // web 端 mock data
  List<AlgaeLog> _mockLogs = [
    AlgaeLog(
      id: 1,
      date: DateTime.now().subtract(const Duration(days: 1)),
      waterColor: '綠色',
      temperature: 25.0,
      pH: 7.2,
      lightHours: 8,
      photoPath: null,
      notes: '測試日誌',
    ),
    AlgaeLog(
      id: 2,
      date: DateTime.now(),
      waterColor: '淡綠',
      temperature: 26.5,
      pH: 7.0,
      lightHours: 10,
      photoPath: null,
      notes: '今日狀態良好',
    ),
  ];

  late Future<List<AlgaeLog>> _logsFuture;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _refreshLogs();
    }
  }

  void _refreshLogs() {
    setState(() {
      _logsFuture = DatabaseService.instance.getAllLogs();
    });
  }

  void _navigateToForm({int? logId}) async {
    if (kIsWeb) {
      // web 端用 dialog 模擬新增/編輯
      final result = await showDialog<AlgaeLog>(
        context: context,
        builder: (context) => _MockLogForm(
          log: logId != null ? _mockLogs.firstWhere((l) => l.id == logId) : null,
        ),
      );
      if (result != null) {
        setState(() {
          if (logId != null) {
            final idx = _mockLogs.indexWhere((l) => l.id == logId);
            _mockLogs[idx] = result;
          } else {
            _mockLogs.add(result.copyWith(id: _mockLogs.length + 1));
          }
        });
      }
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LogFormPage(logId: logId),
        ),
      );
      _refreshLogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('日誌紀錄'), backgroundColor: Colors.blue[700]),
        body: _mockLogs.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('沒有歷史紀錄\n開始記錄養殖日記吧！', textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('開始記錄'),
                      onPressed: () => _navigateToForm(),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: _mockLogs.length,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemBuilder: (context, index) {
                  final log = _mockLogs[index];
                  final date = log.date;
                  final weekDay = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'][date.weekday % 7];
                  final day = date.day.toString();
                  final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _navigateToForm(logId: log.id),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 左側大日期
                            Container(
                              width: 60,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(weekDay, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(day, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 32)),
                                  Text(time, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            // 右側內容
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('水色：${log.waterColor}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 12),
                                      Text('溫度：${log.temperature}°C'),
                                      const SizedBox(width: 12),
                                      Text('pH：${log.pH}'),
                                    ],
                                  ),
                                  if (log.notes != null && log.notes!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(log.notes!, style: const TextStyle(color: Colors.grey)),
                                    ),
                                  if (log.photoPath != null && log.photoPath!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Image.network(log.photoPath!, height: 60, fit: BoxFit.cover),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToForm(),
          child: const Icon(Icons.add),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('日誌紀錄'), backgroundColor: Colors.blue[700]),
      body: FutureBuilder<List<AlgaeLog>>(
        future: _logsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('發生錯誤: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('沒有歷史紀錄\n開始記錄養殖日記吧！', textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('開始記錄'),
                    onPressed: () => _navigateToForm(),
                  ),
                ],
              ),
            );
          } else {
            final logs = snapshot.data!;
            return ListView.builder(
              itemCount: logs.length,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemBuilder: (context, index) {
                final log = logs[index];
                final date = log.date;
                final weekDay = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'][date.weekday % 7];
                final day = date.day.toString();
                final time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _navigateToForm(logId: log.id),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 左側大日期
                          Container(
                            width: 60,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(weekDay, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(day, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 32)),
                                Text(time, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // 右側內容
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('水色：${log.waterColor}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 12),
                                    Text('溫度：${log.temperature}°C'),
                                    const SizedBox(width: 12),
                                    Text('pH：${log.pH}'),
                                  ],
                                ),
                                if (log.notes != null && log.notes!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(log.notes!, style: const TextStyle(color: Colors.grey)),
                                  ),
                                if (log.photoPath != null && log.photoPath!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Image.network(log.photoPath!, height: 60, fit: BoxFit.cover),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// web 端 mock 日誌表單 dialog
class _MockLogForm extends StatefulWidget {
  final AlgaeLog? log;
  const _MockLogForm({this.log});

  @override
  State<_MockLogForm> createState() => _MockLogFormState();
}

class _MockLogFormState extends State<_MockLogForm> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _selectedDate;
  late String _waterColor;
  late String _light;
  late String _temperature;
  late String _ph;
  late String _notes;

  @override
  void initState() {
    super.initState();
    final log = widget.log;
    _selectedDate = log?.date ?? DateTime.now();
    _waterColor = log?.waterColor ?? '';
    _light = log?.lightHours.toString() ?? '';
    _temperature = log?.temperature.toString() ?? '';
    _ph = log?.pH.toString() ?? '';
    _notes = log?.notes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.log == null ? '新增日誌' : '編輯日誌'),
      content: SizedBox(
        width: 300,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text('日期: \\${_selectedDate.toLocal().toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
                TextFormField(
                  initialValue: _waterColor,
                  decoration: const InputDecoration(labelText: '水色'),
                  onSaved: (val) => _waterColor = val ?? '',
                ),
                TextFormField(
                  initialValue: _light,
                  decoration: const InputDecoration(labelText: '光照(小時)'),
                  keyboardType: TextInputType.number,
                  onSaved: (val) => _light = val ?? '',
                ),
                TextFormField(
                  initialValue: _temperature,
                  decoration: const InputDecoration(labelText: '溫度 (°C)'),
                  keyboardType: TextInputType.number,
                  onSaved: (val) => _temperature = val ?? '',
                ),
                TextFormField(
                  initialValue: _ph,
                  decoration: const InputDecoration(labelText: 'pH'),
                  keyboardType: TextInputType.number,
                  onSaved: (val) => _ph = val ?? '',
                ),
                TextFormField(
                  initialValue: _notes,
                  decoration: const InputDecoration(labelText: '微藻描述'),
                  maxLines: 2,
                  onSaved: (val) => _notes = val ?? '',
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            _formKey.currentState!.save();
            Navigator.pop(
              context,
              AlgaeLog(
                id: widget.log?.id,
                date: _selectedDate,
                waterColor: _waterColor,
                temperature: double.tryParse(_temperature) ?? 0,
                pH: double.tryParse(_ph) ?? 0,
                lightHours: int.tryParse(_light) ?? 0,
                photoPath: null,
                notes: _notes,
              ),
            );
          },
          child: const Text('儲存'),
        ),
      ],
    );
  }
} 
