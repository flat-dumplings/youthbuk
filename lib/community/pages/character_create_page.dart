import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:youthbuk/community/pages/character_result_page.dart';
import 'package:youthbuk/community/services/openai_api.dart';

class CharacterCreatePage extends StatefulWidget {
  const CharacterCreatePage({super.key});

  @override
  State<CharacterCreatePage> createState() => _CharacterCreatePageState();
}

class _CharacterCreatePageState extends State<CharacterCreatePage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _customTypeController = TextEditingController();

  bool _isLoading = false;
  late final String openAiApiKey;

  final List<String> _characterTypesKR = [
    "애니메이션 캐릭터",
    "귀여운 캐릭터",
    "판타지 캐릭터",
    "만화 스타일 캐릭터",
    "슈퍼히어로 스타일 캐릭터",
    "미니멀리즘 스타일 캐릭터",
    "레트로 게임 스타일 캐릭터",
    "직접 입력...",
  ];

  final List<String> _characterTypesEN = [
    "bright and cute animated character",
    "cute cartoon style character",
    "fantasy wizard or fairy character",
    "classic cartoon style character",
    "superhero character",
    "minimalist style character",
    "retro pixel art character",
    "",
  ];

  String? _selectedTypeKR;

  @override
  void initState() {
    super.initState();
    openAiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    _selectedTypeKR = _characterTypesKR.first;
    _customTypeController.text = "";
  }

  Future<void> _createCharacter() async {
    final userPrompt = _descriptionController.text.trim();

    final isCustom = _selectedTypeKR == "직접 입력...";
    final characterTypeEN =
        isCustom
            ? _customTypeController.text.trim()
            : _characterTypesEN[_characterTypesKR.indexOf(_selectedTypeKR!)];

    if (userPrompt.isEmpty || characterTypeEN.isEmpty) {
      final message =
          userPrompt.isEmpty ? '캐릭터 설명을 입력해주세요' : '캐릭터 유형을 입력하거나 선택해주세요';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    setState(() => _isLoading = true);

    const negativePrompt =
        "no text, no letters, no words, no logo, no watermark, no background, no objects, character only";

    final combinedPrompt = "$userPrompt, $characterTypeEN, $negativePrompt";

    final imageUrl = await generateImageFromText(
      apiKey: openAiApiKey,
      prompt: combinedPrompt,
      size: "1024x1024",
      n: 1,
    );

    setState(() => _isLoading = false);

    if (imageUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => CharacterResultPage(
                imageUrl: imageUrl,
                description: combinedPrompt,
              ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('캐릭터 생성에 실패했습니다')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final showCustomInput = _selectedTypeKR == "직접 입력...";

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 캐릭터 생성기'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF4F5F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "캐릭터 스타일",
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedTypeKR,
              items:
                  _characterTypesKR
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTypeKR = value;
                  if (value != "직접 입력...") {
                    _customTypeController.clear();
                  }
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            if (showCustomInput) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customTypeController,
                decoration: InputDecoration(
                  labelText: "직접 입력",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '캐릭터 설명을 입력하세요',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createCharacter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                        : const Text(
                          '캐릭터 생성하기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
