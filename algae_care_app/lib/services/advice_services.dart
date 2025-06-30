import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/algae_log.dart';

class AdviceService {
  final String _apiKey = 'AIzaSyCCu3VBgu9nzFUmAGG9byNeAwPAYO8mM3o';

  // 根據日誌資料產生建議
  Future<String> getAdvice(List<AlgaeLog> logs) async {
    // 這裡可以根據 logs 分析產生建議，暫時回傳假資料
    await Future.delayed(const Duration(milliseconds: 300));
    return '建議：保持水質清澈，適時調整光照。';
  }

  // 計算吸碳量
  Future<double> calculateCarbonSequestration(List<AlgaeLog> logs) async {
    // 這裡可以根據 logs 計算吸碳量，暫時回傳假資料
    await Future.delayed(const Duration(milliseconds: 300));
    return 12.34;
  }

  // 取得成長曲線資料
  Future<List<double>> getGrowthData(List<AlgaeLog> logs) async {
    // 這裡可以根據 logs 產生成長曲線資料，暫時回傳假資料
    await Future.delayed(const Duration(milliseconds: 300));
    return [1, 2, 3, 4, 5, 6, 7];
  }

  Future<String> getAdviceFromGemini(List<AlgaeLog> logs) async {
    // 把 logs 轉成文字描述
    String prompt = '以下是我的海藻日誌資料：\n';
    for (var log in logs) {
      prompt += '日期: ${log.date}, 溫度: ${log.temperature}, 水色: ${log.waterColor}\n';
    }
    prompt += '請根據這些資料給我一個養殖建議。';

    final url = Uri.parse('https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$_apiKey');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ]
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // 解析 Gemini 回傳的建議
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      return '取得建議失敗：${response.body}';
    }
  }
}
