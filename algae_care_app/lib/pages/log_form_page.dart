import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:algae_care_app/models/algae_log.dart';
import 'package:algae_care_app/services/database_service.dart';

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

  Future<void> _pickImage() async {
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
                    onChanged: (val) => setState(() => _isWaterChanged = val ?? false),
                  ),
                ],
              ),
              
              TextFormField(
                decoration: const InputDecoration(labelText: '微藻描述'),
                maxLines: 2,
                onSaved: (val) => _notes = val,
              ),
              const SizedBox(height: 16),
              _image == null
                  ? TextButton.icon(
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('上傳照片'),
                      onPressed: _pickImage,
                    )
                  : Column(
                      children: [
                        Image.file(_image!, height: 150),
                        TextButton(
                          onPressed: _pickImage,
                          child: const Text('更換照片'),
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('日誌已儲存')),
                      );
                    }
                  }
                },
                child: const Text('儲存'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 