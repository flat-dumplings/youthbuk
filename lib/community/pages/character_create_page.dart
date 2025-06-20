import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:youthbuk/community/services/openai_api.dart';
import 'poster_result_page.dart';

class CharacterCreatePage extends StatefulWidget {
  const CharacterCreatePage({super.key});

  @override
  State<CharacterCreatePage> createState() => _CharacterCreatePageState();
}

class _CharacterCreatePageState extends State<CharacterCreatePage> {
  File? _selectedImage;
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  late final String openAiApiKey;

  @override
  void initState() {
    super.initState();
    openAiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<void> _createCharacter() async {
    final prompt = _descriptionController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('설명을 입력해주세요')));
      return;
    }

    setState(() => _isLoading = true);

    final imageUrl = await generateImageOpenAI(
      apiKey: openAiApiKey,
      prompt: prompt,
      size: "1024x1024",
    );

    setState(() => _isLoading = false);

    if (imageUrl != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => PosterResultPage(imageUrl: imageUrl, description: prompt),
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
    return Scaffold(
      appBar: AppBar(title: const Text('마을만의 캐릭터 만들기')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image:
                      _selectedImage != null
                          ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    _selectedImage == null
                        ? const Center(
                          child: Text(
                            '이미지 선택 (탭)',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '캐릭터 설명 입력',
                filled: true,
                fillColor: Colors.grey[100],
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
            const SizedBox(height: 40),
            SizedBox(
              width: 140,
              height: 44,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createCharacter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 4,
                  shadowColor: Colors.purpleAccent.withOpacity(0.4),
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
                          '만들기',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
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
