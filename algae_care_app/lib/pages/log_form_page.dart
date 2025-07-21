import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:algae_care_app/models/algae_log.dart';
import 'package:algae_care_app/services/database_service.dart';
// import 'package:algae_care_app/services/notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';

class LogFormPage extends StatefulWidget {
  final int? logId; // 若有 logId 則為編輯，否則為新增
  const LogFormPage({super.key, this.logId});

  @override
  State<LogFormPage> createState() => _LogFormPageState();
}

class _LogFormPageState extends State<LogFormPage> {
  final _formKey = GlobalKey<FormState>();
  // 1. 預設日期為今天
  DateTime? _selectedDate = DateTime.now();
  String? _waterColor;
  String? _light;
  String? _temperature;
  double? _phValue;
  String? _notes;
  File? _image;
  String? _type;
  String? _customType;
  bool _isWaterChanged = false;
  bool _isFertilized = false;
  String? _customWaterColor;
  DateTime? _nextWaterChangeDate;
  DateTime? _nextFertilizeDate;
  List<File> _images = []; // 新增：多圖
  List<String> _actions = []; // 新增：多種操作標記

  // 1. 新增光照、溫度、pH的狀態變數
  int _lightHour = 0;
  int _lightMinute = 0;
  int _temperatureValue = 25;
  double _phSliderValue = 7.0;

  @override
  void initState() {
    super.initState();
    if (widget.logId != null) {
      _loadLogData(widget.logId!);
    }
    _phValue = null;
    _type = null;
    _isWaterChanged = false;
  }

