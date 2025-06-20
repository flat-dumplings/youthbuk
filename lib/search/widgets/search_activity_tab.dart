import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youthbuk/search/models/village.dart';
import 'package:youthbuk/search/village_detail_page%20.dart';
import 'package:youthbuk/search/widgets/filter.dart' as filter_widget;
import 'package:youthbuk/search/widgets/program_detail_page.dart';

class SearchActivityTab extends StatefulWidget {
  final Set<int>? initialSelectedFilterIndexes;

  const SearchActivityTab({super.key, this.initialSelectedFilterIndexes});

  @override
  State<SearchActivityTab> createState() => _SearchActivityTabState();
}

class _SearchActivityTabState extends State<SearchActivityTab> {
  final Color themePrimary = const Color(0xFFFF8C69);
  final Color themeBackground = const Color(0xFFFFF1EC);
  final Color themeTextColor = const Color(0xFF5C4B3B);

  final List<String> sortOptions = ['캠프 추천순', '최신순', '가격 낮은순', '가격 높은순'];
  String selectedSort = '캠프 추천순';

  late Set<int> _selectedFilterIndexes;

  final List<DocumentSnapshot> _programs = [];

  bool _isLoading = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;

  final ScrollController _scrollController = ScrollController();

  List<bool> liked = [];

  @override
  void initState() {
    super.initState();
    _selectedFilterIndexes = widget.initialSelectedFilterIndexes ?? {0};
    liked = [];
    _loadData(reset: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        if (!_isLoading && _hasMore) {
          _loadData();
        }
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

    if (!_hasMore) return;

    setState(() => _isLoading = true);

    List<String>? categoryFilters;

    if (_selectedFilterIndexes.isNotEmpty &&
        !_selectedFilterIndexes.contains(0)) {
      categoryFilters =
          _selectedFilterIndexes
              .map(_mapIndexToCategory)
              .whereType<String>()
              .toList();
    } else {
      categoryFilters = null;
    }

    Query query = FirebaseFirestore.instance.collectionGroup('programs');

    if (categoryFilters != null && categoryFilters.isNotEmpty) {
      query = query.where('category', arrayContainsAny: categoryFilters);
    }

    switch (selectedSort) {
      case '최신순':
        query = query.orderBy('createdAt', descending: true);
        break;
      case '가격 낮은순':
        query = query.orderBy('price', descending: false);
        break;
      case '가격 높은순':
        query = query.orderBy('price', descending: true);
        break;
      case '캠프 추천순':
      default:
        query = query.orderBy('name');
        break;
    }

    query = query.limit(10);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _lastDocument = snapshot.docs.last;
      _programs.addAll(snapshot.docs);
      liked.addAll(List.filled(snapshot.docs.length, false));
      if (snapshot.docs.length < 10) {
        _hasMore = false;
      }
    } else {
      _hasMore = false;
    }

    setState(() => _isLoading = false);
  }

  String? _mapIndexToCategory(int index) {
    switch (index) {
      case 1:
        return '농촌활동';
      case 2:
        return '체험';
      case 3:
        return '관광';
      case 4:
        return '건강';
      case 5:
        return '공예';
      case 6:
        return '요리';
      case 7:
        return '곤충 관찰';
      case 8:
        return '낚시';
      case 9:
        return '먹거리';
      default:
        return null;
    }
  }

  Widget _buildSortBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.sort, size: 16.sp, color: themePrimary),
              SizedBox(width: 6.w),
              Text(
                '정렬 기준',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            height: 35.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              border: Border.all(color: themePrimary.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(30.r),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSort,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20.sp,
                  color: themePrimary,
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: themeTextColor,
                ),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedSort = value;
                    });
                    _loadData(reset: true);
                  }
                },
                items:
                    sortOptions.map((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: SizedBox(
                          height: 28.h,
                          child: Row(
                            children: [
                              Icon(
                                Icons.check,
                                size: 14.sp,
                                color:
                                    option == selectedSort
                                        ? themePrimary
                                        : Colors.transparent,
                              ),
                              SizedBox(width: 4.w),
                              Text(option),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCard(int index) {
    final data = _programs[index].data() as Map<String, dynamic>? ?? {};
    final String? programName = data['name'];

    return GestureDetector(
      onTap: () async {
        print('[DEBUG] 카드 클릭됨: $programName');

        if (programName == null) return;

        if (!context.mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProgramDetailPage(programName: programName),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
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
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        liked[index] = !liked[index];
                      });
                    },
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Icon(
                        liked[index]
                            ? Icons.favorite
                            : Icons.favorite_outline_rounded,
                        size: 25.sp,
                        color: const Color(0xFFFF6F61),
                      ),
                    ),
                  ),
                ),
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
                SizedBox(width: 5.w),
                Icon(Icons.comment_outlined, size: 18.sp, color: Colors.grey),
                SizedBox(width: 4.w),
                Text(
                  '리뷰 ${data['totalReviewCount'] ?? 0}개',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          filter_widget.Filter(
            selectedIndexes: _selectedFilterIndexes,
            onChanged: (selectedIndexes) {
              setState(() {
                _selectedFilterIndexes = selectedIndexes;
              });
              _loadData(reset: true);
            },
          ),
          SizedBox(height: 12.h),
          _buildSortBar(),
          SizedBox(height: 8.h),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
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
          ),
        ],
      ),
    );
  }
}
