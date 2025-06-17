// ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  static final _openAiKey = dotenv.env['OPENAI_API_KEY'];

  // 텍스트 자동 생성: 체험 소개 + 특징
  static Future<Map<String, dynamic>> generateDescriptionAndFeatures({
    required String title,
    required String description,
  }) async {
    final prompt = """
당신은 친근하고 매력적인 체험 프로그램 홍보 문구 전문가입니다.

아래 제목과 설명을 참고해,
- 간결하고 매력적인 소개 문구 한 문장
- 특징 3~5개를 줄바꿈(-로 시작) 형식으로 작성해주세요

제목: $title
설명: $description
""";

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_openAiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "너는 체험 홍보 문구 생성 전문가야."},
          {"role": "user", "content": prompt},
        ],
      }),
    );

    final content =
        jsonDecode(response.body)['choices']?[0]?['message']?['content'] ?? '';

    final lines = content.split('\n');
    String intro = '';
    List<String> features = [];

    for (var line in lines) {
      line = line.trim();
      if (line.startsWith('소개:')) {
        intro = line.replaceFirst('소개:', '').trim();
      } else if (line.startsWith('-')) {
        features.add(line.replaceFirst('-', '').trim());
      }
    }

    return {'introduction': intro, 'features': features};
  }

  // 이미지 생성: 텍스트 프롬프트 기반
  static Future<String> generateImageFromText(String prompt) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: {
        'Authorization': 'Bearer $_openAiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "dall-e-3",
        "prompt": prompt,
        "n": 1,
        "size": "1024x1024",
      }),
    );

    final decoded = jsonDecode(response.body);
    if (decoded['data'] != null && decoded['data'].isNotEmpty) {
      return decoded['data'][0]['url'];
    }
    throw Exception("이미지 생성 실패");
  }
}
