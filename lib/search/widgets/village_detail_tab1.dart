import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VillageDetailTab1 extends StatefulWidget {
  const VillageDetailTab1({super.key});

  @override
  State<VillageDetailTab1> createState() => _VillageDetailTab1State();
}

class _VillageDetailTab1State extends State<VillageDetailTab1> {
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

    Query query = FirebaseFirestore.instance
        .collectionGroup('programs')
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

    setState(() => _isLoading = false);
  }

  Widget _buildProgramCard(int index) {
    final data = _programs[index].data() as Map<String, dynamic>? ?? {};

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30.r),
                child:
                    (data['imageUrl'] != null &&
                            data['imageUrl'].toString().isNotEmpty)
                        ? Image.network(
                          data['imageUrl'],
                          width: 36.w,
                          height: 36.w,
                          fit: BoxFit.cover,
                        )
                        : Image.asset(
                          'assets/images/test.png',
                          width: 36.w,
                          height: 36.w,
                          fit: BoxFit.cover,
                        ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  data['villageName'] ?? '마을명 없음',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    liked[index] = !liked[index];
                  });
                },
                child: Icon(
                  liked[index]
                      ? Icons.favorite
                      : Icons.favorite_outline_rounded,
                  size: 25.sp,
                  color: const Color(0xFFFF6F61),
                ),
              ),
              SizedBox(width: 12.w),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child:
                (data['imageUrl'] != null &&
                        data['imageUrl'].toString().isNotEmpty)
                    ? Image.network(
                      data['imageUrl'],
                      width: double.infinity,
                      height: 160.h,
                      fit: BoxFit.cover,
                    )
                    : Image.asset(
                      'assets/images/test.png',
                      width: double.infinity,
                      height: 160.h,
                      fit: BoxFit.cover,
                    ),
          ),
          SizedBox(height: 10.h),
          Text(
            data['name'] ?? '[프로그램명 없음]',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6.h),
          Text(
            data['description'] ?? '설명 없음',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.comment_outlined, size: 18.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                '리뷰 ${data['totalReviewCount'] ?? 0}개',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        controller: _scrollController,
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
          return _buildProgramCard(index);
        },
      ),
    );
  }
}
