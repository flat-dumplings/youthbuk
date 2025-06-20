import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> generateImageOpenAI({
  required String apiKey,
  required String prompt,
  int n = 1,
  String size = "1024x1024",
}) async {
  final url = Uri.parse("https://api.openai.com/v1/images/generations");

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  // 텍스트 포함 안 하도록 부정 조건 추가
  final modifiedPrompt =
      "$prompt, no text, no letters, no words, no characters";

  final body = jsonEncode({
    "model": "dall-e-3",
    "prompt": modifiedPrompt,
    "n": n,
    "size": size,
  });

  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'][0]['url'];
    } else {
      print('OpenAI API error: ${response.statusCode} ${response.body}');
      return null;
    }
  } catch (e) {
    print('Error calling OpenAI API: $e');
    return null;
  }
}
