import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../services/achievement_service.dart';

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  XFile? _imageFile;
  int badgeCount = 0;
  int photoCount = 0;
  late final AchievementService _achievementService;

  @override
  void initState() {
    super.initState();
    _achievementService = AchievementService.instance;
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
    _loadData();
  }

  Future<void> _loadData() async {
    final unlockedCount = await _achievementService.getUnlockedAchievementCount();
    setState(() {
      badgeCount = unlockedCount;
      photoCount = 3; // 模擬照片數量
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  void _showSuccessDialog() async {
    _animController.forward(from: 0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('share_achievement_unlocked', true);
    
    // 解鎖分享成就
    await _achievementService.unlockAchievement('share_achievement');
    
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
    final text = '分享我的微藻養殖成果：已解鎖$badgeCount個成就徽章，為地球減碳盡一份心力！一起加入綠色生活！#微藻養殖 #環保 #永續發展';
    if (_imageFile != null) {
      Share.shareXFiles([XFile(_imageFile!.path)], text: text);
    } else {
      Share.share(text);
    }
    _showSuccessDialog();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '社群分享',
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
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
            Navigator.of(context).pop();
          }
        },
        child: Center(
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
                              : kIsWeb
                                  ? Icon(Icons.image, size: 64, color: Colors.grey)
                                  : Image.file(File(_imageFile!.path), width: 64, height: 64, fit: BoxFit.cover),
                          const SizedBox(height: 16),
                          Text('已獲得 $badgeCount 枚徽章', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 8),
                          Text('已上傳 $photoCount 張照片', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('分享到 LINE'),
                    onPressed: () => _shareToLine(context),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('分享到 Instagram'),
                    onPressed: () => _shareToIG(context),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.facebook),
                    label: const Text('分享到 Facebook'),
                    onPressed: () => _shareToFB(context),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('選擇照片'),
                    onPressed: _pickImage,
                  ),
                  const SizedBox(height: 32),
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.blue[700]),
                          const SizedBox(height: 8),
                          const Text(
                            '分享小貼士',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '分享你的微藻成果，讓更多人了解微藻養殖的環保價值！每次分享都有機會獲得成就徽章。',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 