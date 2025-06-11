// lib/search/pages/all_reviews_page.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youthbuk/search/review_write_page.dart';
import 'package:youthbuk/search/services/review_service.dart';
import 'package:youthbuk/search/widgets/review_card.dart';
import 'package:youthbuk/search/models/review_model.dart';

class AllReviewsPage extends StatefulWidget {
  final String villageName;
  const AllReviewsPage({super.key, required this.villageName});

  @override
  State<AllReviewsPage> createState() => _AllReviewsPageState();
}

class _AllReviewsPageState extends State<AllReviewsPage> {
  final ReviewService _reviewService = ReviewService();
  late Future<List<Review>> _futureReviews;
  Future<Map<String, String>>? _futureNicknames;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  void _loadReviews() {
    _futureReviews = _reviewService.fetchAllReviews(
      villageName: widget.villageName,
    );
    // 리뷰 로드 완료 후 batch 닉네임 조회
    _futureNicknames = _futureReviews.then(
      (reviews) => fetchNicknamesForReviews(reviews),
    );
  }

  // 리뷰 작성 페이지에서 돌아왔을 때 새로고침
  Future<void> _navigateToWritePage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewWritePage(villageName: widget.villageName),
      ),
    );
    if (result == true) {
      setState(() {
        _loadReviews();
      });
    }
  }

  /// 리뷰 리스트에서 고유한 authorId 목록을 뽑아 batch로 닉네임 조회
  Future<Map<String, String>> fetchNicknamesForReviews(
    List<Review> reviews,
  ) async {
    final authorIds =
        reviews
            .map((r) => r.authorId)
            .where((id) => id.isNotEmpty)
            .toSet()
            .toList();
    final Map<String, String> result = {};
    const int chunkSize = 10;

    for (var i = 0; i < authorIds.length; i += chunkSize) {
      final end = min(i + chunkSize, authorIds.length);
      final chunk = authorIds.sublist(i, end);
      try {
        final querySnap =
            await FirebaseFirestore.instance
                .collection('users')
                .where(FieldPath.documentId, whereIn: chunk)
                .get();
        for (var doc in querySnap.docs) {
          final data = doc.data();
          String name;
          if (data['nickname'] is String &&
              (data['nickname'] as String).trim().isNotEmpty) {
            name = data['nickname'] as String;
          } else if (data['displayName'] is String &&
              (data['displayName'] as String).trim().isNotEmpty) {
            name = data['displayName'] as String;
          } else {
            name = '익명';
          }
          result[doc.id] = name;
        }
        // 없는 ID는 익명 처리
        for (var id in chunk) {
          if (!result.containsKey(id)) {
            result[id] = '익명';
          }
        }
      } catch (e) {
        // 에러 시 모든 ID 익명 처리
        for (var id in chunk) {
          result[id] = '익명';
        }
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.villageName} 리뷰 전체 보기')),
      body: FutureBuilder<List<Review>>(
        future: _futureReviews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final err = snapshot.error.toString();
            return Center(child: Text('리뷰 로드 중 오류: $err'));
          }
          final reviews = snapshot.data ?? [];
          if (reviews.isEmpty) {
            return const Center(
              child: Text(
                '등록된 리뷰가 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }
          // 리뷰 로드 후 닉네임 Map을 기다림
          return FutureBuilder<Map<String, String>>(
            future: _futureNicknames,
            builder: (context, snapNames) {
              if (snapNames.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final nameMap = snapNames.data ?? {};
              return ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  final nickname = nameMap[review.authorId];
                  return ReviewCard(
                    review: review,
                    onDeleted: () {
                      // 삭제 후 새로고침
                      setState(() {
                        _loadReviews();
                      });
                    },
                    onEdited: () {
                      // 수정 후 새로고침
                      setState(() {
                        _loadReviews();
                      });
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToWritePage, // 연필 아이콘 등
        tooltip: '리뷰 작성',
        child: const Icon(Icons.edit),
      ),
    );
  }
}
