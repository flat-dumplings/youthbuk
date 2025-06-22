import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // contentType 지정용

Future<String?> generateImageInpainting({
  required String apiKey,
  required File image,
  required File mask,
  required String prompt,
  int n = 1,
  String size = "1024x1024",
}) async {
  final url = Uri.parse("https://api.openai.com/v1/images/edits");

  final request = http.MultipartRequest('POST', url);

  // 헤더에 API 키 포함
  request.headers['Authorization'] = 'Bearer $apiKey';

  // 부정 조건 제거: 프롬프트를 단순하게 유지
  final modifiedPrompt = prompt;

  request.fields['model'] = 'dall-e-2'; // 현재 인페인팅 지원 모델
  request.fields['prompt'] = modifiedPrompt;
  request.fields['n'] = n.toString();
  request.fields['size'] = size;

  // 파일 첨부 (image, mask) — contentType 꼭 지정
  request.files.add(
    await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType('image', 'png'),
    ),
  );
  request.files.add(
    await http.MultipartFile.fromPath(
      'mask',
      mask.path,
      contentType: MediaType('image', 'png'),
    ),
  );

  // 디버깅용 출력
  print('Prompt: $modifiedPrompt');
  print('Image path: ${image.path}');
  print('Mask path: ${mask.path}');

  try {
    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      final data = json.decode(responseBody);
      // 생성된 이미지 URL 반환
      return data['data'][0]['url'] as String?;
    } else {
      print('OpenAI API error: ${streamedResponse.statusCode} $responseBody');
      return null;
    }
  } catch (e) {
    print('Error calling OpenAI API: $e');
    return null;
  }
}
