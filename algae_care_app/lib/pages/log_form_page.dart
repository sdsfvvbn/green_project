import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:algae_care_app/models/algae_log.dart';
import 'package:algae_care_app/services/database_service.dart';
import 'package:algae_care_app/services/notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LogFormPage extends StatefulWidget {
  final int? logId; // 若有 logId 則為編輯，否則為新增
  const LogFormPage({super.key, this.logId});

  @override
  State<LogFormPage> createState() => _LogFormPageState();
}

class _LogFormPageState extends State<LogFormPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  String? _waterColor;
  String? _light;
  String? _temperature;
  double? _phValue;
  String? _notes;
  File? _image;
  String? _type;
  String? _customType;
  bool _isWaterChanged = false;
  String? _customWaterColor;
  DateTime? _nextWaterChangeDate;
  List<File> _images = []; // 新增：多圖
  List<String> _actions = []; // 新增：多種操作標記

  @override
  void initState() {
    super.initState();
    if (widget.logId != null) {
      // TODO: 從資料庫讀取該筆日誌，並預設填入各欄位（含 notes）
    }
    _phValue = null;
    _type = null;
    _isWaterChanged = false;
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
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
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _images = pickedFiles.map((f) => File(f.path)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text('日誌紀錄'),
        ),
        backgroundColor: Colors.blue[700],
        leading: IconButton(
          icon: const Icon(Icons.close),
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
                title: Text(_selectedDate == null ? '選擇日期' : '日期: \\${_selectedDate!.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(context),
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
                onSaved: (val) => _waterColor = val,
              ),
              if (_waterColor == '其他')
                TextFormField(
                  decoration: const InputDecoration(labelText: '請輸入水色'),
                  onChanged: (val) => _customWaterColor = val,
                  onSaved: (val) => _customWaterColor = val,
                ),
              TextFormField(
                decoration: const InputDecoration(labelText: '光照'),
                onSaved: (val) => _light = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: '溫度 (°C)'),
                keyboardType: TextInputType.number,
                onSaved: (val) => _temperature = val,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'pH'),
                keyboardType: TextInputType.number,
                onSaved: (val) {
                  _phValue = double.tryParse(val ?? '');
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
                        await _pickNextWaterChangeDate(context);
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
                        onPressed: () => _pickNextWaterChangeDate(context),
                        tooltip: '修改日期',
                      ),
                    ],
                  ),
                ),
              TextFormField(
                decoration: const InputDecoration(labelText: '微藻描述'),
                maxLines: 2,
                onSaved: (val) => _notes = val,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('選擇照片'),
                    onPressed: _pickImages,
                  ),
                  const SizedBox(width: 8),
                  if (_images.isNotEmpty)
                    Expanded(
                      child: SizedBox(
                        height: 60,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: _images.map((img) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: kIsWeb
                              ? Icon(Icons.image, size: 48, color: Colors.grey)
                              : Image.file(img, width: 60, height: 60, fit: BoxFit.cover),
                          )).toList(),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final log = AlgaeLog(
                      id: widget.logId,
                      date: _selectedDate ?? DateTime.now(),
                      waterColor: _waterColor == '其他' ? _customWaterColor ?? '' : _waterColor ?? '',
                      temperature: double.tryParse(_temperature ?? '') ?? 0,
                      pH: _phValue ?? 0,
                      lightHours: int.tryParse(_light ?? '') ?? 0,
                      photoPath: _image?.path,
                      notes: _notes ?? '',
                      type: _type == '其他' ? _customType : _type,
                      isWaterChanged: _isWaterChanged,
                      nextWaterChangeDate: _isWaterChanged ? _nextWaterChangeDate : null,
                    );
                    // 新增：檢查同日期是否已有日誌
                    final existLog = await DatabaseService.instance.getLogByDate(log.date);
                    if (existLog != null && widget.logId == null) {
                      final shouldOverwrite = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('覆蓋提醒'),
                          content: const Text('這一天已經有日誌，儲存會覆蓋原本的內容，確定要繼續嗎？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('取消'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('覆蓋'),
                            ),
                          ],
                        ),
                      );
                      if (shouldOverwrite == true) {
                        await DatabaseService.instance.updateLog(log.copyWith(id: existLog.id));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('日誌已覆蓋')),
                        );
                      }
                    } else {
                      if (widget.logId == null) {
                        await DatabaseService.instance.createLog(log);
                      } else {
                        await DatabaseService.instance.updateLog(log);
                      }
                      
                      // 如果有設置預計下次換水日期，設置通知
                      if (log.nextWaterChangeDate != null) {
                        await NotificationService.instance.scheduleWaterChangeReminder(
                          id: log.id ?? DateTime.now().millisecondsSinceEpoch,
                          scheduledDate: log.nextWaterChangeDate!,
                          title: '換水提醒',
                          body: '今天是預計換水的日子，記得檢查您的微藻養殖狀況！',
                        );
                      }
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('日誌已儲存')),
                      );
                    }
                  }
                },
                child: const Text('儲存'),
              ),
              const SizedBox(height: 16),
              // 操作標記多選
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('換水'),
                    selected: _actions.contains('換水'),
                    onSelected: (v) => setState(() => v ? _actions.add('換水') : _actions.remove('換水')),
                  ),
                  FilterChip(
                    label: const Text('加光'),
                    selected: _actions.contains('加光'),
                    onSelected: (v) => setState(() => v ? _actions.add('加光') : _actions.remove('加光')),
                  ),
                  FilterChip(
                    label: const Text('加肥'),
                    selected: _actions.contains('加肥'),
                    onSelected: (v) => setState(() => v ? _actions.add('加肥') : _actions.remove('加肥')),
                  ),
                  FilterChip(
                    label: const Text('其他'),
                    selected: _actions.contains('其他'),
                    onSelected: (v) => setState(() => v ? _actions.add('其他') : _actions.remove('其他')),
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