import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../font_size_notifier.dart';
import '../l10n/app_localizations.dart';

import 'package:url_launcher/url_launcher.dart';
import '../services/database_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('settings')),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 6,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        children: [

          ListTile(
            leading: const Icon(Icons.format_size),
            title: Text(loc.get('font_size')),
            subtitle: Text('${loc.get('font_small')}/${loc.get('font_medium')}/${loc.get('font_large')}'),
            onTap: () => _showFontDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('意見回饋/報錯'),
            onTap: () => _showFeedbackDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(loc.get('clear_data'), style: const TextStyle(color: Colors.red)),
            onTap: () => _showClearDataDialog(context),
          ),
        ],
      ),
    );
  }

  

  void _showFontDialog(BuildContext context) {
    final fontNotifier = Provider.of<FontSizeNotifier>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('字體大小'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<AppFontSize>(
              title: const Text('小'),
              value: AppFontSize.small,
              groupValue: fontNotifier.fontSize,
              onChanged: (val) {
                fontNotifier.setFontSize(val!);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<AppFontSize>(
              title: const Text('中（預設）'),
              value: AppFontSize.medium,
              groupValue: fontNotifier.fontSize,
              onChanged: (val) {
                fontNotifier.setFontSize(val!);
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<AppFontSize>(
              title: const Text('大'),
              value: AppFontSize.large,
              groupValue: fontNotifier.fontSize,
              onChanged: (val) {
                fontNotifier.setFontSize(val!);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('意見回饋/報錯'),
        content: const Text('如果你有任何建議或遇到問題，歡迎來信反饋！'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('關閉')),
          ElevatedButton.icon(
            icon: const Icon(Icons.email),
            label: const Text('Email 反饋'),
            onPressed: () async {
              final uri = Uri(
                scheme: 'mailto',
                path: 'algaecaring2025@gmail.com',
                query: 'subject=微藻養殖APP意見回饋',
              );
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: '微藻養殖APP',
      applicationVersion: 'v1.0.0',
      applicationLegalese: '開發者：你的名字\n聯絡信箱：your@email.com',
    );
  }

  void _showClearDataDialog(BuildContext context) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.get('clear_data')),
        content: Text(loc.get('clear_data_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.get('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await DatabaseService.instance.clearAllData();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('資料已清除')),
              );
            },
            child: Text(loc.get('confirm')),
          ),
        ],
      ),
    );
  }
} 