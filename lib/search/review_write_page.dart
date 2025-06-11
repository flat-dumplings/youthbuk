// lib/search/pages/review_write_page.dart

import 'package:flutter/material.dart';
import 'package:youthbuk/search/services/review_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youthbuk/search/models/review_model.dart';

class ReviewWritePage extends StatefulWidget {
  final String villageName;
  final Review? existingReview; // 수정 모드일 때 리뷰 객체 전달

  const ReviewWritePage({
    super.key,
    required this.villageName,
    this.existingReview,
  });

  @override
  State<ReviewWritePage> createState() => _ReviewWritePageState();
}

class _ReviewWritePageState extends State<ReviewWritePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  int _star = 0;
  bool _isSubmitting = false;

  List<String> _hashtags = [];

  @override
  void initState() {
    super.initState();
    // 수정 모드라면 기존 값으로 초기화
    if (widget.existingReview != null) {
      final rev = widget.existingReview!;
      _titleController = TextEditingController(text: rev.title ?? '');
      _contentController.text = rev.content;
      _star = rev.star.toInt();
      _hashtags = rev.hashtags != null ? List.from(rev.hashtags!) : [];
    } else {
      _titleController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Widget _buildStarSelector() {
    return Row(
      children: List.generate(5, (index) {
        final idx = index + 1;
        return IconButton(
          onPressed: () {
            setState(() {
              _star = idx;
            });
          },
          icon: Icon(
            idx <= _star ? Icons.star : Icons.star_border,
            color: Colors.orange,
          ),
        );
      }),
    );
  }

  void _addHashtag() {
    final text = _tagController.text.trim();
    if (text.isEmpty) return;
    if (text.contains(' ')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('해시태그에는 공백을 포함할 수 없습니다.')));
      return;
    }
    if (_hashtags.contains(text)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미 추가된 해시태그입니다.')));
      return;
    }
    setState(() {
      _hashtags.add(text);
      _tagController.clear();
    });
  }

  Future<void> _submitReview() async {
    if (_isSubmitting) return;
    if (_star == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('별점을 선택해주세요.')));
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('리뷰 내용을 입력해주세요.')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final reviewService = ReviewService();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      final titleText =
          _titleController.text.trim().isNotEmpty
              ? _titleController.text.trim()
              : null;
      final hashtags = _hashtags.isNotEmpty ? _hashtags : null;

      if (widget.existingReview != null) {
        // 수정 모드
        final rev = widget.existingReview!;
        await reviewService.updateReview(
          docId: rev.id,
          villageName: widget.villageName,
          content: content,
          star: _star.toDouble(),
          title: titleText,
          hashtags: hashtags,
        );
      } else {
        // 새 작성 모드: 중복 허용 방식 등 원하는 저장 메서드 사용
        // 예: saveReviewAllowDuplicates
        await reviewService.saveReviewAllowDuplicates(
          villageName: widget.villageName,
          content: content,
          star: _star.toDouble(),
          title: titleText,
          hashtags: hashtags,
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('리뷰 저장 오류: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('리뷰 저장 중 오류가 발생했습니다: $e')));
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.existingReview != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditMode ? '리뷰 수정' : '리뷰 작성')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '“${widget.villageName}” 리뷰 ${isEditMode ? '수정' : '작성'}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 입력
                      const Text('제목 (선택)', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: '리뷰 제목을 입력하세요.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLength: 50,
                      ),
                      const SizedBox(height: 16),
                      // 별점
                      const Text('별점', style: TextStyle(fontSize: 14)),
                      _buildStarSelector(),
                      const SizedBox(height: 16),
                      // 내용
                      const Text('리뷰 내용', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _contentController,
                        maxLines: null,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: '리뷰 내용을 입력하세요.',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '리뷰 내용을 입력해주세요.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // 해시태그 입력
                      const Text('해시태그 (선택)', style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _tagController,
                              decoration: InputDecoration(
                                hintText: '해시태그를 입력하고 추가 버튼을 누르세요',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onSubmitted: (_) => _addHashtag(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addHashtag,
                            child: const Text('추가'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_hashtags.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          children:
                              _hashtags.map((tag) {
                                return Chip(
                                  label: Text('#$tag'),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () {
                                    setState(() {
                                      _hashtags.remove(tag);
                                    });
                                  },
                                );
                              }).toList(),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child:
                  _isSubmitting
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Text(isEditMode ? '수정 완료' : '저장'),
            ),
          ],
        ),
      ),
    );
  }
}
