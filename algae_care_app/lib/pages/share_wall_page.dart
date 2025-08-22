import 'package:flutter/material.dart';
import '../models/post.dart';

class ShareWallPage extends StatefulWidget {
  const ShareWallPage({super.key});

  @override
  State<ShareWallPage> createState() => _ShareWallPageState();
}

class _ShareWallPageState extends State<ShareWallPage> {
  List<Post> posts = [
    Post(
      id: '1',
      author: 'AlgaeLover',
      content: '我的微藻今天超綠！',
      tags: ['#綠藻', '#成長日誌'],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Post(
      id: '2',
      author: 'GreenMaster',
      content: '換水後狀態超好，推薦大家多曬太陽！',
      tags: ['#換水', '#養殖技巧'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  void _likePost(int index) {
    setState(() {
      posts[index].likedBy.add('你');
    });
  }

  void _addComment(int index, String text) {
    setState(() {
      posts[index].comments.add(Comment(user: '你', text: text, createdAt: DateTime.now()));
    });
  }

  void _showPostDialog() async {
    String content = '';
    List<String> tags = [];
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('發佈新貼文'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: '內容'),
                  maxLines: 3,
                  onChanged: (val) => content = val,
                ),
                const SizedBox(height: 8),
                // 已移除圖片選取與預覽
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['#綠藻', '#成長日誌', '#換水', '#養殖技巧', '#其他']
                      .map((t) => FilterChip(
                            label: Text(t),
                            selected: tags.contains(t),
                            onSelected: (v) {
                              if (v) {
                                tags.add(t);
                              } else {
                                tags.remove(t);
                              }
                              (context as Element).markNeedsBuild();
                            },
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (content.trim().isEmpty) return;
                setState(() {
                  posts.insert(
                    0,
                    Post(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      author: '你',
                      content: content,
                      tags: tags,
                      createdAt: DateTime.now(),
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('發佈'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '社群分享牆',
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
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, idx) {
            final post = posts[idx];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(child: Text(post.author[0])),
                        const SizedBox(width: 8),
                        Text(post.author, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text('${post.createdAt.hour}:${post.createdAt.minute.toString().padLeft(2, '0')}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(post.content),
                    // 已移除貼文圖片顯示區塊
                    Wrap(
                      spacing: 8,
                      children: post.tags.map((t) => Chip(label: Text(t))).toList(),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.thumb_up),
                          onPressed: () => _likePost(idx),
                        ),
                        Text('${post.likedBy.length}'),
                        const SizedBox(width: 16),
                        Icon(Icons.comment),
                        Text('${post.comments.length}'),
                      ],
                    ),
                    if (post.comments.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: post.comments.map((c) => Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text('${c.user}: ${c.text}', style: const TextStyle(color: Colors.grey)),
                        )).toList(),
                      ),
                    TextField(
                      decoration: const InputDecoration(hintText: '留言...'),
                      onSubmitted: (text) => _addComment(idx, text),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPostDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}