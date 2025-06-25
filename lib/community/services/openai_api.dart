// openai_api.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

Future<String?> generateImageInpainting({
  required String apiKey,
  required File image,
  required File mask,
  required String prompt,
  int n = 1,
  String size = "1024x1024",
  String model = 'dall-e-3',
}) async {
  final url = Uri.parse("https://api.openai.com/v1/images/edits");
  final request = http.MultipartRequest('POST', url);

  request.headers['Authorization'] = 'Bearer $apiKey';
  request.fields['model'] = model;
  request.fields['prompt'] = prompt;
  request.fields['n'] = n.toString();
  request.fields['size'] = size;

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

  try {
    final streamedResponse = await request.send();
    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      final data = json.decode(responseBody);
      return data['data'][0]['url'] as String?;
    } else {
      print('OpenAI API error: ${streamedResponse.statusCode} $responseBody');
      return null;
    }
  } catch (e, st) {
    print('Error calling OpenAI API: $e\n$st');
    return null;
  }
}

Future<String?> generateImageFromText({
  required String apiKey,
  required String prompt,
  int n = 1,
  String size = "1024x1024",
  String model = 'dall-e-3',
  String? negativePrompt,
}) async {
  final url = Uri.parse('https://api.openai.com/v1/images/generations');

  final body = {'model': model, 'prompt': prompt, 'n': n, 'size': size};

  if (negativePrompt != null && negativePrompt.isNotEmpty) {
    body['negative_prompt'] = negativePrompt;
  }

  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    body: json.encode(body),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['data'][0]['url'] as String?;
  } else {
    print('OpenAI API error: ${response.statusCode} ${response.body}');
    return null;
  }
}
