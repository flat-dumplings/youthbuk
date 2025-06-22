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
  File? _maskImage; // 마스크 이미지 추가
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

  Future<void> _pickMaskImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _maskImage = File(pickedFile.path));
    }
  }

  Future<void> _createCharacter() async {
    if (_selectedImage == null || _maskImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('원본 이미지와 마스크 이미지를 모두 선택해주세요')),
      );
      return;
    }
    final prompt = _descriptionController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('설명을 입력해주세요')));
      return;
    }

    setState(() => _isLoading = true);

    final imageUrl = await generateImageInpainting(
      apiKey: openAiApiKey,
      image: _selectedImage!,
      mask: _maskImage!,
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

  Widget _buildImagePreview(File? image, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
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
              image != null
                  ? DecorationImage(image: FileImage(image), fit: BoxFit.cover)
                  : null,
        ),
        child:
            image == null
                ? Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마을만의 캐릭터 만들기 (인페인팅)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            _buildImagePreview(_selectedImage, '원본 이미지 선택 (탭)', _pickImage),
            const SizedBox(height: 16),
            _buildImagePreview(_maskImage, '마스크 이미지 선택 (탭)', _pickMaskImage),
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
