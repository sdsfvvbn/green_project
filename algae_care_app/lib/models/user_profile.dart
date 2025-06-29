import 'package:flutter/material.dart';

class UserProfile extends ChangeNotifier {
  static final UserProfile instance = UserProfile._internal();
  factory UserProfile() => instance;
  UserProfile._internal();

  String nickname = '用戶';
  String email = 'algae@example.com';
  String bio = '熱愛微藻養殖，歡迎交流！';
  String? avatarPath;

  // 成就狀態
  final Set<String> unlockedBadges = {};

  // 統計數據
  int postCount = 0;
  int totalLikes = 0;
  int photoCount = 0;

  // 解鎖成就
  void unlockBadge(String badge) {
    if (unlockedBadges.add(badge)) {
      notifyListeners();
    }
  }

  // 更新統計
  void addPost() {
    postCount++;
    notifyListeners();
  }
  void addLike() {
    totalLikes++;
    notifyListeners();
  }
  void addPhoto() {
    photoCount++;
    notifyListeners();
  }

  // 編輯個人資料
  void updateProfile({String? nickname, String? email, String? bio, String? avatarPath}) {
    if (nickname != null) this.nickname = nickname;
    if (email != null) this.email = email;
    if (bio != null) this.bio = bio;
    if (avatarPath != null) this.avatarPath = avatarPath;
    notifyListeners();
  }
} 