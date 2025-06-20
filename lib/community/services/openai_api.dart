// openai_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> generateImageOpenAI({
  required String apiKey,
  required String prompt,
  int n = 1,
  String size = "512x512",
}) async {
  final url = Uri.parse("https://api.openai.com/v1/images/generations");

  final headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  final body = jsonEncode({
    "model": "dall-e-3",
    "prompt": prompt,
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
