import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:youthbuk/search/models/review_model.dart';
import 'package:youthbuk/search/widgets/review_write_page.dart';

class VillageDetailTab3 extends StatefulWidget {
  final String villageId;
  const VillageDetailTab3({super.key, required this.villageId});

  @override
  State<VillageDetailTab3> createState() => _VillageDetailTab3State();
}

class _VillageDetailTab3State extends State<VillageDetailTab3> {
  final ScrollController _scrollController = ScrollController();
  final List<Review> _reviews = [];
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;
  bool _photoOnly = false;
  String _sortOption = '최신순';

  @override
  void initState() {
    super.initState();
    _fetchMoreReviews(reset: true);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      if (!_isLoading && _hasMore) {
        _fetchMoreReviews();
      }
    }
  }

  Future<void> _fetchMoreReviews({bool reset = false}) async {
    if (_isLoading || (!_hasMore && !reset)) return;

    if (reset) {
      setState(() {
        _reviews.clear();
        _lastDoc = null;
        _hasMore = true;
        _isLoading = true;
      });
    } else {
      setState(() => _isLoading = true);
    }

    try {
      Query query = FirebaseFirestore.instance
          .collection('villages_review')
          .where('체험마을명', isEqualTo: widget.villageId);

      if (_sortOption == '최신순') {
        query = query.orderBy('create_at', descending: true);
      } else if (_sortOption == '별점높은순') {
        query = query.orderBy('star', descending: true);
      } else if (_sortOption == '별점낮은순') {
        query = query.orderBy('star', descending: false);
      }

      query = query.limit(5);

      final querySnap =
          (_lastDoc != null && !reset)
              ? await query.startAfterDocument(_lastDoc!).get()
              : await query.get();

      if (querySnap.docs.isEmpty) {
        setState(() => _hasMore = false);
        return;
      }

      final newReviews =
          querySnap.docs
              .map((d) => Review.fromDocument(d))
              .where(
                (r) =>
                    !_photoOnly ||
                    (r.imageUrl != null && r.imageUrl!.isNotEmpty),
              )
              .toList();

      setState(() {
        _reviews.addAll(newReviews);
        _lastDoc = querySnap.docs.last;
        if (querySnap.docs.length < 5) _hasMore = false;
      });
    } catch (e) {
      debugPrint('🔥 리뷰 불러오기 실패: $e');
      setState(() => _hasMore = false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 25.h),
            _buildReviewHeader(),
            SizedBox(height: 24.h),
            if (_reviews.isEmpty && !_isLoading)
              _buildEmptyMessage()
            else
              ..._reviews.map((r) => _buildReviewCard(context, r)),
            if (_isLoading && _hasMore)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMessage() {
    return SizedBox(
      height: 300.h,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 60.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16.h),
            Text(
              '아직 등록된 후기가 없어요!',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              '첫 번째 후기를 남겨보세요 😊',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '총 ${_reviews.length}개의 후기',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _photoOnly = !_photoOnly;
                  _reviews.clear();
                  _lastDoc = null;
                  _hasMore = true;
                });
                _fetchMoreReviews(reset: true);
              },
              child: Row(
                children: [
                  Icon(
                    _photoOnly
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    size: 25.sp,
                    color: Colors.lightGreen,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '사진후기만',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            _sortButton('최신순'),
            SizedBox(width: 15.w),
            _sortButton('별점높은순'),
            SizedBox(width: 15.w),
            _sortButton('별점낮은순'),
          ],
        ),
      ],
    );
  }

  Widget _sortButton(String label) {
    final isSelected = _sortOption == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortOption = label;
          _reviews.clear();
          _lastDoc = null;
          _hasMore = true;
        });
        _fetchMoreReviews(reset: true);
      },
      child: Text(
        label,
        style: TextStyle(
          fontSize: 15.sp,
          color: isSelected ? Colors.black : Colors.grey,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, Review review) {
    final displayName =
        (review.authorNickname?.isNotEmpty ?? false)
            ? review.authorNickname!
            : '익명';
    final dateStr = DateFormat('yyyy.MM.dd').format(review.createAt);
    final hashtags = review.hashtags ?? [];
    final isMine = review.authorId == FirebaseAuth.instance.currentUser?.uid;

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: Colors.grey.shade300,
                child: Text(
                  displayName[0],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16.sp, color: Colors.orange),
                        SizedBox(width: 2.w),
                        Text(
                          review.star.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          dateStr,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.favorite_border, color: Colors.red, size: 20.sp),
              SizedBox(width: 4.w),
              Text('${review.like ?? 0}', style: TextStyle(fontSize: 13.sp)),
              if (isMine)
                Padding(
                  padding: EdgeInsets.only(left: 12.w),
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ReviewWritePage(
                                villageName: review.villageName,
                                existingReview: review,
                              ),
                        ),
                      );
                      if (result == true) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('리뷰가 수정되었습니다.')),
                        );
                        setState(() {
                          _reviews.clear();
                          _lastDoc = null;
                          _hasMore = true;
                        });
                        await _fetchMoreReviews(reset: true);
                      }
                    },
                    child: Icon(Icons.edit, size: 20.sp, color: Colors.grey),
                  ),
                ),
            ],
          ),
          if (review.imageUrl != null && review.imageUrl!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: _imageSliderWithTap(context, review.imageUrl!),
            ),
          SizedBox(height: 12.h),
          Text(
            review.content,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          if (hashtags.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Wrap(
                spacing: 6.w,
                runSpacing: 4.h,
                children: hashtags.map(_tagChip).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _imageSliderWithTap(BuildContext context, List<String> images) {
    final PageController controller = PageController();
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _ImageGalleryPage(images: images),
            ),
          ),
      child: SizedBox(
        height: 160.h,
        child: Stack(
          children: [
            PageView.builder(
              controller: controller,
              itemCount: images.length,
              itemBuilder:
                  (_, index) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.asset(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Container(
                              color: Colors.grey.shade200,
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                      ),
                    ),
                  ),
            ),
            Positioned(
              bottom: 6.h,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 2.w),
                    width: 6.w,
                    height: 6.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black26,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(label, style: TextStyle(fontSize: 12.sp)),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class _ImageGalleryPage extends StatelessWidget {
  final List<String> images;
  const _ImageGalleryPage({required this.images});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            itemCount: images.length,
            itemBuilder:
                (_, index) => InteractiveViewer(
                  child: Image.asset(
                    images[index],
                    fit: BoxFit.contain,
                    errorBuilder:
                        (_, __, ___) => Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
