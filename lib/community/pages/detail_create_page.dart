import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenv import
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'experience_preview_page.dart';

class DetailCreatePage extends StatefulWidget {
  const DetailCreatePage({super.key});

  @override
  State<DetailCreatePage> createState() => _DetailCreatePageState();
}

class _DetailCreatePageState extends State<DetailCreatePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController villageController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController peopleController = TextEditingController();

  DateTimeRange? selectedDateRange;

  bool isLoading = false;
  Map<String, dynamic> aiData = {};
  List<File> selectedImages = [];

  String? dallEImageUrl;

  // 요일 선택 상태 (월~일)
  final Map<String, bool> weekdaySelected = {
    '월': false,
    '화': false,
    '수': false,
    '목': false,
    '금': false,
    '토': false,
    '일': false,
  };

  void _toggleAll(bool selectAll) {
    setState(() {
      for (var day in weekdaySelected.keys) {
        weekdaySelected[day] = selectAll;
      }
    });
  }

  void _toggleWeekend() {
    setState(() {
      weekdaySelected['토'] = !(weekdaySelected['토'] ?? false);
      weekdaySelected['일'] = !(weekdaySelected['일'] ?? false);
    });
  }

  void _toggleWeekday() {
    setState(() {
      for (var day in ['월', '화', '수', '목', '금']) {
        weekdaySelected[day] = !(weekdaySelected[day] ?? false);
      }
    });
  }

  String _buildSelectedWeekdaysString() {
    String days = weekdaySelected.entries
        .where((entry) => entry.value)
        .map((e) => e.key)
        .join('');
    return days.isEmpty ? '' : days;
  }

  String _getSelectedPeriod() {
    if (selectedDateRange != null) {
      return '${selectedDateRange!.start.year}.${selectedDateRange!.start.month}.${selectedDateRange!.start.day} ~ '
          '${selectedDateRange!.end.year}.${selectedDateRange!.end.month}.${selectedDateRange!.end.day}';
    } else {
      return '미선택';
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        selectedImages = pickedFiles.map((e) => File(e.path)).toList();
      });
    }
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      initialDateRange: selectedDateRange,
    );
    if (picked != null) {
      setState(() => selectedDateRange = picked);
    }
  }

  Future<String> _uploadFileToFirebase(File file, String folder) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final ref = FirebaseStorage.instance.ref().child('$folder/$fileName');
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<String> _generateImageWithDallE(String prompt) async {
    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${dotenv.env['OPENAI_API_KEY']}',
      },
      body: jsonEncode({
        'model': 'dall-e-3',
        'prompt': prompt,
        'n': 1,
        'size': '1024x1024',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('DALL·E 이미지 생성 실패: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['data'][0]['url'];
  }

  Future<void> _generateDetailPage() async {
    setState(() {
      isLoading = true;
      dallEImageUrl = null;
    });

    final period = _getSelectedPeriod();
    final weekdays = _buildSelectedWeekdaysString();

    final posterPrompt =
        '${titleController.text} rural village landscape, minimalistic, soft pastel colors, simple background without text or people, clean and clear for overlay text';

    try {
      final generatedImageUrl = await _generateImageWithDallE(posterPrompt);

      final userMessage = '''
체험명: ${titleController.text}
마을명: ${villageController.text}
비용: ${priceController.text}
기간: $period
가능 요일: $weekdays
인원: ${peopleController.text}

다음 정보를 JSON 형식으로 정확하게 key와 value 쌍으로만 만들어줘:
{
  "main_title": "",
  "info_price": "",
  "info_time": "",
  "info_participants": "",
  "refund_policy": "",
  "extra_comment": "",
  "village_name": "",
  "promo_message": "",
  "possible_days": "$weekdays",
  "background_image_url": "$generatedImageUrl"
}
''';

      final response = await http.post(
        Uri.parse("https://api.anthropic.com/v1/messages"),
        headers: {
          "x-api-key": dotenv.env['CLAUDE_API_KEY'] ?? '',
          "Content-Type": "application/json",
          "anthropic-version": "2023-06-01",
        },
        body: jsonEncode({
          "model": "claude-3-opus-20240229",
          "messages": [
            {"role": "user", "content": userMessage},
          ],
          "max_tokens": 700,
          "temperature": 0.7,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Claude API 요청 실패: ${response.body}');
      }

      final utf8Body = utf8.decode(response.bodyBytes);
      final data = jsonDecode(utf8Body);
      final completionText = data['content']?[0]?['text'] as String? ?? '';

      Map<String, dynamic> jsonResult = {};
      try {
        jsonResult = jsonDecode(completionText);
      } catch (_) {
        jsonResult = {};
      }

      final result = <String, dynamic>{
        'main_title': jsonResult['main_title']?.toString() ?? '',
        'info_price': jsonResult['info_price']?.toString() ?? '',
        'info_time': jsonResult['info_time']?.toString() ?? '',
        'info_participants': jsonResult['info_participants']?.toString() ?? '',
        'refund_policy': jsonResult['refund_policy']?.toString() ?? '',
        'extra_comment': jsonResult['extra_comment']?.toString() ?? '',
        'village_name': jsonResult['village_name']?.toString() ?? '',
        'promo_message': jsonResult['promo_message']?.toString() ?? '',
        'possible_days': jsonResult['possible_days']?.toString() ?? weekdays,
        'background_image_url': generatedImageUrl,
      };

      result['poster_url'] = generatedImageUrl;

      final galleryImageUrls =
          selectedImages.isNotEmpty
              ? await Future.wait(
                selectedImages.map(
                  (file) => _uploadFileToFirebase(file, 'gallery'),
                ),
              )
              : [generatedImageUrl];

      setState(() {
        aiData = result;
        dallEImageUrl = generatedImageUrl;
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ExperiencePreviewPage(
                aiData: result,
                mainImageUrl: generatedImageUrl,
                galleryImageUrls: galleryImageUrls,
              ),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    }
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('기간 선택', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _selectDateRange,
          icon: const Icon(Icons.calendar_month_outlined),
          label: Text(
            selectedDateRange == null
                ? '날짜 범위 선택'
                : '${selectedDateRange!.start.year}.${selectedDateRange!.start.month}.${selectedDateRange!.start.day} ~ '
                    '${selectedDateRange!.end.year}.${selectedDateRange!.end.month}.${selectedDateRange!.end.day}',
          ),
        ),
        const SizedBox(height: 16),
        const Text('가능 요일 선택', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    weekdaySelected.values.every((v) => v)
                        ? Colors.deepOrange.shade400
                        : null,
              ),
              onPressed:
                  () => _toggleAll(!weekdaySelected.values.every((v) => v)),
              child: const Text('전체'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    weekdaySelected['토'] == true && weekdaySelected['일'] == true
                        ? Colors.deepOrange.shade400
                        : null,
              ),
              onPressed: _toggleWeekend,
              child: const Text('주말'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    weekdaySelected.entries
                            .where(
                              (e) => ['월', '화', '수', '목', '금'].contains(e.key),
                            )
                            .every((e) => e.value)
                        ? Colors.deepOrange.shade400
                        : null,
              ),
              onPressed: _toggleWeekday,
              child: const Text('평일'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          children:
              weekdaySelected.keys.map((day) {
                final selected = weekdaySelected[day]!;
                return FilterChip(
                  label: Text(day),
                  selected: selected,
                  showCheckmark: false,
                  selectedColor: Colors.deepOrange.shade200,
                  onSelected: (bool value) {
                    setState(() {
                      weekdaySelected[day] = value;
                    });
                  },
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: Colors.grey.shade200,
                );
              }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 상세페이지 생성')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputField('체험명', titleController),
            _buildInputField('마을명', villageController),
            _buildInputField('비용', priceController),
            _buildInputField('인원', peopleController),
            const SizedBox(height: 16),
            _buildPeriodSelector(),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('체험 사진 선택 (최대 4장)'),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  selectedImages
                      .take(4)
                      .map(
                        (file) => Image.file(
                          file,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : _generateDetailPage,
                child:
                    isLoading
                        ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Text('AI로 생성하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
