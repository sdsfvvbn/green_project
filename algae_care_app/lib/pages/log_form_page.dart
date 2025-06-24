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
  String? _ph;
  String? _notes;
  File? _image;

  @override
  void initState() {
    super.initState();
    if (widget.logId != null) {
      // TODO: 從資料庫讀取該筆日誌，並預設填入各欄位（含 notes）
    }
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
      appBar: AppBar(title: const Text('日誌紀錄'), backgroundColor: Colors.blue[700]),
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
              TextFormField(
                decoration: const InputDecoration(labelText: '水色'),
                onSaved: (val) => _waterColor = val,
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
                onSaved: (val) => _ph = val,
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
                    // 儲存資料到資料庫
                    final log = AlgaeLog(
                      id: widget.logId,
                      date: _selectedDate ?? DateTime.now(),
                      waterColor: _waterColor ?? '',
                      temperature: double.tryParse(_temperature ?? '') ?? 0,
                      pH: double.tryParse(_ph ?? '') ?? 0,
                      lightHours: int.tryParse(_light ?? '') ?? 0,
                      photoPath: _image?.path,
                      notes: _notes ?? '',
                    );
                    // TODO: 判斷是新增還是編輯
                    // await DatabaseService.instance.createLog(log);
                    // or await DatabaseService.instance.updateLog(log);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('日誌已儲存')),
                    );
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