  Future<void> _loadLogData(int logId) async {
    final log = await DatabaseService.instance.getLog(logId);
    if (log != null) {
      setState(() {
        _selectedDate = log.date;
        _type = log.type;
        _customType = null;
        _waterColor = log.waterColor;
        _customWaterColor = null;
        _light = log.lightHours.toString();
        _temperature = log.temperature.toString();
        _phValue = log.pH;
        _notes = log.notes;
        _isWaterChanged = log.isWaterChanged;
        _isFertilized = log.isFertilized;
        _nextWaterChangeDate = log.nextWaterChangeDate;
        _nextFertilizeDate = log.nextFertilizeDate;
        if (log.photoPath != null && log.photoPath!.isNotEmpty) {
          _image = File(log.photoPath!);
        }
        // 2. _loadLogData 時自動拆解小時/分鐘
        _lightHour = log.lightHours.floor();
        _lightMinute = ((log.lightHours - _lightHour) * 60).round();
        // 新增：溫度
        _temperatureValue = log.temperature.round();
        // 新增：pH
        _phSliderValue = log.pH;
      });
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('zh', 'TW'), // 設定為繁體中文
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickNextWaterChangeDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
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
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '日誌紀錄',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 6,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text(
                  '日期：${_selectedDate != null ? _selectedDate!.year.toString().padLeft(4, '0') + '-' + _selectedDate!.month.toString().padLeft(2, '0') + '-' + _selectedDate!.day.toString().padLeft(2, '0') : ''}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(context),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: '種類',
                  prefixIcon: Icon(Icons.grass),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                ),
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
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: '請輸入種類',
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      border: UnderlineInputBorder(),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                    onChanged: (val) => _customType = val,
                    onSaved: (val) => _customType = val,
                  ),
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _waterColor,
                decoration: const InputDecoration(
                  labelText: '水色',
                  prefixIcon: Icon(Icons.water_drop),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                ),
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
                onSaved: (val) => _waterColor = val,
              ),
              if (_waterColor == '其他')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: '請輸入水色',
                      contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      border: UnderlineInputBorder(),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey, width: 1),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                    onChanged: (val) => _customWaterColor = val,
                    onSaved: (val) => _customWaterColor = val,
                  ),
                ),
              const SizedBox(height: 16),
              // 光照欄位改成如下：
              GestureDetector(
                onTap: () async {
                  int tempHour = _lightHour;
                  int tempMinute = (_lightMinute / 5).round();
                  await showModalBottomSheet(
                    context: context,
                    builder: (ctx) {
                      return SizedBox(
                        height: 250,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                SizedBox(width: 100, child: Center(child: Text('小時', style: TextStyle(fontWeight: FontWeight.bold)))),
                                SizedBox(width: 100, child: Center(child: Text('分鐘', style: TextStyle(fontWeight: FontWeight.bold)))),
                              ],
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 100,
                                    child: CupertinoPicker(
                                      scrollController: FixedExtentScrollController(initialItem: tempHour),
                                      itemExtent: 40,
                                      magnification: 1.2,
                                      useMagnifier: true,
                                      onSelectedItemChanged: (v) => tempHour = v,
                                      children: List.generate(25, (idx) => Center(child: Text('$idx'))),
                                    ),
                                  ),
                                  SizedBox(width: 24), // 空白取代原本的「:」
                                  SizedBox(
                                    width: 100,
                                    child: CupertinoPicker(
                                      scrollController: FixedExtentScrollController(initialItem: tempMinute),
                                      itemExtent: 40,
                                      magnification: 1.2,
                                      useMagnifier: true,
                                      onSelectedItemChanged: (v) => tempMinute = v,
                                      children: List.generate(12, (idx) => Center(child: Text('${idx * 5}'))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                  setState(() {
                    _lightHour = tempHour;
                    _lightMinute = tempMinute * 5;
                  });
                },
                child: ListTile(
                  title: Text('光照'),
                  subtitle: Text('${_lightHour} 小時 ${_lightMinute} 分'),
                  trailing: const Icon(Icons.wb_sunny),
                ),
              ),
              const SizedBox(height: 16),
              // 溫度欄位改成如下：
              GestureDetector(
                onTap: () async {
                  int temp = _temperatureValue;
                  await showModalBottomSheet(
                    context: context,
                    builder: (ctx) {
                      return SizedBox(
                        height: 250,
                        child: ListWheelScrollView.useDelegate(
                          itemExtent: 40,
                          onSelectedItemChanged: (v) => temp = v,
                          controller: FixedExtentScrollController(initialItem: _temperatureValue),
                          childDelegate: ListWheelChildBuilderDelegate(
                            builder: (ctx, idx) => idx <= 50 ? Center(child: Text('$idx °C')) : null,
                            childCount: 51,
                          ),
                        ),
                      );
                    },
                  );
                  setState(() {
                    _temperatureValue = temp;
                  });
                },
                child: ListTile(
                  title: Text('溫度 (°C)'),
                  subtitle: Text('$_temperatureValue °C'),
                  trailing: const Icon(Icons.thermostat),
                ),
              ),
              const SizedBox(height: 16),
              // pH欄位改成如下：
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('pH', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Slider(
                    min: 0,
                    max: 14,
                    divisions: 140,
                    value: _phSliderValue,
                    label: _phSliderValue.toStringAsFixed(1),
                    onChanged: (v) => setState(() => _phSliderValue = v),
                  ),
                  Center(child: Text('目前值：${_phSliderValue.toStringAsFixed(1)}')),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[100]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _isWaterChanged,
                          activeColor: Colors.green,
                          checkColor: Colors.white,
                          onChanged: (val) async {
                            setState(() => _isWaterChanged = val ?? false);
                            if (val == true) {
                              await _pickNextWaterChangeDate(context);
                            } else {
                              setState(() {
                                _nextWaterChangeDate = null;
                              });
                            }
                          },
                        ),
                        Text(
                          '今日有換水',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_isWaterChanged && _nextWaterChangeDate != null)
                          Flexible(
                            child: GestureDetector(
                              onTap: () => _pickNextWaterChangeDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.water_drop, color: Colors.blue[600], size: 18),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '下次換水: ${_nextWaterChangeDate!.toLocal().toString().split(' ')[0]}',
                                        style: TextStyle(color: Colors.blue[700], fontWeight: FontWeight.w500, fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.edit, size: 16, color: Colors.blue),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _isFertilized,
                          activeColor: Colors.orange,
                          checkColor: Colors.white,
                          onChanged: (val) {
                            setState(() => _isFertilized = val ?? false);
                            if (val == true && _nextFertilizeDate == null) {
                              _nextFertilizeDate = DateTime.now().add(const Duration(days: 7));
                            }
                            if (val == false) {
                              _nextFertilizeDate = null;
                            }
                          },
                        ),
                        Text(
                          '今日有施肥',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_isFertilized && _nextFertilizeDate != null)
                          Flexible(
                            child: GestureDetector(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _nextFertilizeDate ?? DateTime.now().add(const Duration(days: 7)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _nextFertilizeDate = picked;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange[200]!),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.science, color: Colors.orange[600], size: 18),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '下次施肥: ${_nextFertilizeDate!.toLocal().toString().split(' ')[0]}',
                                        style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.w500, fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.edit, size: 16, color: Colors.orange),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: '微藻描述',
                  prefixIcon: Icon(Icons.description),
                  contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                ),
                maxLines: 2,
                initialValue: _notes,
                onSaved: (val) => _notes = val,
              ),
              const SizedBox(height: 20),
              // 圖片上傳區塊（可根據你的需求調整）
              if (!kIsWeb) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('上傳照片'),
                        onPressed: _pickImages,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_image != null)
                      SizedBox(
                        height: 60,
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(_image!, width: 60, height: 60, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _image = null;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () async {
                        try {
                          if (_formKey.currentState!.validate()) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(child: CircularProgressIndicator()),
                            );
                            _formKey.currentState!.save();
                            // 儲存時要把這三個欄位的值正確存進 AlgaeLog
                            final log = AlgaeLog(
                              id: widget.logId,
                              date: _selectedDate ?? DateTime.now(),
                              waterColor: _waterColor == '其他' ? _customWaterColor ?? '' : _waterColor ?? '',
                              temperature: _temperatureValue.toDouble(),
                              pH: _phSliderValue,
                              lightHours: _lightHour + _lightMinute/60.0,
                              photoPath: _image?.path,
                              notes: _notes ?? '',
                              type: _type == '其他' ? _customType : _type,
                              isWaterChanged: _isWaterChanged,
                              nextWaterChangeDate: _isWaterChanged ? _nextWaterChangeDate : null,
                              isFertilized: _isFertilized,
                              nextFertilizeDate: _isFertilized ? _nextFertilizeDate : null,
                            );
                            final existLog = await DatabaseService.instance.getLogByDate(log.date);
                            Navigator.of(context).pop(); // 關閉 loading
                            if (existLog != null && widget.logId == null) {
                              final shouldOverwrite = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text('覆蓋提醒'),
                                  content: Text('這一天已經有日誌，儲存會覆蓋原本的內容，確定要繼續嗎？'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('取消'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: Text('覆蓋', style: TextStyle(color: Colors.green)),
                                    ),
                                  ],
                                ),
                              );
                              if (shouldOverwrite == true) {
                                await DatabaseService.instance.updateLog(log.copyWith(id: existLog.id));
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('日誌已覆蓋')),
                                  );
                                  Navigator.of(context).pop();
                                }
                              }
                            } else {
                              if (widget.logId == null) {
                                await DatabaseService.instance.createLog(log);
                              } else {
                                await DatabaseService.instance.updateLog(log);
                              }
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('日誌已儲存')),
                                );
                                Navigator.of(context).pop();
                              }
                            }
                          }
                        } catch (e) {
                          print('儲存失敗: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('儲存失敗: $e', style: TextStyle(color: Colors.black87))),
                          );
                        }
                      },
                      child: const Text('儲存'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('取消'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 