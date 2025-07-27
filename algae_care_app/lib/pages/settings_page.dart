import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../font_size_notifier.dart';
import '../l10n/app_localizations.dart';



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

          // 已移除一鍵清除所有資料功能
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




} 