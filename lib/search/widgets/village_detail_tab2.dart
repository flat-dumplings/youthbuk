import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:youthbuk/search/widgets/program_detail_page.dart';

class VillageDetailTab2 extends StatefulWidget {
  final String villageId;
  const VillageDetailTab2({super.key, required this.villageId});

  @override
  State<VillageDetailTab2> createState() => _VillageDetailTab2State();
}

class _VillageDetailTab2State extends State<VillageDetailTab2> {
  final List<DocumentSnapshot> _programs = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  List<bool> liked = [];

  @override
  void initState() {
    super.initState();
    liked = [];
    _loadData(reset: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_isLoading &&
          _hasMore) {
        _loadData();
      }
    });
  }

  Future<void> _loadData({bool reset = false}) async {
    if (_isLoading) return;

    if (reset) {
      _lastDocument = null;
      _hasMore = true;
      _programs.clear();
      liked.clear();
    }

    setState(() => _isLoading = true);

    try {
      Query query = FirebaseFirestore.instance
          .collectionGroup('programs')
          .where('villageName', isEqualTo: widget.villageId)
          .orderBy('createdAt', descending: true)
          .limit(10);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _programs.addAll(snapshot.docs);
        liked.addAll(List.filled(snapshot.docs.length, false));
        if (snapshot.docs.length < 10) _hasMore = false;
      } else {
        _hasMore = false;
      }
    } catch (e) {
      print('🔥 Firestore 오류: $e');
      _hasMore = false;
    }

    setState(() => _isLoading = false);
  }

  Widget _buildProgramCard(int index) {
    final data = _programs[index].data() as Map<String, dynamic>? ?? {};

    final String imageUrl = data['imageUrl']?.toString() ?? '';
    final String name = data['name'] ?? '[프로그램명 없음]';
    final int price = data['price'] ?? 0;
    final formattedPrice = NumberFormat.decimalPattern().format(price);
    final int reviewCount = data['totalReviewCount'] ?? 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProgramDetailPage(programName: name),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 + 하트
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(16.r),
                  ),
                  child:
                      imageUrl.isNotEmpty
                          ? Image.network(
                            imageUrl,
                            width: double.infinity,
                            height: 140.h,
                            fit: BoxFit.cover,
                          )
                          : Image.asset(
                            'assets/images/test.png',
                            width: double.infinity,
                            height: 140.h,
                            fit: BoxFit.cover,
                          ),
                ),
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        liked[index] = !liked[index];
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(6.w),
                      child: Icon(
                        liked[index]
                            ? Icons.favorite
                            : Icons.favorite_outline_rounded,
                        size: 20.sp,
                        color: const Color(0xFFFF6F61),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 내용
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이름
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),

                  // 가격 + 리뷰 + 장바구니
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildTag(
                            '$formattedPrice원',
                            const Color(0xFFFFEBEE),
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.comment_outlined,
                            size: 14.sp,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '$reviewCount개',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          print('장바구니 추가');
                        },
                        child: _buildTag(
                          '담기',
                          const Color(0xFFE3F2FD),
                          icon: Icons.shopping_cart_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color bgColor, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14.sp, color: Colors.black87),
            SizedBox(width: 4.w),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          itemCount: _programs.length + (_isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _programs.length) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const CircularProgressIndicator(),
                ),
              );
            }
            return Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: _buildProgramCard(index),
            );
          },
        ),
      ],
    );
  }
}
