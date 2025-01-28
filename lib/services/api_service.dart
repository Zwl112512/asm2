import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String? _apiKey = dotenv.env['DEEPSEEK_API_KEY'];
  static final String? _apiUrl = dotenv.env['DEEPSEEK_API_URL'];

  static Future<String> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse(_apiUrl!),
      headers: {
        'Content-Type': 'application/json; charset=utf-8', // 确保使用 UTF-8
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'deepseek-chat',
        'messages': [
          {'role': 'user', 'content': message}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final rawContent = data['choices'][0]['message']['content'] ?? "No response from bot.";
      return sanitizeText(rawContent);
    } else {
      throw Exception('Failed to load response: ${response.body}');
    }
  }

  // 清理特殊字符的方法
  static String sanitizeText(String text) {
    // 使用正则表达式移除不可见字符或将其替换为空格
    return text.replaceAll(RegExp(r'[^\x20-\x7E]'), '').trim();
  }
}
