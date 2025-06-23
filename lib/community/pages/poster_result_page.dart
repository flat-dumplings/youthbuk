import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PosterResultPage extends StatefulWidget {
  final String backgroundImageUrl; // AI가 생성한 배경 이미지 URL

  const PosterResultPage({super.key, required this.backgroundImageUrl});

  @override
  State<PosterResultPage> createState() => _PosterResultPageState();
}

class _PosterResultPageState extends State<PosterResultPage> {
  bool _isSaving = false;

  Future<void> _saveImage() async {
    setState(() => _isSaving = true);

    // TODO: 실제 저장 로직 구현 (예: image_gallery_saver 패키지 활용)
    await Future.delayed(const Duration(seconds: 1)); // 임시 딜레이

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('저장이 완료되었습니다')));
  }

  Future<void> _shareImageLink() async {
    await Clipboard.setData(ClipboardData(text: widget.backgroundImageUrl));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('공유 링크가 복사되었습니다')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('포스터 결과'),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.network(
                widget.backgroundImageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child:
                        _isSaving
                            ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Colors.white,
                              ),
                            )
                            : const Text(
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
                    onPressed: _shareImageLink,
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
      backgroundColor: Colors.white,
    );
  }
}
