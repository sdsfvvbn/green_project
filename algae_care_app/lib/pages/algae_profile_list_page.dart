import 'package:flutter/material.dart';
import '../models/algae_profile.dart';
import 'algae_profile_edit_page.dart';
import '../services/database_service.dart';

class AlgaeProfileListPage extends StatefulWidget {
  @override
  _AlgaeProfileListPageState createState() => _AlgaeProfileListPageState();
}

class _AlgaeProfileListPageState extends State<AlgaeProfileListPage> {
  List<AlgaeProfile> profiles = [];

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final loaded = await DatabaseService.instance.getAllProfiles();
    setState(() {
      profiles = loaded;
    });
  }

  Future<void> addProfile(AlgaeProfile profile) async {
    final id = await DatabaseService.instance.createProfile(profile);
    final newProfile = profile..id = id;
    setState(() {
      profiles.add(newProfile);
    });
  }

  Future<void> editProfile(int index, AlgaeProfile profile) async {
    if (profile.id != null) {
      await DatabaseService.instance.updateProfile(profile);
      setState(() {
        profiles[index] = profile;
      });
    }
  }

  Future<void> deleteProfile(int index) async {
    if (profiles.length > 1) {
      final id = profiles[index].id;
      if (id != null) {
        await DatabaseService.instance.deleteProfile(id);
      }
      setState(() {
        profiles.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('至少要有一個 Profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '我的微藻',
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
        child: profiles.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.eco, size: 64, color: Colors.green[300]),
                    const SizedBox(height: 24),
                    const Text('尚未建立任何藻類', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Text('點擊下方按鈕開始建立你的第一個藻類！', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              )
            : PageView.builder(
                itemCount: profiles.length,
                controller: PageController(viewportFraction: 0.88),
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  return Center(
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 40, horizontal: 8),
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.green[100],
                              child: Icon(Icons.eco, size: 40, color: Colors.green[700]),
                            ),
                            const SizedBox(height: 16),
                            Text(profile.name?.isNotEmpty == true ? profile.name! : profile.species,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('品種：${profile.species}'),
                            Text('養了：${DateTime.now().difference(profile.startDate).inDays + 1} 天'),
                            Text('水源：${profile.waterSource}'),
                            Text('光源種類：${profile.lightType}' + (profile.lightType == '其他' && (profile.lightTypeDescription?.isNotEmpty ?? false) ? '（${profile.lightTypeDescription}）' : '')),
                            Text('光照強度：${profile.lightIntensityLevel ?? ''}'),
                            Text('換水頻率：${profile.waterChangeFrequency} 天'),
                            Text('水體體積：${profile.waterVolume} 公升'),
                            Text('肥料種類：${profile.fertilizerType}' + (profile.fertilizerType == '自製肥料' && (profile.fertilizerDescription?.isNotEmpty ?? false) ? '（${profile.fertilizerDescription}）' : '')),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('編輯'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal[600],
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AlgaeProfileEditPage(profile: profile),
                                      ),
                                    );
                                    await _loadProfiles(); // 無論 result 為何都刷新
                                  },
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('刪除'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[400],
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => deleteProfile(index),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AlgaeProfileEditPage(),
            ),
          );
          await _loadProfiles(); // 無論 result 為何都刷新
        },
      ),
    );
  }
} 