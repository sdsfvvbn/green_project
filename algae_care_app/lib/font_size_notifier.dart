import 'package:flutter/material.dart';

enum AppFontSize { small, medium, large }

class FontSizeNotifier extends ChangeNotifier {
  AppFontSize _fontSize = AppFontSize.medium;
  AppFontSize get fontSize => _fontSize;

  double get scale {
    switch (_fontSize) {
      case AppFontSize.small:
        return 0.9;
      case AppFontSize.medium:
        return 1.0;
      case AppFontSize.large:
        return 1.2;
    }
  }

  void setFontSize(AppFontSize size) {
    _fontSize = size;
    notifyListeners();
  }
} 