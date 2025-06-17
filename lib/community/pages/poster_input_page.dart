import 'package:flutter/material.dart';
import 'package:youthbuk/community/services/ai_service.dart';
import 'poster_result_page.dart';

class PosterInputPage extends StatefulWidget {
  const PosterInputPage({super.key});

  @override
  State<PosterInputPage> createState() => _PosterInputPageState();
}

class _PosterInputPageState extends State<PosterInputPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _featureController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  bool _loading = false;

  Future<void> _onGenerate() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final features =
        _featureController.text.trim().split(',').map((f) => f.trim()).toList();
    final themeColor =
        _colorController.text.trim().isEmpty
            ? "#6cc37d"
            : _colorController.text.trim();

    if (title.isEmpty || description.isEmpty || features.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("모든 필드를 입력해주세요.")));
      return;
    }

    setState(() => _loading = true);

    try {
      final htmlPages = await AiService.generateHtmlCardPages(
        title: title,
        description: description,
        features: features,
        themeColor: themeColor,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PosterResultPage(htmlPages: htmlPages),
        ),
      );
    } catch (e) {
      print('❌ HTML 생성 오류: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 카드뉴스 생성기')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '설명 문구',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _featureController,
              decoration: const InputDecoration(
                labelText: '특징 목록 (쉼표로 구분)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: '테마 색상 (예: #6cc37d)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _onGenerate,
                  child: const Text('카드뉴스 바로 생성'),
                ),
          ],
        ),
      ),
    );
  }
}
