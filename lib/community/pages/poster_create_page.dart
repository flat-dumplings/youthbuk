import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:youthbuk/community/services/openai_api.dart'; // generateImageInpainting 함수

import 'poster_result_page.dart';

class PosterCreatePage extends StatefulWidget {
  const PosterCreatePage({super.key});

  @override
  State<PosterCreatePage> createState() => _PosterCreatePageState();
}

class _PosterCreatePageState extends State<PosterCreatePage> {
  File? _selectedImage;
  File? _maskFile; // 인페인팅용 마스크 이미지 (흰색=변경, 검은색=유지)
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  late final String openAiApiKey;
  late final String removeBgApiKey;

  @override
  void initState() {
    super.initState();
    openAiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    removeBgApiKey = dotenv.env['REMOVE_BG_API_KEY'] ?? '';
    debugPrint('OpenAI API Key: $openAiApiKey');
    debugPrint('RemoveBG API Key: $removeBgApiKey');
  }

  // 원본 이미지 선택 → PNG 변환 → 배경제거 → 마스크 이미지 생성 → 크기 맞춤
  Future<void> _pickImageAndRemoveBg() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _isLoading = true;
      _maskFile = null;
    });

    // PNG 변환
    final pngFile = await _convertToPng(File(pickedFile.path));
    setState(() {
      _selectedImage = pngFile;
    });

    // 배경제거
    final removedBgFile = await _removeBackground(pngFile);
    if (removedBgFile == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('배경제거에 실패했습니다')));
      return;
    }

    // 배경제거된 이미지로 마스크 이미지 생성 (투명->검정, 불투명->흰색)
    final maskFile = await _createMaskFromTransparentImage(removedBgFile);
    if (maskFile == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('마스크 이미지 생성 실패')));
      return;
    }

    // 크기 맞춤
    final resizedMaskFile = await _resizeImageToMatch(
      maskFile,
      _selectedImage!,
    );

    setState(() {
      _maskFile = resizedMaskFile ?? maskFile;
      _isLoading = false;
    });
  }

  // PNG 변환 함수
  Future<File> _convertToPng(File inputFile) async {
    final bytes = await inputFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final outputFile = File('${dir.path}/converted.png');
    await outputFile.writeAsBytes(pngBytes);
    debugPrint('Converted image saved at: ${outputFile.path}');
    return outputFile;
  }

  // remove.bg API 호출
  Future<File?> _removeBackground(File originalImage) async {
    final url = Uri.parse('https://api.remove.bg/v1.0/removebg');
    final request = http.MultipartRequest('POST', url);
    request.headers['X-Api-Key'] = removeBgApiKey;
    request.files.add(
      await http.MultipartFile.fromPath('image_file', originalImage.path),
    );
    request.fields['size'] = 'auto';

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/removed_bg.png');
        await file.writeAsBytes(bytes);
        debugPrint('Background removal succeeded: saved to ${file.path}');
        return file;
      } else {
        final responseBody = await response.stream.bytesToString();
        debugPrint('Background removal failed: ${response.statusCode}');
        debugPrint('Response body: $responseBody');
        return null;
      }
    } catch (e) {
      debugPrint('Exception during background removal: $e');
      return null;
    }
  }

  // 투명 배경제거 이미지에서 흰/검 마스크 이미지 생성
  Future<File?> _createMaskFromTransparentImage(
    File transparentImageFile,
  ) async {
    try {
      final bytes = await transparentImageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final ui.Image image = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final paintWhite = Paint()..color = Colors.white;
      final paintBlack = Paint()..color = Colors.black;

      final width = image.width;
      final height = image.height;

      final pixelData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (pixelData == null) return null;

      // 캔버스 배경을 검정색으로 채움
      canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
        paintBlack,
      );

      final pixels = pixelData.buffer.asUint8List();

      // 각 픽셀의 알파 채널 확인해 흰색(불투명) 또는 검은색(투명) 칠하기
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final offset = (y * width + x) * 4;
          final alpha = pixels[offset + 3];
          if (alpha > 128) {
            // 불투명 영역: 흰색 점 찍기
            canvas.drawPoints(ui.PointMode.points, [
              Offset(x.toDouble(), y.toDouble()),
            ], paintWhite);
          }
          // 투명 영역은 검정색(배경) 그대로 둠
        }
      }

      final picture = recorder.endRecording();
      final maskImage = await picture.toImage(width, height);
      final byteData2 = await maskImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData2 == null) return null;

      final pngBytes = byteData2.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final maskFile = File('${dir.path}/mask_from_transparent.png');
      await maskFile.writeAsBytes(pngBytes);
      debugPrint('Mask image created: ${maskFile.path}');

      return maskFile;
    } catch (e) {
      debugPrint('Error creating mask image: $e');
      return null;
    }
  }

  // 마스크 이미지 원본 이미지 크기에 맞게 리사이징
  Future<File?> _resizeImageToMatch(File maskFile, File originalFile) async {
    try {
      final originalBytes = await originalFile.readAsBytes();
      final originalCodec = await ui.instantiateImageCodec(originalBytes);
      final originalFrame = await originalCodec.getNextFrame();
      final originalImage = originalFrame.image;

      final maskBytes = await maskFile.readAsBytes();
      final maskCodec = await ui.instantiateImageCodec(
        maskBytes,
        targetWidth: originalImage.width,
        targetHeight: originalImage.height,
      );
      final maskFrame = await maskCodec.getNextFrame();
      final resizedMaskImage = maskFrame.image;

      final byteData = await resizedMaskImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final pngBytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final resizedMaskFile = File('${dir.path}/resized_mask.png');
      await resizedMaskFile.writeAsBytes(pngBytes);
      debugPrint('Resized mask saved at: ${resizedMaskFile.path}');

      return resizedMaskFile;
    } catch (e) {
      debugPrint('Error resizing mask image: $e');
      return null;
    }
  }

  Future<void> _createPoster() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('원본 이미지를 선택해주세요')));
      return;
    }
    if (_maskFile == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('마스크 이미지가 없습니다')));
      return;
    }

    final prompt = _descriptionController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('포스터 설명을 입력해주세요')));
      return;
    }

    setState(() => _isLoading = true);

    final imageUrl = await generateImageInpainting(
      apiKey: openAiApiKey,
      image: _selectedImage!,
      mask: _maskFile!,
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
      ).showSnackBar(const SnackBar(content: Text('포스터 생성에 실패했습니다')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 인페인팅 포스터 만들기')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _pickImageAndRemoveBg,
              child: const Text('원본 이미지 선택 및 배경제거'),
            ),
            const SizedBox(height: 8),
            if (_selectedImage != null) ...[
              const Text('원본 이미지:'),
              const SizedBox(height: 8),
              Image.file(_selectedImage!, height: 200, fit: BoxFit.contain),
              const SizedBox(height: 16),
            ],
            if (_maskFile != null) ...[
              const Text('마스크 이미지 (대비확인용):'),
              const SizedBox(height: 8),
              Image.file(_maskFile!, height: 200, fit: BoxFit.contain),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '포스터 설명 입력',
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
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 140,
              height: 44,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _createPoster,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          '만들기',
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
    );
  }
}
