import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'settings': 'Settings',
      'theme': 'Theme',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'theme_system': 'System',
      'font_size': 'Font Size',
      'font_small': 'Small',
      'font_medium': 'Medium (Default)',
      'font_large': 'Large',
      'language': 'Language',
      'about': 'About',
      'clear_data': 'Clear All Data',
      'clear_data_confirm': 'Are you sure you want to clear all data? This cannot be undone!',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'app_name': 'Algae Care App',
      'version': 'Version',
      'developer': 'Developer',

    },
    'zh': {
      'settings': '設定',
      'theme': '主題切換',
      'theme_light': '淺色模式',
      'theme_dark': '深色模式',
      'theme_system': '跟隨系統',
      'font_size': '字體大小',
      'font_small': '小',
      'font_medium': '中（預設）',
      'font_large': '大',
      'language': '語言切換',
      'about': '關於本 App',
      'clear_data': '一鍵清除所有資料',
      'clear_data_confirm': '確定要清除所有資料嗎？此操作無法復原！',
      'cancel': '取消',
      'confirm': '確定',
      'app_name': '微藻照護',
      'version': '版本',
      'developer': '開發者',

    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['zh']![key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
} 