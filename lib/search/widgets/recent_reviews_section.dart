import 'package:flutter/material.dart';
import 'package:youthbuk/search/services/review_service.dart';
import 'package:youthbuk/search/models/review_model.dart';
import 'package:youthbuk/search/widgets/review_card.dart';

class RecentReviewsSection extends StatefulWidget {
  final String villageName;
  final VoidCallback? onViewAll; // 전체 보기로 이동 콜백

  const RecentReviewsSection({
    super.key,
    required this.villageName,
    this.onViewAll,
  });

  @override
  State<RecentReviewsSection> createState() => _RecentReviewsSectionState();
}

class _RecentReviewsSectionState extends State<RecentReviewsSection> {
  final ReviewService _reviewService = ReviewService();
  Future<List<Review>>? _futureRecentReviews; // late 제거, ?로 변경

  @override
  void initState() {
    super.initState();
    _loadRecentReviews();
  }

  void _loadRecentReviews() {
    _futureRecentReviews = _reviewService.fetchRecentReviews(
      villageName: widget.villageName,
      limit: 5,
    );
  }

  @override
  Widget build(BuildContext context) {
    // null 체크: 초기화 전일 경우 빈 위젯 반환
    if (_futureRecentReviews == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<Review>>(
      future: _futureRecentReviews,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          final err = snapshot.error.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              '리뷰 로드 중 오류: $err',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        final reviews = snapshot.data ?? [];
        if (reviews.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text('등록된 리뷰가 없습니다.', style: TextStyle(color: Colors.grey)),
          );
        }

        // 최근 리뷰 5개 리스트
        return Column(
          children: [
            ...reviews.map((review) {
              return ReviewCard(
                review: review,
                onDeleted: () {
                  setState(() {
                    _loadRecentReviews(); // 삭제 후 새로고침
                  });
                },
                onEdited: () {
                  setState(() {
                    _loadRecentReviews(); // 수정 후 새로고침
                  });
                },
              );
            }),
          ],
        );
      },
    );
  }
}
