import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  static final _openAiKey = dotenv.env['OPENAI_API_KEY'];

  static Future<String> translateToEnglish(String korText) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Authorization': 'Bearer $_openAiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "You are a translator."},
          {
            "role": "user",
            "content":
                "Translate this to natural English for an AI image prompt: '$korText'",
          },
        ],
      }),
    );
    return jsonDecode(response.body)['choices'][0]['message']['content'].trim();
  }

  static Future<List<String>> generateImagesFromText({
    required String title,
    required String description,
  }) async {
    final translatedPrompt = await translateToEnglish(
      "$title, $description, 농촌 체험, 자연, 귀엽고 따뜻한 일러스트 스타일",
    );

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: {
        'Authorization': 'Bearer $_openAiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "dall-e-3",
        "prompt": translatedPrompt,
        "n": 1,
        "size": "1024x1024",
      }),
    );

    final decoded = jsonDecode(response.body);
    if (decoded['data'] == null) {
      print("⚠️ 이미지 생성 실패: ${response.body}");
      throw Exception('AI 이미지 생성 실패');
    }

    return List<String>.from(decoded['data'].map((d) => d['url']));
  }

  static Future<List<String>> generateHtmlCardPages({
    required String title,
    required String description,
    required List<String> features,
    required String themeColor,
    String tone = "귀엽고 보기 쉬운 스타일",
  }) async {
    final featureText = features.map((f) => "- $f").join("\n");

    final prompt = """
당신은 인스타그램 카드뉴스 전문 디자이너입니다.

아래 정보를 바탕으로 4~6개의 서로 다른 스타일의 HTML 카드뉴스를 만들어주세요.
- 각 페이지는 명확한 메시지를 갖고, 디자인적으로 분리되어야 합니다.
- 각 페이지는 인스타 카드뉴스처럼 세련되고 시각적으로 눈에 띄어야 합니다.
- 각 HTML은 독립된 <html><head><style>...</style></head><body>...</body></html> 구조여야 합니다.
- 예쁜 폰트, 넓은 마진, 컬러 강조, 레이아웃 분리 등을 꼭 활용하세요.
- 이미지 없이 HTML + CSS만으로 구성하세요.
- 전체 레이아웃은 3:4 비율로 가정하고 만들어주세요. (예: 900x1200px)

정보:
- 제목: $title
- 설명: $description
- 주요 항목:
$featureText
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
          {
            "role": "system",
            "content": "너는 HTML 기반 카드뉴스 디자이너야. 설명 없이 HTML 코드들만 반환해.",
          },
          {"role": "user", "content": prompt},
        ],
      }),
    );

    final content =
        jsonDecode(response.body)['choices'][0]['message']['content']
            .replaceAll('```html', '')
            .replaceAll('```', '')
            .trim();

    final List<String> pages =
        content
            .split(RegExp(r'</html>\s*<html>'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .map((e) => e.startsWith('<html>') ? e : '<html>$e</html>')
            .toList();

    return pages;
  }
}
