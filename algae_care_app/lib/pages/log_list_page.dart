import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/algae_log.dart';
import '../services/database_service.dart';
import 'log_form_page.dart';
import 'dart:io';
// ignore: uri_does_not_exist
import 'dart:html' as html; // 只會在 web 端有效
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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
      isWaterChanged: true,
      nextWaterChangeDate: DateTime.now().add(const Duration(days: 6)), // 預計6天後換水
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
    // 新增 2025/5/15 假資料
    AlgaeLog(
      id: 3,
      date: DateTime(2025, 5, 15),
      waterColor: '藍綠',
      temperature: 23.5,
      pH: 8.1,
      lightHours: 9,
      photoPath: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
      notes: '這是五月的測試日誌，有照片',
      isWaterChanged: true,
      nextWaterChangeDate: DateTime(2025, 5, 22), // 預計一週後換水
    ),
  ];

  late Future<List<AlgaeLog>> _logsFuture;
  String? _customType;
  String? _customWaterColor;
  bool _showCalendar = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    if (!kIsWeb) {
      _refreshLogs();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        appBar: AppBar(
          title: const Text('日誌紀錄'),
          backgroundColor: Colors.blue[700],
          actions: [
            IconButton(
              icon: Icon(_showCalendar ? Icons.view_list : Icons.calendar_month),
              onPressed: () => setState(() => _showCalendar = !_showCalendar),
            ),
          ],
        ),
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
            : (_showCalendar
                ? _buildCalendar(_mockLogs)
                : _buildGroupedList(_mockLogs)),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _navigateToForm(),
          child: const Icon(Icons.add),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Row(
          children: [
            const Text('日誌紀錄'),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(_showCalendar ? Icons.view_list : Icons.calendar_month),
              onPressed: () => setState(() => _showCalendar = !_showCalendar),
              tooltip: _showCalendar ? '切換列表' : '切換日曆',
            ),
          ],
        ),
      ),
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
            return PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildGroupedList(logs),
                _buildCalendar(logs),
              ],
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

  Widget _buildGroupedList(List<AlgaeLog> logs) {
    // 依照年/月分組
    final Map<String, List<AlgaeLog>> grouped = {};
    for (final log in logs) {
      final key = '${log.date.year}-${log.date.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(log);
    }
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // 新的月份在上面
    return ListView.builder(
      itemCount: sortedKeys.length,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemBuilder: (context, idx) {
        final key = sortedKeys[idx];
        final ym = key.split('-');
        final year = ym[0];
        final month = ym[1];
        final monthLogs = grouped[key]!..sort((a, b) => b.date.compareTo(a.date)); // 月內依日期新到舊
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text('$year年${int.parse(month)}月', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
            ),
            ...monthLogs.map((log) {
              final date = log.date;
              final weekDay = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'][date.weekday % 7];
              final day = date.day.toString();
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // 文字內容
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('水色：${log.waterColor}'),
                                  const SizedBox(width: 12),
                                  Text('種類：${log.type ?? ''}'),
                                  const SizedBox(width: 12),
                                  Text('溫度：${log.temperature}°C'),
                                  const SizedBox(width: 12),
                                  Text('pH：${log.pH}'),
                                  const SizedBox(width: 12),
                                  Text('光照：${log.lightHours}'),
                                  if (log.isWaterChanged)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('換水', style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ),
                                ],
                              ),
                              if (log.notes != null && log.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text('描述：${log.notes!}', style: const TextStyle(color: Colors.grey)),
                                ),
                            ],
                          ),
                        ),
                        // 圖片在最右側
                        if (log.photoPath != null && log.photoPath!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: SizedBox(
                              width: 60,
                              height: 60,
                              child: log.photoPath!.startsWith('http')
                                  ? Image.network(log.photoPath!, fit: BoxFit.cover)
                                  : Image.file(File(log.photoPath!), fit: BoxFit.cover),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildCalendar(List<AlgaeLog> logs) {
    // 依日期分組
    final Map<DateTime, List<AlgaeLog>> logMap = {};
    final Map<DateTime, List<AlgaeLog>> scheduledWaterChanges = {};
    
    for (final log in logs) {
      final key = DateTime(log.date.year, log.date.month, log.date.day);
      logMap.putIfAbsent(key, () => []).add(log);
      
      // 收集預計換水日期
      if (log.nextWaterChangeDate != null) {
        final scheduledKey = DateTime(
          log.nextWaterChangeDate!.year, 
          log.nextWaterChangeDate!.month, 
          log.nextWaterChangeDate!.day
        );
        scheduledWaterChanges.putIfAbsent(scheduledKey, () => []).add(log);
      }
    }
    
    return TableCalendar<AlgaeLog>(
      firstDay: DateTime(2020, 1, 1),
      lastDay: DateTime(2100, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      eventLoader: (day) => logMap[DateTime(day.year, day.month, day.day)] ?? [],
      availableCalendarFormats: const {
        CalendarFormat.month: '月',
      },
      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDay = selected;
          _focusedDay = focused;
        });
        final logsForDay = logMap[DateTime(selected.year, selected.month, selected.day)] ?? [];
        final scheduledForDay = scheduledWaterChanges[DateTime(selected.year, selected.month, selected.day)] ?? [];
        
        if (logsForDay.isNotEmpty || scheduledForDay.isNotEmpty) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('${selected.year}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}'),
              content: SizedBox(
                width: 320,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (logsForDay.isNotEmpty) ...[
                        const Text('日誌記錄:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...logsForDay.map((log) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (log.photoPath != null && log.photoPath!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: log.photoPath!.startsWith('http')
                                    ? Image.network(log.photoPath!, height: 120)
                                    : Image.file(File(log.photoPath!), height: 120),
                                ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  Chip(label: Text('水色: ${log.waterColor}')),
                                  Chip(label: Text('種類: ${log.type ?? ''}')),
                                  if (log.isWaterChanged) Chip(label: const Text('換水'), backgroundColor: Colors.blue[100]),
                                  Chip(label: Text('pH: ${log.pH}')),
                                  Chip(label: Text('溫度: ${log.temperature}°C')),
                                  Chip(label: Text('光照: ${log.lightHours}')),
                                ],
                              ),
                              if (log.notes != null && log.notes!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text('描述：${log.notes!}', style: const TextStyle(color: Colors.grey)),
                                ),
                            ],
                          ),
                        )).toList(),
                      ],
                      if (scheduledForDay.isNotEmpty) ...[
                        if (logsForDay.isNotEmpty) const SizedBox(height: 16),
                        const Text('預計換水:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        const SizedBox(height: 8),
                        ...scheduledForDay.map((log) => Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.schedule, color: Colors.orange[600], size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '預計換水日期',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('關閉'),
                ),
              ],
            ),
          );
        }
      },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          final logsForDay = logMap[DateTime(day.year, day.month, day.day)] ?? [];
          final scheduledForDay = scheduledWaterChanges[DateTime(day.year, day.month, day.day)] ?? [];
          final hasLog = logsForDay.isNotEmpty;
          final hasWaterChange = hasLog && logsForDay.any((log) => log.isWaterChanged);
          final hasScheduledWaterChange = scheduledForDay.isNotEmpty;
          
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: hasLog ? Colors.green[100] : (hasScheduledWaterChange ? Colors.orange[50] : null),
                  borderRadius: BorderRadius.zero,
                ),
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(
                      color: hasLog ? Colors.green[900] : (hasScheduledWaterChange ? Colors.orange[700] : Colors.grey[600]),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (hasWaterChange)
                Positioned.fill(
                  child: Center(
                    child: Icon(
                      Icons.water_drop, 
                      color: Colors.blue.withOpacity(0.4), 
                      size: 28,
                    ),
                  ),
                ),
              if (hasScheduledWaterChange && !hasWaterChange)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Icon(
                    Icons.schedule, 
                    color: Colors.orange[600], 
                    size: 12,
                  ),
                ),
            ],
          );
        },
        todayBuilder: (context, day, focusedDay) {
          final logsForDay = logMap[DateTime(day.year, day.month, day.day)] ?? [];
          final scheduledForDay = scheduledWaterChanges[DateTime(day.year, day.month, day.day)] ?? [];
          final hasLog = logsForDay.isNotEmpty;
          final hasWaterChange = hasLog && logsForDay.any((log) => log.isWaterChanged);
          final hasScheduledWaterChange = scheduledForDay.isNotEmpty;
          
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: hasLog ? Colors.green[100] : (hasScheduledWaterChange ? Colors.orange[50] : Colors.orange[50]),
                  borderRadius: BorderRadius.zero,
                ),
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: Text(
                    day.day.toString(),
                    style: TextStyle(
                      color: hasLog ? Colors.green[900] : (hasScheduledWaterChange ? Colors.orange[700] : Colors.orange),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (hasWaterChange)
                Positioned.fill(
                  child: Center(
                    child: Icon(
                      Icons.water_drop, 
                      color: Colors.blue.withOpacity(0.4), 
                      size: 28,
                    ),
                  ),
                ),
              if (hasScheduledWaterChange && !hasWaterChange)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Icon(
                    Icons.schedule, 
                    color: Colors.orange[600], 
                    size: 12,
                  ),
                ),
            ],
          );
        },
      ),
      calendarStyle: const CalendarStyle(
        markerDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
      ),
    );
  }

  Widget _miniTag(String text, Color? color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color ?? Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: const TextStyle(fontSize: 9)),
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
  String? _waterColor;
  late String _light;
  late String _temperature;
  double? _phValue;
  late String _notes;
  String? _photoDataUrl;
  String? _type;
  bool _isWaterChanged = false;
  String? _customType;
  String? _customWaterColor;
  DateTime? _nextWaterChangeDate;

  @override
  void initState() {
    super.initState();
    final log = widget.log;
    _selectedDate = log?.date ?? DateTime.now();
    _waterColor = log?.waterColor;
    _light = log?.lightHours.toString() ?? '';
    _temperature = log?.temperature.toString() ?? '';
    _phValue = log?.pH;
    _notes = log?.notes ?? '';
    _photoDataUrl = log?.photoPath;
    _type = log?.type;
    _isWaterChanged = log?.isWaterChanged ?? false;
    _nextWaterChangeDate = log?.nextWaterChangeDate;
  }

  Future<void> _pickWebImage() async {
    // ignore: undefined_prefixed_name
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();
    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      if (file != null) {
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((event) {
          setState(() {
            _photoDataUrl = reader.result as String;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(widget.log == null ? '新增日誌' : '編輯日誌'),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
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
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: '種類'),
                  items: const [
                    DropdownMenuItem(value: '綠藻', child: Text('綠藻')),
                    DropdownMenuItem(value: '小球藻', child: Text('小球藻')),
                    DropdownMenuItem(value: '藍綠藻', child: Text('藍綠藻')),
                    DropdownMenuItem(value: '其他', child: Text('其他')),
                  ],
                  onChanged: (val) => setState(() {
                    _type = val;
                    if (val != '其他') _customType = null;
                  }),
                  onSaved: (val) => _type = val,
                ),
                if (_type == '其他')
                  TextFormField(
                    decoration: const InputDecoration(labelText: '請輸入種類'),
                    onChanged: (val) => _customType = val,
                    onSaved: (val) => _customType = val,
                  ),
                DropdownButtonFormField<String>(
                  value: _waterColor,
                  decoration: const InputDecoration(labelText: '水色'),
                  items: const [
                    DropdownMenuItem(value: '淡綠色', child: Text('淡綠色')),
                    DropdownMenuItem(value: '綠色', child: Text('綠色')),
                    DropdownMenuItem(value: '黃綠色', child: Text('黃綠色')),
                    DropdownMenuItem(value: '黃色', child: Text('黃色')),
                    DropdownMenuItem(value: '藍綠色', child: Text('藍綠色')),
                    DropdownMenuItem(value: '其他', child: Text('其他')),
                  ],
                  onChanged: (val) => setState(() {
                    _waterColor = val;
                    if (val != '其他') _customWaterColor = null;
                  }),
                  onSaved: (val) => _waterColor = val ?? '',
                ),
                if (_waterColor == '其他')
                  TextFormField(
                    decoration: const InputDecoration(labelText: '請輸入水色'),
                    onChanged: (val) => _customWaterColor = val,
                    onSaved: (val) => _customWaterColor = val,
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
                  initialValue: _phValue != null ? _phValue.toString() : '',
                  decoration: const InputDecoration(labelText: 'pH'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setState(() {
                      _phValue = double.tryParse(val);
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text('換水:', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Checkbox(
                      value: _isWaterChanged,
                      onChanged: (val) async {
                        setState(() => _isWaterChanged = val ?? false);
                        // 當勾選換水時，自動跳出預計下次換水日期選擇
                        if (val == true) {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _nextWaterChangeDate ?? DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              _nextWaterChangeDate = picked;
                            });
                          }
                        } else {
                          // 當取消勾選換水時，清除預計下次換水日期
                          setState(() {
                            _nextWaterChangeDate = null;
                          });
                        }
                      },
                    ),
                  ],
                ),
                
                // 顯示已選擇的預計下次換水日期
                if (_isWaterChanged && _nextWaterChangeDate != null)
                  Container(
                    margin: const EdgeInsets.only(left: 16, top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.water_drop, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '預計下次換水日期: ${_nextWaterChangeDate!.toLocal().toString().split(' ')[0]}',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _nextWaterChangeDate!,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                _nextWaterChangeDate = picked;
                              });
                            }
                          },
                          tooltip: '修改日期',
                        ),
                      ],
                    ),
                  ),
                TextFormField(
                  initialValue: _notes,
                  decoration: const InputDecoration(labelText: '微藻描述'),
                  maxLines: 2,
                  onSaved: (val) => _notes = val ?? '',
                ),
                const SizedBox(height: 16),
                _photoDataUrl == null
                    ? TextButton.icon(
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('上傳照片'),
                        onPressed: _pickWebImage,
                      )
                    : Column(
                        children: [
                          Image.network(_photoDataUrl!, height: 120),
                          TextButton(
                            onPressed: _pickWebImage,
                            child: const Text('更換照片'),
                          ),
                        ],
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
                waterColor: _waterColor == '其他' ? _customWaterColor ?? '' : _waterColor ?? '',
                temperature: double.tryParse(_temperature) ?? 0,
                pH: _phValue ?? 0,
                lightHours: int.tryParse(_light) ?? 0,
                photoPath: _photoDataUrl,
                notes: _notes,
                type: _type == '其他' ? _customType : _type,
                isWaterChanged: _isWaterChanged,
                nextWaterChangeDate: _nextWaterChangeDate,
              ),
            );
          },
          child: const Text('儲存'),
        ),
      ],
    );
  }
} 
