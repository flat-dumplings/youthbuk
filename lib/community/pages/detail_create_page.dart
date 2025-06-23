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

  File? backgroundImageFile; // 유저가 직접 선택한 배경 이미지 파일

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
    return weekdaySelected.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .join('');
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

  Future<void> _pickBackgroundImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        backgroundImageFile = File(pickedFile.path);
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
              onPressed: _pickBackgroundImage,
              icon: const Icon(Icons.image_outlined),
              label: const Text('배경 이미지 직접 선택'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade100,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (backgroundImageFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    backgroundImageFile!,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('체험 사진 선택 (최대 4장)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange.shade100,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  selectedImages
                      .take(4)
                      .map(
                        (file) => ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  backgroundColor: Colors.deepOrange.shade200,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
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

  Widget _buildInputField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '기간 선택',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade100,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
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
        const Text(
          '가능 요일 선택',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ElevatedButton(
              onPressed:
                  () => _toggleAll(!weekdaySelected.values.every((v) => v)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('전체'),
            ),
            ElevatedButton(
              onPressed: _toggleWeekend,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('주말'),
            ),
            ElevatedButton(
              onPressed: _toggleWeekday,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
                  selectedColor: Colors.orange.shade300,
                  backgroundColor: Colors.grey.shade200,
                  onSelected: (bool value) {
                    setState(() {
                      weekdaySelected[day] = value;
                    });
                  },
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
