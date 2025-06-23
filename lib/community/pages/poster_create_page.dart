import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'poster_result_page.dart';
import 'package:youthbuk/community/services/openai_api.dart';

class PosterCreatePage extends StatefulWidget {
  const PosterCreatePage({super.key});

  @override
  State<PosterCreatePage> createState() => _PosterCreatePageState();
}

class _PosterCreatePageState extends State<PosterCreatePage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _characterStyleInputController =
      TextEditingController();
  final TextEditingController _posterStyleInputController =
      TextEditingController();

  bool _isLoading = false;
  late final String openAiApiKey;

  final List<String> _characterStylesKR = [
    "애니메이션 캐릭터",
    "귀여운 캐릭터",
    "판타지 캐릭터",
    "만화 스타일 캐릭터",
    "슈퍼히어로 스타일 캐릭터",
    "미니멀리즘 스타일 캐릭터",
    "레트로 게임 스타일 캐릭터",
    "직접 입력...",
  ];

  final List<String> _characterStylesEN = [
    "bright and cute animated character",
    "cute cartoon style character",
    "fantasy wizard or fairy character",
    "classic cartoon style character",
    "superhero character",
    "minimalist style character",
    "retro pixel art character",
    "",
  ];

  final List<String> _posterStylesKR = [
    "감성 스타일",
    "모던 스타일",
    "레트로 스타일",
    "미니멀 스타일",
    "컬러풀 스타일",
    "직접 입력...",
  ];

  final List<String> _posterStylesEN = [
    "emotional style",
    "modern style",
    "retro style",
    "minimal style",
    "colorful style",
    "",
  ];

  String? _selectedCharacterKR;
  String? _selectedPosterKR;

  @override
  void initState() {
    super.initState();
    openAiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    _selectedCharacterKR = _characterStylesKR.first;
    _selectedPosterKR = _posterStylesKR.first;
  }

  Future<void> _createPoster() async {
    final userPrompt = _descriptionController.text.trim();
    final isCharacterCustom = _selectedCharacterKR == "직접 입력...";
    final characterStyle =
        isCharacterCustom
            ? _characterStyleInputController.text.trim()
            : _characterStylesEN[_characterStylesKR.indexOf(
              _selectedCharacterKR!,
            )];

    final isPosterCustom = _selectedPosterKR == "직접 입력...";
    final posterStyle =
        isPosterCustom
            ? _posterStyleInputController.text.trim()
            : _posterStylesEN[_posterStylesKR.indexOf(_selectedPosterKR!)];

    if (userPrompt.isEmpty || characterStyle.isEmpty || posterStyle.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 입력란을 채워주세요.')));
      return;
    }

    setState(() => _isLoading = true);

    const negativePrompt =
        "no text, no letters, no words, no logo, no watermark";
    final combinedPrompt =
        "$userPrompt, $characterStyle, $posterStyle, poster, high quality, $negativePrompt";

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
          builder: (_) => PosterResultPage(backgroundImageUrl: imageUrl),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('포스터 생성에 실패했습니다')));
    }
  }

  Widget _buildStyleSelector({
    required String label,
    required List<String> itemsKR,
    required String? selectedKR,
    required ValueChanged<String?> onChanged,
    required TextEditingController inputController,
    required bool showInputField,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        DropdownButtonFormField<String>(
          value: selectedKR,
          isExpanded: true,
          items:
              itemsKR
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        if (showInputField)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: TextField(
              controller: inputController,
              decoration: InputDecoration(
                labelText: '$label 직접 입력',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final showCharacterInput = _selectedCharacterKR == "직접 입력...";
    final showPosterInput = _selectedPosterKR == "직접 입력...";

    return Scaffold(
      appBar: AppBar(title: const Text('🎨 AI 홍보 포스터 생성')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStyleSelector(
                label: "캐릭터 스타일",
                itemsKR: _characterStylesKR,
                selectedKR: _selectedCharacterKR,
                onChanged: (v) => setState(() => _selectedCharacterKR = v),
                inputController: _characterStyleInputController,
                showInputField: showCharacterInput,
              ),
              const SizedBox(height: 24),
              _buildStyleSelector(
                label: "포스터 스타일",
                itemsKR: _posterStylesKR,
                selectedKR: _selectedPosterKR,
                onChanged: (v) => setState(() => _selectedPosterKR = v),
                inputController: _posterStyleInputController,
                showInputField: showPosterInput,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: '포스터 설명을 입력하세요',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createPoster,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 4,
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                            '✨ 포스터 생성하기',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
