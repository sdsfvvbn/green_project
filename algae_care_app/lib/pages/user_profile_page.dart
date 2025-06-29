import 'package:flutter/material.dart';
import '../models/post.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UserProfilePage extends StatefulWidget {
  final String user;
  final List<Post> posts;
  const UserProfilePage({super.key, required this.user, required this.posts});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String? _nickname;
  File? _avatar;
  String? _bio = '熱愛微藻養殖，歡迎交流！';
  String? _email = 'algae@example.com';
  final List<Map<String, dynamic>> _badges = [
    {'icon': Icons.emoji_events, 'label': '成就達人'},
    {'icon': Icons.eco, 'label': '綠色生活'},
    {'icon': Icons.star, 'label': '人氣王'},
  ];

  @override
  void initState() {
    super.initState();
    _nickname = widget.user;
  }

  void _editProfile() async {
    String nickname = _nickname ?? widget.user;
    File? avatar = _avatar;
    final picker = ImagePicker();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('編輯個人資料'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final picked = await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() {
                      avatar = File(picked.path);
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: avatar != null ? FileImage(avatar!) : null,
                  child: avatar == null ? Text(nickname[0], style: const TextStyle(fontSize: 32)) : null,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: '暱稱'),
                controller: TextEditingController(text: nickname),
                onChanged: (val) => nickname = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _nickname = nickname;
                  _avatar = avatar;
                });
                Navigator.pop(context);
              },
              child: const Text('儲存'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvatar() {
    if (kIsWeb) {
      // Web 端暫時顯示預設 icon
      return CircleAvatar(
        radius: 40,
        child: Text((_nickname ?? widget.user)[0], style: const TextStyle(fontSize: 32)),
      );
    } else {
      return CircleAvatar(
        radius: 40,
        backgroundImage: _avatar != null ? FileImage(_avatar!) : null,
        child: _avatar == null ? Text((_nickname ?? widget.user)[0], style: const TextStyle(fontSize: 32)) : null,
      );
    }
  }

  List<Map<String, dynamic>> getUserBadges() {
    List<Map<String, dynamic>> badges = [
      {'icon': Icons.emoji_events, 'label': '成就達人'},
      {'icon': Icons.eco, 'label': '綠色生活'},
      {'icon': Icons.star, 'label': '人氣王'},
    ];
    if (true) {
      badges.add({'icon': Icons.psychology, 'label': '知識達人'});
    }
    return badges;
  }

  @override
  Widget build(BuildContext context) {
    final userPosts = widget.posts.where((p) => p.author == widget.user).toList();
    final totalLikes = userPosts.fold<int>(0, (sum, p) => sum + p.likedBy.length);
    return Scaffold(
      appBar: AppBar(title: Text('${_nickname ?? widget.user} 的主頁'), backgroundColor: Colors.green[700]),
      body: Column(
        children: [
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _editProfile,
            child: _buildAvatar(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_nickname ?? widget.user, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: _editProfile,
                tooltip: '編輯個人資料',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Chip(label: Text('貼文 ${userPosts.length}')),
              const SizedBox(width: 8),
              Chip(label: Text('總讚數 $totalLikes')),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: getUserBadges().map((b) => Chip(
              avatar: Icon(b['icon'], color: Colors.orange),
              label: Text(b['label']),
            )).toList(),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('自我介紹：${_bio ?? ''}', style: const TextStyle(color: Colors.grey)),
                Text('Email：${_email ?? ''}', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const Text('貼文', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: userPosts.length,
              itemBuilder: (context, idx) {
                final post = userPosts[idx];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.content),
                        if (post.imageUrls.isNotEmpty)
                          SizedBox(
                            height: 80,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: post.imageUrls.map((url) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: kIsWeb
                                  ? Icon(Icons.image, size: 60, color: Colors.grey)
                                  : Image.file(
                                      File(url),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                              )).toList(),
                            ),
                          ),
                        Wrap(
                          spacing: 8,
                          children: post.tags.map((t) => Chip(label: Text(t))).toList(),
                        ),
                        Text('${post.createdAt.year}/${post.createdAt.month}/${post.createdAt.day}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 