import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AlgaeSettingsPage extends StatefulWidget {
  const AlgaeSettingsPage({super.key});

  @override
  State<AlgaeSettingsPage> createState() => _AlgaeSettingsPageState();
}

class _AlgaeSettingsPageState extends State<AlgaeSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _volumeController = TextEditingController();
  DateTime? _startDate;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _volumeController.text = (prefs.getDouble('algae_volume') ?? 1.0).toString();
      final millis = prefs.getInt('algae_start_date');
      if (millis != null) {
        _startDate = DateTime.fromMillisecondsSinceEpoch(millis);
      } else {
        _startDate = DateTime.now();
      }
    });
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate() || _startDate == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('algae_volume', double.parse(_volumeController.text));
    await prefs.setInt('algae_start_date', _startDate!.millisecondsSinceEpoch);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('設定已儲存')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '微藻養殖設定',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 6,
        centerTitle: true,
        leading: Icon(Icons.settings, size: 28),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('請輸入你的微藻養殖資訊：', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _volumeController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '養殖體積 (L)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.water_drop),
                ),
                validator: (v) {
                  final d = double.tryParse(v ?? '');
                  if (d == null || d <= 0) return '請輸入正確的體積';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: Colors.teal),
                  const SizedBox(width: 8),
                  const Text('開始養殖日期：', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(_startDate == null ? '未選擇' : '${_startDate!.year}/${_startDate!.month}/${_startDate!.day}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked;
                        });
                      }
                    },
                    child: const Text('選擇日期'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );
                    await _saveSettings();
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('設定已儲存')),
                    );
                  },
                  child: const Text('儲存設定'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 