import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:algae_care_app/models/algae_log.dart';
import 'package:algae_care_app/services/database_service.dart';
import 'package:algae_care_app/services/achievement_service.dart';
// import 'package:algae_care_app/services/notification_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import '../models/algae_profile.dart';

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
  List<AlgaeProfile> _profiles = [];
  AlgaeProfile? _selectedProfile; // 新增：選中的藻類資料

  // 1. 新增光照、溫度、pH的狀態變數
  int _lightHour = 0;
  int _lightMinute = 0;
  int _temperatureValue = 25;
  double _phSliderValue = 7.0;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
    if (widget.logId != null) {
      _loadLogData(widget.logId!);
    }
    _phValue = null;
    _type = null;
    _isWaterChanged = false;
  }

  Future<void> _loadProfiles() async {
    final profiles = await DatabaseService.instance.getAllProfiles();
    setState(() {
      _profiles = profiles;
      // 如果有資料，預設選擇第一個
      if (profiles.isNotEmpty) {
        _selectedProfile = profiles.first;
        _autoFillFromProfile(_selectedProfile!);
      }
    });
  }

  // 新增：根據選擇的藻類自動填入資訊
  void _autoFillFromProfile(AlgaeProfile profile) {
    setState(() {
      _type = profile.species;
      // 可以根據需要自動填入其他資訊
    });
  }

  // 顯示成就解鎖對話框
  void _showAchievementUnlockedDialog(String achievementId) {
    final achievement = AchievementService.instance.achievements[achievementId];
    if (achievement == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconData(achievement['icon']),
              color: Colors.amber,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              '🎉 成就解鎖！',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              achievement['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              achievement['detail'],
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('太棒了！'),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'play_circle':
        return Icons.play_circle;
      case 'calendar_month':
        return Icons.calendar_month;
      case 'water_drop':
        return Icons.water_drop;
      case 'camera_alt':
        return Icons.camera_alt;
      case 'eco':
        return Icons.eco;
      case 'forest':
        return Icons.forest;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'share':
        return Icons.share;
      case 'question_answer':
        return Icons.question_answer;
      case 'check_circle':
        return Icons.check_circle;
      case 'psychology':
        return Icons.psychology;
      case 'photo_camera':
        return Icons.photo_camera;
      case 'science':
        return Icons.science;
      case 'edit_note':
        return Icons.edit_note;
      case 'person':
        return Icons.person;
      case 'public':
        return Icons.public;
      default:
        return Icons.star;
    }
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

        // 根據 profileId 選擇對應的藻類資料
        if (log.profileId != null) {
          _selectedProfile = _profiles.firstWhere(
            (profile) => profile.id == log.profileId,
            orElse: () => _profiles.isNotEmpty ? _profiles.first : AlgaeProfile(
              id: null,
              species: '綠藻',
              name: null,
              startDate: DateTime.now(),
              length: 1.0,
              width: 1.0,
              waterSource: '自來水',
              lightType: 'LED',
              lightTypeDescription: null,
              lightIntensityLevel: '中光',
              waterChangeFrequency: 7,
              waterVolume: 1.0,
              fertilizerType: '液態肥',
              fertilizerDescription: null,
            ),
          );
        }

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
              // 日期欄位移到最上面
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  title: Row(
                    children: [
                      Text(
                        '日期 *',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDate != null ? _selectedDate!.year.toString().padLeft(4, '0') + '-' + _selectedDate!.month.toString().padLeft(2, '0') + '-' + _selectedDate!.day.toString().padLeft(2, '0') : '請選擇日期',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDate != null ? Colors.black : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate(context),
                ),
              ),
              const SizedBox(height: 16),
              // 新增：選擇藻類名字的下拉選單
              if (_profiles.isNotEmpty)
                DropdownButtonFormField<AlgaeProfile>(
                  value: _selectedProfile,
                  decoration: const InputDecoration(
                    labelText: '選擇藻類 *',
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
                  items: _profiles.map((profile) {
                    return DropdownMenuItem(
                      value: profile,
                      child: Text(profile.name ?? profile.species),
                    );
                  }).toList(),
                  onChanged: (profile) {
                    setState(() {
                      _selectedProfile = profile;
                      if (profile != null) {
                        _autoFillFromProfile(profile);
                      }
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return '請選擇藻類';
                    }
                    return null;
                  },
                ),
              if (_profiles.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('請先建立藻類資料', style: TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  labelText: '種類 *',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請選擇種類';
                  }
                  return null;
                },
              ),
              if (_type == '其他')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: '請輸入種類 *',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入種類';
                      }
                      return null;
                    },
                  ),
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _waterColor,
                decoration: const InputDecoration(
                  labelText: '水色 *',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '請選擇水色';
                  }
                  return null;
                },
              ),
              if (_waterColor == '其他')
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: '請輸入水色 *',
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '請輸入水色';
                      }
                      return null;
                    },
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
                  title: Row(
                    children: [
                      Text('光照 *'),
                      const SizedBox(width: 8),
                      Text(
                        '${_lightHour} 小時 ${_lightMinute} 分',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
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
                        child: CupertinoPicker(
                          itemExtent: 40,
                          scrollController: FixedExtentScrollController(initialItem: _temperatureValue),
                          onSelectedItemChanged: (v) => temp = v,
                          children: List.generate(41, (idx) => Center(child: Text('$idx °C'))),
                        ),
                      );
                    },
                  );
                  setState(() {
                    _temperatureValue = temp;
                  });
                },
                child: ListTile(
                  title: Row(
                    children: [
                      Text('溫度 (°C) *'),
                      const SizedBox(width: 8),
                      Text(
                        '$_temperatureValue °C',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.thermostat),
                ),
              ),
              const SizedBox(height: 16),
              // pH欄位改成如下：
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('pH *', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                          // 檢查必填欄位
                          List<String> missingFields = [];

                          if (_selectedProfile == null) {
                            missingFields.add('選擇藻類');
                          }

                          if (_selectedDate == null) {
                            missingFields.add('日期');
                          }

                          if (_type == null || _type!.isEmpty) {
                            missingFields.add('種類');
                          } else if (_type == '其他' && (_customType == null || _customType!.isEmpty)) {
                            missingFields.add('自訂種類');
                          }

                          if (_waterColor == null || _waterColor!.isEmpty) {
                            missingFields.add('水色');
                          } else if (_waterColor == '其他' && (_customWaterColor == null || _customWaterColor!.isEmpty)) {
                            missingFields.add('自訂水色');
                          }

                          if (missingFields.isNotEmpty) {
                            // 顯示必填欄位提醒視窗
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Row(
                                  children: [
                                    Icon(Icons.warning, color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text('必填欄位提醒'),
                                  ],
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('請填寫以下必填欄位：'),
                                    const SizedBox(height: 8),
                                    ...missingFields.map((field) => Padding(
                                      padding: const EdgeInsets.only(left: 16, top: 4),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.arrow_right, size: 16, color: Colors.red),
                                          const SizedBox(width: 8),
                                          Text(field, style: const TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('確定'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }

                          if (_formKey.currentState!.validate()) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(child: CircularProgressIndicator()),
                            );
                            _formKey.currentState!.save();
                            // 根據 _type 找到對應 profile 的 waterVolume
                            double? waterVolume;
                            final profile = _profiles.firstWhere(
                              (p) => p.species == (_type == '其他' ? _customType : _type),
                              orElse: () => AlgaeProfile(
                                id: null,
                                species: _type == '其他' ? _customType ?? '' : _type ?? '',
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
                            waterVolume = profile.waterVolume ?? 1.0;
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
                              waterVolume: waterVolume,
                              profileId: _selectedProfile?.id,
                            );
                            final existLog = await DatabaseService.instance.getLogByDateAndProfile(log.date, _selectedProfile?.id);
                            Navigator.of(context).pop(); // 關閉 loading
                            if (existLog != null && widget.logId == null) {
                              final shouldOverwrite = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('覆蓋提醒'),
                                  content: Text('這一天已經有「${_selectedProfile?.name ?? _selectedProfile?.species}」的日誌記錄，儲存會覆蓋原本的內容，確定要繼續嗎？'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('取消'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('覆蓋', style: TextStyle(color: Colors.green)),
                                    ),
                                  ],
                                ),
                              );
                              if (shouldOverwrite == true) {
                                await DatabaseService.instance.updateLog(log.copyWith(id: existLog.id));

                                // 檢查並更新成就
                                final newlyUnlocked = await AchievementService.instance.checkAndUpdateAchievements();

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('日誌已覆蓋')),
                                  );

                                  // 如果有新解鎖的成就，顯示通知
                                  if (newlyUnlocked.isNotEmpty) {
                                    _showAchievementUnlockedDialog(newlyUnlocked.first);
                                  }

                                  Navigator.of(context).pop();
                                }
                              }
                            } else {
                              if (widget.logId == null) {
                                await DatabaseService.instance.createLog(log);
                              } else {
                                await DatabaseService.instance.updateLog(log);
                              }

                              // 檢查並更新成就
                              final newlyUnlocked = await AchievementService.instance.checkAndUpdateAchievements();

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('日誌已儲存')),
                                );

                                // 如果有新解鎖的成就，顯示通知
                                if (newlyUnlocked.isNotEmpty) {
                                  _showAchievementUnlockedDialog(newlyUnlocked.first);
                                }

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