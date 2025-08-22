import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/achievement_service.dart';

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  int badgeCount = 0;
  int photoCount = 0;
  double totalCO2 = 0.0;
  late final AchievementService _achievementService;
  String _shareText = '我正在用「微藻養殖APP」養微藻、減碳救地球！快來一起參與綠生活！#微藻 #減碳 #環保 #永續發展';
  bool _isLoading = true;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _achievementService = AchievementService.instance;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final unlockedCount = await _achievementService.getUnlockedAchievementCount();
      setState(() {
        badgeCount = unlockedCount;
        photoCount = 3; // 模擬照片數量，可以從資料庫獲取
        totalCO2 = 125.5; // 模擬總吸碳量，可以從資料庫獲取
        _isLoading = false;
      });
    } catch (e) {
      // 如果載入失敗，使用預設值
      setState(() {
        badgeCount = 0;
        photoCount = 0;
        totalCO2 = 0.0;
        _isLoading = false;
      });
      print('載入成就數據失敗: $e');
    }
  }

  // 已移除圖片選擇功能

  void _showSuccessDialog() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 更新分享次數
      int totalShares = prefs.getInt('total_share_count') ?? 0;
      totalShares++;
      await prefs.setInt('total_share_count', totalShares);

      // 檢查並更新成就
      try {
        await _achievementService.checkAndUpdateAchievements();
      } catch (e) {
        print('檢查成就失敗: $e');
        // 即使成就檢查失敗，也繼續顯示成功對話框
      }

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
                    );
                  },
                ),
                const SizedBox(height: 12),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: const Text('分享成功！', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    );
                  },
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Text('您已分享 $totalShares 次，繼續推廣微藻養殖！', textAlign: TextAlign.center),
                    );
                  },
                ),
              ],
            ),
            actions: [
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 1200),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('太棒了！'),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('顯示成功對話框失敗: $e');
      // 如果顯示對話框失敗，至少顯示一個簡單的成功訊息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('分享成功！'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _shareContent() async {
    if (_isSharing) return; // 防止重複點擊

    setState(() {
      _isSharing = true;
    });

    try {
      // 根據使用者的成就和進度生成分享文字
      String shareText = _generateShareText();

      await Share.share(shareText);
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
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  String _generateShareText() {
    String baseText = '我正在用「微藻養殖APP」養微藻、減碳救地球！';
    List<String> achievements = [];

    if (badgeCount > 0) {
      achievements.add('已解鎖 $badgeCount 個成就徽章');
    }

    if (totalCO2 > 0) {
      if (totalCO2 >= 1000) {
        achievements.add('累積吸碳量 ${(totalCO2 / 1000).toStringAsFixed(1)} kg');
      } else {
        achievements.add('累積吸碳量 ${totalCO2.toInt()} g');
      }
    }

    if (photoCount > 0) {
      achievements.add('已記錄 $photoCount 張照片');
    }

    if (achievements.isNotEmpty) {
      baseText += '，${achievements.join('、')}，';
    }

    baseText += '快來一起參與綠生活！#微藻 #減碳 #環保 #永續發展';

    return baseText;
  }

  Future<void> _shareToSpecificApp(String appType) async {
    if (_isSharing) return; // 防止重複點擊

    setState(() {
      _isSharing = true;
    });

    try {
      final text = _generateShareText();
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
        default:
          // 如果是不支援的應用程式類型，使用通用分享
          await _shareContent();
          return;
      }

      try {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          _showSuccessDialog();
        } else {
          // 如果無法開啟特定應用程式，使用通用分享
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('無法開啟該應用程式，使用通用分享'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          await _shareContent();
        }
      } catch (e) {
        print('啟動URL失敗: $e');
        // 如果開啟失敗，使用通用分享
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('啟動應用程式失敗，使用通用分享'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        await _shareContent();
      }
    } catch (e) {
      print('特定應用程式分享失敗: $e');
      // 如果整個過程失敗，使用通用分享
      await _shareContent();
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '分享成果',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 成就統計卡片
            Card(
              color: Colors.green[50],
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: _isLoading
                    ? const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: Colors.green),
                            SizedBox(height: 16),
                            Text('載入中...', style: TextStyle(color: Colors.green)),
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                icon: Icons.emoji_events,
                                value: badgeCount.toString(),
                                label: '成就徽章',
                                color: Colors.amber[700]!,
                              ),
                              _buildStatItem(
                                icon: Icons.eco,
                                value: totalCO2 >= 1000
                                    ? '${(totalCO2 / 1000).toStringAsFixed(1)} kg'
                                    : '${totalCO2.toInt()} g',
                                label: '累積吸碳量',
                                color: Colors.green[700]!,
                              ),
                              _buildStatItem(
                                icon: Icons.photo_camera,
                                value: photoCount.toString(),
                                label: '記錄照片',
                                color: Colors.blue[700]!,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.orange[300]!),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.share, color: Colors.orange[700], size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  '分享您的成果',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (badgeCount == 0 && totalCO2 == 0 && photoCount == 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Column(
                                children: [
                                  Text(
                                    '還沒有成就數據',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: _loadData,
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text('重新載入'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          FutureBuilder<SharedPreferences>(
                            future: SharedPreferences.getInstance(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final totalShares = snapshot.data!.getInt('total_share_count') ?? 0;
                                if (totalShares > 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.green[300]!),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.trending_up, color: Colors.green[700], size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            '已分享 $totalShares 次',
                                            style: TextStyle(
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          if (badgeCount > 0 || totalCO2 > 0 || photoCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.purple[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.purple[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.analytics, color: Colors.purple[700], size: 16),
                                        const SizedBox(width: 8),
                                        Text(
                                          '進度摘要',
                                          style: TextStyle(
                                            color: Colors.purple[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '繼續努力，您已經取得了不錯的進展！',
                                      style: TextStyle(
                                        color: Colors.purple[700],
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    if (badgeCount > 0)
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text('成就進度', style: TextStyle(color: Colors.purple[700], fontSize: 12)),
                                              Text('$badgeCount/20', style: TextStyle(color: Colors.purple[700], fontSize: 12)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          LinearProgressIndicator(
                                            value: (badgeCount / 20).clamp(0.0, 1.0),
                                            backgroundColor: Colors.purple[200],
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[700]!),
                                          ),
                                        ],
                                      ),
                                    if (totalCO2 > 0)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('吸碳進度', style: TextStyle(color: Colors.purple[700], fontSize: 12)),
                                                Text('${totalCO2.toStringAsFixed(1)}/20.0 kg', style: TextStyle(color: Colors.purple[700], fontSize: 12)),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            LinearProgressIndicator(
                                              value: (totalCO2 / 20.0).clamp(0.0, 1.0),
                                              backgroundColor: Colors.purple[200],
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[700]!),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),

            // 分享文字編輯區
            Card(
              color: Colors.blue[50],
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_note, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        const Text(
                          '分享文字',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: TextEditingController(text: _generateShareText()),
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: '輸入您想要分享的文字...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                      onChanged: (value) {
                        _shareText = value;
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '提示：文字會根據您的成就和進度自動生成',
                      style: TextStyle(color: Colors.blue[600], fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final previewText = _generateShareText();
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('分享文字預覽'),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('這是你將要分享的文字：'),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey[300]!),
                                          ),
                                          child: Text(
                                            previewText,
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('關閉'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.preview, size: 16),
                            label: const Text('預覽文字'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue[700],
                              side: BorderSide(color: Colors.blue[300]!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 已移除圖片選擇區

            // 主要分享按鈕
            ElevatedButton.icon(
              icon: _isSharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.share, size: 24),
              label: Text(
                _isSharing ? '分享中...' : '分享成果',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSharing ? null : _shareContent,
            ),

            const SizedBox(height: 24),

            // 快速分享到特定應用程式
            const Text('快速分享到：', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: _isSharing ? null : () => _shareToSpecificApp('facebook'),
                  icon: const Icon(Icons.facebook, color: Colors.blue),
                  tooltip: '分享到 Facebook',
                ),
                IconButton(
                  onPressed: _isSharing ? null : () => _shareToSpecificApp('line'),
                  icon: const Icon(Icons.chat_bubble, color: Colors.green),
                  tooltip: '分享到 LINE',
                ),
                IconButton(
                  onPressed: _isSharing ? null : () => _shareToSpecificApp('instagram'),
                  icon: const Icon(Icons.camera_alt, color: Colors.purple),
                  tooltip: '分享到 Instagram',
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
                      '點擊「分享成果」使用系統分享功能，或點擊下方圖標快速分享到特定應用程式。每次分享都會記錄您的推廣成果！',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<SharedPreferences>(
                      future: SharedPreferences.getInstance(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final totalShares = snapshot.data!.getInt('total_share_count') ?? 0;
                          if (totalShares > 0) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue[300]!),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.share, color: Colors.blue[700], size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    '已分享 $totalShares 次',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.tips_and_updates, color: Colors.amber[700], size: 16),
                              const SizedBox(width: 8),
                              Text(
                                '分享建議',
                                style: TextStyle(
                                  color: Colors.amber[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• 定期分享您的養殖進度\n• 使用相關的標籤增加曝光度',
                            style: TextStyle(
                              color: Colors.amber[700],
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star, color: Colors.amber[700], size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '每次分享都有機會獲得成就徽章，繼續努力！',
                                    style: TextStyle(
                                      color: Colors.amber[700],
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<SharedPreferences>(
                      future: SharedPreferences.getInstance(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final totalShares = snapshot.data!.getInt('total_share_count') ?? 0;
                          if (totalShares > 0) {
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.indigo[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.indigo[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.history, color: Colors.indigo[700], size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        '分享里程碑',
                                        style: TextStyle(
                                          color: Colors.indigo[700],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    totalShares >= 10
                                        ? '🎉 您已經是分享達人了！'
                                        : totalShares >= 5
                                            ? '🌟 您正在成為分享高手！'
                                            : '💪 繼續加油，分享更多精彩內容！',
                                    style: TextStyle(
                                      color: Colors.indigo[700],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.indigo[100],
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                totalShares.toString(),
                                                style: TextStyle(
                                                  color: Colors.indigo[700],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Text(
                                                '總分享次數',
                                                style: TextStyle(
                                                  color: Colors.indigo[700],
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.indigo[100],
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                (totalShares * 0.5).toStringAsFixed(1),
                                                style: TextStyle(
                                                  color: Colors.indigo[700],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Text(
                                                '預估影響力',
                                                style: TextStyle(
                                                  color: Colors.indigo[700],
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}