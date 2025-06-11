// lib/search/widgets/review_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youthbuk/search/models/review_model.dart';
import 'package:youthbuk/search/review_write_page.dart';
import 'package:youthbuk/search/services/review_service.dart';

class ReviewCard extends StatefulWidget {
  final Review review;
  final VoidCallback? onDeleted; // 삭제 후 부모에 알림
  final VoidCallback? onEdited; // 수정 후 부모에 알림

  const ReviewCard({
    super.key,
    required this.review,
    this.onDeleted,
    this.onEdited,
  });

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  @override
  Widget build(BuildContext context) {
    final authorId = widget.review.authorId;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwnReview = (currentUser != null && authorId == currentUser.uid);

    final created = widget.review.createAt;
    final dateStr = DateFormat('yyyy.MM.dd').format(created);

    // authorNickname 활용: null 또는 빈 문자열이면 '익명'
    String displayName = widget.review.authorNickname?.trim() ?? '';
    if (displayName.isEmpty) {
      displayName = '익명';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 작성자 정보 + (본인 리뷰면) 메뉴 버튼
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 16,
                child: Text(
                  displayName.isNotEmpty ? displayName[0] : '?',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const Spacer(),
              if (isOwnReview)
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _onEditReview(context);
                    } else if (value == 'delete') {
                      _onDeleteReview(context);
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('수정')),
                        const PopupMenuItem(value: 'delete', child: Text('삭제')),
                      ],
                  icon: const Icon(Icons.more_vert, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // 별점
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < widget.review.star ? Icons.star : Icons.star_border,
                size: 16,
                color: Colors.orange,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 제목
          if (widget.review.title != null &&
              widget.review.title!.isNotEmpty) ...[
            Text(
              widget.review.title!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
          ],
          // 내용
          Text(widget.review.content, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 8),
          // 해시태그
          if (widget.review.hashtags != null &&
              widget.review.hashtags!.isNotEmpty)
            Wrap(
              spacing: 8,
              children:
                  widget.review.hashtags!
                      .map(
                        (tag) => Chip(
                          label: Text(
                            '#$tag',
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: Colors.grey.shade100,
                        ),
                      )
                      .toList(),
            ),
          const Divider(),
        ],
      ),
    );
  }

  void _onEditReview(BuildContext context) {
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder:
            (_) => ReviewWritePage(
              villageName: widget.review.villageName,
              existingReview: widget.review,
            ),
      ),
    ).then((result) {
      if (result == true) {
        // 카드 자체 rebuild
        setState(() {});
        // 부모 페이지에 알림
        widget.onEdited?.call();
      }
    });
  }

  void _onDeleteReview(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('리뷰 삭제'),
            content: const Text('정말 이 리뷰를 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
    if (confirmed == true) {
      try {
        final reviewService = ReviewService();
        await reviewService.deleteReview(docId: widget.review.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('리뷰가 삭제되었습니다.')));
        // 부모 페이지에 삭제 알림
        widget.onDeleted?.call();
      } catch (e) {
        debugPrint('리뷰 삭제 오류: $e');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('리뷰 삭제 중 오류가 발생했습니다: $e')));
      }
    }
  }
}
