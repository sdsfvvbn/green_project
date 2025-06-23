import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _shareToLine(BuildContext context) {
    final text = '我正在用「微藻養殖APP」養微藻、減碳救地球！本月吸碳量2.5kg，快來一起參與綠生活！#微藻 #減碳 #環保';
    if (_imageFile != null) {
      Share.shareXFiles([XFile(_imageFile!.path)], text: text);
    } else {
      Share.share(text);
    }
  }

  void _shareToIG(BuildContext context) {
    final text = '我的微藻成果：本月吸碳2.5kg，已解鎖多項成就徽章！你也能輕鬆養微藻，加入綠色行動！#微藻 #個人化養殖 #永續';
    if (_imageFile != null) {
      Share.shareXFiles([XFile(_imageFile!.path)], text: text);
    } else {
      Share.share(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('社群分享'), backgroundColor: Colors.green[700]),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: Colors.green[50],
                margin: const EdgeInsets.only(bottom: 32),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _imageFile == null
                          ? Icon(Icons.emoji_nature, color: Colors.green[700], size: 48)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_imageFile!, width: 120, height: 120, fit: BoxFit.cover),
                            ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('上傳成果照片'),
                        onPressed: _pickImage,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[400]),
                      ),
                      const SizedBox(height: 8),
                      const Text('我的微藻成果', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      const Text('本月吸碳量：2.5 kg\n累積吸碳量：12.8 kg\n成就徽章：3枚', textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.eco, color: Colors.teal, size: 28),
                          SizedBox(width: 8),
                          Icon(Icons.calendar_month, color: Colors.blue, size: 28),
                          SizedBox(width: 8),
                          Icon(Icons.menu_book, color: Colors.orange, size: 28),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('分享到 LINE'),
                onPressed: () => _shareToLine(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('分享到 IG'),
                onPressed: () => _shareToIG(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple[400]),
              ),
              const SizedBox(height: 32),
              const Text('推廣個人化微藻養殖，讓更多人一起減碳、愛地球！',
                  style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
} 