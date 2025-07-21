import 'package:flutter/material.dart';
import '../models/algae_profile.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/database_service.dart';

class AlgaeProfileEditPage extends StatefulWidget {
  final AlgaeProfile? profile;

  const AlgaeProfileEditPage({Key? key, this.profile}) : super(key: key);

  @override
  _AlgaeProfileEditPageState createState() => _AlgaeProfileEditPageState();
}

class _AlgaeProfileEditPageState extends State<AlgaeProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String species;
  String? name;
  late int ageDays;
  late double length;
  late double width;
  late String waterSource;
  late String lightType;
  String? lightTypeDescription;
  // 1. 新增光照強度level狀態變數
  String _lightIntensityLevel = '中光';
  late int waterChangeFrequency;
  late double waterVolume;
  late String fertilizerType;
  String? fertilizerDescription;
  File? _image;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    species = p?.species ?? '綠藻';
    name = p?.name;
    ageDays = p?.ageDays ?? 1;
    length = p?.length ?? 1.0;
    width = p?.width ?? 1.0;
    waterSource = p?.waterSource ?? '自來水';
    lightType = p?.lightType ?? 'LED';
    lightTypeDescription = p?.lightTypeDescription;
    // _loadLogData 時自動帶入舊資料
    _lightIntensityLevel = p?.lightIntensityLevel ?? '中光';
    waterChangeFrequency = p?.waterChangeFrequency ?? 7;
    waterVolume = p?.waterVolume ?? 1.0;
    fertilizerType = p?.fertilizerType ?? '液態肥';
    fertilizerDescription = p?.fertilizerDescription;
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
        title: Text(widget.profile == null ? '新增藻類 Profile' : '編輯藻類 Profile',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 6,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Colors.green[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                DropdownButtonFormField<String>(
                  value: species,
                  decoration: const InputDecoration(
                    labelText: '品種',
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
                  onChanged: (v) => setState(() => species = v!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(
                    labelText: '名字（選填）',
                    prefixIcon: Icon(Icons.label),
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                  onChanged: (v) => name = v,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: ageDays.toString(),
                  decoration: const InputDecoration(
                    labelText: '養了幾天',
                    prefixIcon: Icon(Icons.calendar_today),
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => ageDays = int.tryParse(v) ?? 1,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: length.toString(),
                  decoration: const InputDecoration(
                    labelText: '藻類長度（cm）',
                    prefixIcon: Icon(Icons.straighten),
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => length = double.tryParse(v) ?? 1.0,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: width.toString(),
                  decoration: InputDecoration(
                    labelText: '藻類寬度（cm）',
                    prefixIcon: Icon(Icons.straighten, color: Colors.green[700]),
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    labelStyle: TextStyle(color: Colors.green),
                  ),
                  style: TextStyle(color: Colors.green[900]),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => width = double.tryParse(v) ?? 1.0,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: waterSource,
                  decoration: InputDecoration(
                    labelText: '水源',
                    prefixIcon: Icon(Icons.water_drop, color: Colors.green[700]),
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                    labelStyle: TextStyle(color: Colors.green),
                  ),
                  style: TextStyle(color: Colors.green[900]),
                  dropdownColor: Colors.green[50],
                  items: const [
                    DropdownMenuItem(value: '自來水', child: Text('自來水')),
                    DropdownMenuItem(value: '雨水', child: Text('雨水')),
                    DropdownMenuItem(value: '地下水', child: Text('地下水')),
                    DropdownMenuItem(value: '其他', child: Text('其他')),
                  ],
                  onChanged: (v) => setState(() => waterSource = v!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: lightType,
                  decoration: const InputDecoration(
                    labelText: '光源種類',
                    prefixIcon: Icon(Icons.wb_sunny),
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
                    DropdownMenuItem(value: 'LED', child: Text('LED')),
                    DropdownMenuItem(value: '自然光', child: Text('自然光')),
                    DropdownMenuItem(value: '其他', child: Text('其他')),
                  ],
                  onChanged: (v) => setState(() => lightType = v!),
                ),
                if (lightType == '其他')
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextFormField(
                      initialValue: lightTypeDescription,
                      decoration: const InputDecoration(
                        labelText: '光源描述',
                        prefixIcon: Icon(Icons.wb_sunny_outlined),
                        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        border: UnderlineInputBorder(),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey, width: 1),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.green, width: 2),
                        ),
                      ),
                      onChanged: (v) => lightTypeDescription = v,
                    ),
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _lightIntensityLevel,
                  decoration: const InputDecoration(
                    labelText: '光照強度',
                    prefixIcon: Icon(Icons.light_mode),
                  ),
                  items: const [
                    DropdownMenuItem(value: '強光', child: Text('強光')),
                    DropdownMenuItem(value: '中光', child: Text('中光')),
                    DropdownMenuItem(value: '弱光', child: Text('弱光')),
                  ],
                  onChanged: (v) => setState(() => _lightIntensityLevel = v!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: waterChangeFrequency.toString(),
                  decoration: const InputDecoration(
                    labelText: '換水頻率（天）',
                    prefixIcon: Icon(Icons.repeat),
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => waterChangeFrequency = int.tryParse(v) ?? 7,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: waterVolume.toString(),
                  decoration: const InputDecoration(
                    labelText: '水體體積（公升）',
                    prefixIcon: Icon(Icons.invert_colors),
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    border: UnderlineInputBorder(),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green, width: 2),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (v) => waterVolume = double.tryParse(v) ?? 1.0,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: fertilizerType,
                  decoration: const InputDecoration(
                    labelText: '肥料種類',
                    prefixIcon: Icon(Icons.science),
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
                    DropdownMenuItem(value: '液態肥', child: Text('液態肥')),
                    DropdownMenuItem(value: '固態肥', child: Text('固態肥')),
                    DropdownMenuItem(value: '自製肥料', child: Text('自製肥料')),
                  ],
                  onChanged: (v) => setState(() => fertilizerType = v!),
                ),
                if (fertilizerType == '自製肥料')
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextFormField(
                      initialValue: fertilizerDescription,
                      decoration: const InputDecoration(
                        labelText: '肥料描述',
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
                      onChanged: (v) => fertilizerDescription = v,
                    ),
                  ),
                const SizedBox(height: 20),
                // 圖片上傳區塊
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.photo_camera),
                        label: const Text('上傳照片'),
                        onPressed: _pickImage,
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
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    child: const Text('儲存', style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          print('準備寫入資料庫');
                          final profile = AlgaeProfile(
                            id: widget.profile?.id, // 編輯時帶入 id
                            species: species,
                            name: name,
                            ageDays: ageDays,
                            length: length,
                            width: width,
                            waterSource: waterSource,
                            lightType: lightType,
                            lightTypeDescription: lightType == '其他' ? lightTypeDescription : null,
                            lightIntensityLevel: _lightIntensityLevel,
                            waterChangeFrequency: waterChangeFrequency,
                            waterVolume: waterVolume,
                            fertilizerType: fertilizerType,
                            fertilizerDescription: fertilizerType == '自製肥料' ? fertilizerDescription : null,
                          );
                          if (widget.profile?.id != null) {
                            await DatabaseService.instance.updateProfile(profile);
                          } else {
                            await DatabaseService.instance.createProfile(profile);
                          }
                          print('寫入完成，準備 pop');
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        } catch (e, s) {
                          print('寫入 profile 發生錯誤: $e');
                          print(s);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('儲存失敗: $e')),
                            );
                          }
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 