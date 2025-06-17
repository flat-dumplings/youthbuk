import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PosterInputPage extends StatefulWidget {
  const PosterInputPage({super.key});

  @override
  State<PosterInputPage> createState() => _PosterInputPageState();
}

class _PosterInputPageState extends State<PosterInputPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _templates = ['fall_1.jpg', 'fall_2.jpg', 'fall_3.jpg'];
  String? _selectedTemplate;

  bool _loading = false;
  String? _generatedTitle;
  String? _generatedSubtitle;
  String? _posterUrl;

  // OpenAI 이미지 생성 API 호출: 텍스트 프롬프트를 받아 이미지 URL 반환
  Future<String> _generateAiImageUrl(String prompt) async {
    const openAiApiKey = 'YOUR_OPENAI_API_KEY'; // 반드시 안전하게 관리하세요!

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: {
        'Authorization': 'Bearer $openAiApiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "model": "dall-e-3",
        "prompt": prompt,
        "n": 1,
        "size": "1024x1024",
      }),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['data'] != null && decoded['data'].isNotEmpty) {
        return decoded['data'][0]['url'];
      } else {
        throw Exception('이미지 생성 데이터가 없습니다.');
      }
    } else {
      throw Exception('이미지 생성 API 오류: ${response.statusCode}');
    }
  }

  Future<void> _generatePoster() async {
    final titlePrompt = _titleController.text.trim();
    final subtitlePrompt = _descriptionController.text.trim();

    if (titlePrompt.isEmpty ||
        subtitlePrompt.isEmpty ||
        _selectedTemplate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목, 설명, 템플릿을 모두 입력해주세요')));
      return;
    }

    setState(() {
      _loading = true;
      _generatedTitle = null;
      _generatedSubtitle = null;
      _posterUrl = null;
    });

    try {
      // AI 이미지 URL 생성 (제목을 프롬프트로 사용)
      final aiImageUrl = await _generateAiImageUrl(titlePrompt);

      final url = Uri.parse(
        'https://us-central1-youthbuk-ba603.cloudfunctions.net/createPoster',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titlePrompt': titlePrompt,
          'subtitlePrompt': subtitlePrompt,
          'aiImageUrl': aiImageUrl,
          'templateFileName': _selectedTemplate,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _generatedTitle = data['generatedTitle'];
          _generatedSubtitle = data['generatedSubtitle'];
          _posterUrl = data['posterUrl'];
        });
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 포스터 생성')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '포스터 제목 입력',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '포스터 부제 입력',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '템플릿 선택',
                  border: OutlineInputBorder(),
                ),
                value: _selectedTemplate,
                items:
                    _templates
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedTemplate = val;
                  });
                },
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _generatePoster,
                    child: const Text('포스터 생성하기'),
                  ),
              const SizedBox(height: 30),
              if (_posterUrl != null)
                Stack(
                  children: [
                    Image.network(_posterUrl!),
                    if (_generatedTitle != null)
                      Positioned(
                        left: 50,
                        top: 30,
                        child: Text(
                          _generatedTitle!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            shadows: [
                              Shadow(blurRadius: 2, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    if (_generatedSubtitle != null)
                      Positioned(
                        left: 50,
                        top: 70,
                        child: Text(
                          _generatedSubtitle!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            shadows: [
                              Shadow(blurRadius: 1, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
