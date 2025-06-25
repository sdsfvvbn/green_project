import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:algae_care_app/services/database_service.dart';

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> with SingleTickerProviderStateMixin {
  File? _imageFile;
  bool _showShareSuccess = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  double _algaeVolume = 1.0;
  int _logDays = 1;
  double get _monthCO2 => _algaeVolume * 2 / 12;
  double get _totalCO2 => _algaeVolume * 2 * _logDays / 365;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.2).chain(CurveTween(curve: Curves.elasticOut)).animate(_animController);
    _loadAlgaeSettings();
    _loadLogDays();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _loadAlgaeSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _algaeVolume = prefs.getDouble('algae_volume') ?? 1.0;
    });
  }

  Future<void> _loadLogDays() async {
    final db = DatabaseService.instance;
    final days = await db.getLogDays();
    setState(() {
      _logDays = days > 0 ? days : 1;
    });
  }

  void _showSuccessDialog() async {
    _animController.forward(from: 0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('share_achievement_unlocked', true);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnim,
              child: const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
            ),
            const SizedBox(height: 12),
            const Text('分享成功！', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 8),
            const Text('你已解鎖「綠色生活推廣者」成就，讓更多人認識微藻！', textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }

  void _shareToLine(BuildContext context) {
    final text = '我正在用「微藻養殖APP」養微藻、減碳救地球！本月吸碳量2.5kg，快來一起參與綠生活！#微藻 #減碳 #環保';
    if (_imageFile != null) {
      Share.shareXFiles([XFile(_imageFile!.path)], text: text);
    } else {
      Share.share(text);
    }
    _showSuccessDialog();
  }

  void _shareToIG(BuildContext context) {
    final text = '我的微藻成果：本月吸碳2.5kg，已解鎖多項成就徽章！你也能輕鬆養微藻，加入綠色行動！#微藻 #個人化養殖 #永續';
    if (_imageFile != null) {
      Share.shareXFiles([XFile(_imageFile!.path)], text: text);
    } else {
      Share.share(text);
    }
    _showSuccessDialog();
  }

  void _shareToFB(BuildContext context) {
    // 預留 Facebook 分享（可用 share_plus 或 url_launcher 實作）
    _showSuccessDialog();
  }

  void _shareToTwitter(BuildContext context) {
    // 預留 Twitter 分享（可用 share_plus 或 url_launcher 實作）
    _showSuccessDialog();
  }

  @override
  Widget build(BuildContext context) {
    // 假資料可改為串接本地資料庫
    final badgeCount = 5;
    final photoCount = 7;
    return Scaffold(
      appBar: AppBar(title: const Text('社群分享'), backgroundColor: Colors.green[700]),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  color: Colors.green[50],
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  margin: const EdgeInsets.only(bottom: 32),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        _imageFile == null
                            ? Icon(Icons.emoji_nature, color: Colors.green[700], size: 64)
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.file(_imageFile!, width: 140, height: 140, fit: BoxFit.cover),
                              ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add_a_photo, color: Colors.white),
                          label: const Text('上傳成果照片', style: TextStyle(color: Colors.white)),
                          onPressed: _pickImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[400],
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('我的微藻成果', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(height: 4),
                        Text('本月吸碳量：${_monthCO2.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 16, color: Colors.teal)),
                        Text('累積吸碳量：${_totalCO2.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 16, color: Colors.green)),
                        Text('已解鎖徽章：$badgeCount 枚', style: const TextStyle(fontSize: 16, color: Colors.orange)),
                        Text('上傳照片數：$photoCount 張', style: const TextStyle(fontSize: 16, color: Colors.blue)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.eco, color: Colors.teal, size: 28),
                            SizedBox(width: 8),
                            Icon(Icons.calendar_month, color: Colors.blue, size: 28),
                            SizedBox(width: 8),
                            Icon(Icons.menu_book, color: Colors.orange, size: 28),
                            SizedBox(width: 8),
                            Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.chat, color: Colors.white),
                      label: const Text('分享到 LINE', style: TextStyle(color: Colors.white)),
                      onPressed: () => _shareToLine(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        minimumSize: const Size(160, 48),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text('分享到 IG', style: TextStyle(color: Colors.white)),
                      onPressed: () => _shareToIG(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[400],
                        minimumSize: const Size(160, 48),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.facebook, color: Colors.blue),
                      label: const Text('分享到 FB'),
                      onPressed: () => _shareToFB(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size(160, 48),
                        textStyle: const TextStyle(fontSize: 16, color: Colors.blue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Colors.blue),
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.alternate_email, color: Colors.lightBlue),
                      label: const Text('分享到 Twitter'),
                      onPressed: () => _shareToTwitter(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size(160, 48),
                        textStyle: const TextStyle(fontSize: 16, color: Colors.lightBlue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: const BorderSide(color: Colors.lightBlue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text('推廣個人化微藻養殖，讓更多人一起減碳、愛地球！',
                    style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 