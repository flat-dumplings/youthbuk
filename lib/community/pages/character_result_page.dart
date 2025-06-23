import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CharacterResultPage extends StatefulWidget {
  final String imageUrl;
  final String description;

  const CharacterResultPage({
    super.key,
    required this.imageUrl,
    required this.description,
  });

  @override
  State<CharacterResultPage> createState() => _CharacterResultPageState();
}

class _CharacterResultPageState extends State<CharacterResultPage> {
  late final String removeBgApiKey;
  File? _bgRemovedImageFile;
  bool _isRemovingBg = false;
  bool _isBgRemoved = false; // 배경제거 완료 상태 체크

  @override
  void initState() {
    super.initState();
    removeBgApiKey = dotenv.env['REMOVE_BG_API_KEY'] ?? '';
  }

  Future<void> _removeBackground() async {
    if (_isBgRemoved) return; // 이미 배경제거 했으면 무시

    setState(() {
      _isRemovingBg = true;
      _bgRemovedImageFile = null;
    });

    try {
      final response = await http.get(Uri.parse(widget.imageUrl));
      if (response.statusCode != 200) throw Exception('이미지 다운로드 실패');

      final bytes = response.bodyBytes;
      final dir = await getTemporaryDirectory();
      final tempFile = File('${dir.path}/temp_image.png');
      await tempFile.writeAsBytes(bytes);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.remove.bg/v1.0/removebg'),
      );
      request.headers['X-Api-Key'] = removeBgApiKey;
      request.files.add(
        await http.MultipartFile.fromPath('image_file', tempFile.path),
      );
      request.fields['size'] = 'auto';

      final res = await request.send();
      if (res.statusCode == 200) {
        final resBytes = await res.stream.toBytes();
        final outputFile = File(
          '${dir.path}/bg_removed_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        await outputFile.writeAsBytes(resBytes);
        setState(() {
          _bgRemovedImageFile = outputFile;
          _isRemovingBg = false;
          _isBgRemoved = true;
        });
      } else {
        throw Exception('배경제거 실패: 상태 코드 ${res.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isRemovingBg = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('배경제거 실패: $e')));
    }
  }

  Future<void> _saveImage() async {
    // 저장 로직 예시 (플랫폼별로 적절히 구현 필요)
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('저장이 완료되었습니다')));
  }

  Future<void> _shareImageLink() async {
    // 공유 로직 예시 (클립보드 복사만 구현)
    await Clipboard.setData(ClipboardData(text: widget.imageUrl));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('공유 링크가 복사되었습니다')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캐릭터 결과'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(0), // 패딩 제거해서 꽉 찬 화면
        child: Column(
          children: [
            Expanded(
              child: Center(
                child:
                    _isRemovingBg
                        ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.purple.shade300,
                            ),
                            const SizedBox(height: 16),
                            const Text('배경제거 중입니다...'),
                          ],
                        )
                        : _bgRemovedImageFile != null
                        ? Image.file(
                          _bgRemovedImageFile!,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        )
                        : Image.network(
                          widget.imageUrl,
                          fit: BoxFit.contain,
                          width: double.infinity,
                          height: double.infinity,
                        ),
              ),
            ),
            const SizedBox(height: 8),

            // 배경제거 버튼 한 줄
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                      _isRemovingBg || _isBgRemoved ? null : _removeBackground,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Text(
                    '배경제거하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 저장하기, 공유하기 버튼 한 줄
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _bgRemovedImageFile != null ? _saveImage : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text(
                        '저장하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _bgRemovedImageFile != null ? _shareImageLink : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text(
                        '공유하기',
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

            const SizedBox(height: 24),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
