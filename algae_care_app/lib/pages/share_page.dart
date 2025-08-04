import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
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

    // 追蹤分享平台數量
    int platformCount = prefs.getInt('share_platform_count') ?? 0;
    platformCount++;
    await prefs.setInt('share_platform_count', platformCount);

    // 檢查並更新成就
    await _achievementService.checkAndUpdateAchievements();

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

  Future<void> _shareContent() async {
    final text = '我正在用「微藻養殖APP」養微藻、減碳救地球！本月吸碳量${badgeCount}kg，已解鎖${badgeCount}個成就徽章，快來一起參與綠生活！#微藻 #減碳 #環保 #永續發展';

    try {
      if (_imageFile != null) {
        await Share.shareXFiles([XFile(_imageFile!.path)], text: text);
      } else {
        await Share.share(text);
      }
      _showSuccessDialog();
    } catch (e) {
      // 如果分享失敗，顯示錯誤訊息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分享失敗：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareToSpecificApp(String appType) async {
    final text = '我正在用「微藻養殖APP」養微藻、減碳救地球！本月吸碳量${badgeCount}kg，已解鎖${badgeCount}個成就徽章！#微藻 #減碳 #環保';
    final encodedText = Uri.encodeComponent(text);

    String url = '';
    switch (appType) {
      case 'line':
        url = 'https://line.me/R/msg/text/?$encodedText';
        break;
      case 'instagram':
        // Instagram 不支援直接文字分享，需要先分享到相簿
        url = 'instagram://library?AssetPickerSourceType=1';
        break;
      case 'facebook':
        url = 'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent('https://example.com')}&quote=$encodedText';
        break;
      case 'twitter':
        url = 'https://twitter.com/intent/tweet?text=$encodedText';
        break;
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        _showSuccessDialog();
      } else {
        // 如果無法開啟特定應用程式，使用通用分享
        await _shareContent();
      }
    } catch (e) {
      // 如果開啟失敗，使用通用分享
      await _shareContent();
    }
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
                  // 主要分享按鈕
                  ElevatedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('分享成果'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _shareContent,
                  ),
                  const SizedBox(height: 16),

                  // 選擇照片按鈕
                  OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('選擇照片'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _pickImage,
                  ),
                  const SizedBox(height: 24),

                  // 快速分享到特定應用程式
                  const Text('快速分享到：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () => _shareToSpecificApp('line'),
                        icon: const Icon(Icons.chat_bubble, color: Colors.green),
                        tooltip: '分享到 LINE',
                      ),
                      IconButton(
                        onPressed: () => _shareToSpecificApp('facebook'),
                        icon: const Icon(Icons.facebook, color: Colors.blue),
                        tooltip: '分享到 Facebook',
                      ),
                      IconButton(
                        onPressed: () => _shareToSpecificApp('twitter'),
                        icon: const Icon(Icons.flutter_dash, color: Colors.lightBlue),
                        tooltip: '分享到 Twitter',
                      ),
                    ],
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
                             '點擊「分享成果」使用系統分享功能，或點擊下方圖標快速分享到特定應用程式。每次分享都有機會獲得成就徽章！',
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