import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youthbuk/search/services/village_repository.dart';
import 'package:youthbuk/search/models/village.dart';
import 'package:youthbuk/search/village_detail_page%20.dart';
import 'package:youthbuk/search/widgets/filter.dart';

class VillageListPage extends StatefulWidget {
  final String regionName;
  final bool isOthers;

  const VillageListPage({
    super.key,
    required this.regionName,
    this.isOthers = false,
  });

  @override
  State<VillageListPage> createState() => _VillageListPageState();
}

class _VillageListPageState extends State<VillageListPage> {
  final repo = VillageRepository();
  final Color themePrimary = const Color(0xFFFF8C69);
  final Color themeBackground = const Color(0xFFFFF1EC);
  final Color themeTextColor = const Color(0xFF5C4B3B);

  final List<String> sortOptions = ['캠프 추천순', '최신순', '가격 낮은순', '가격 높은순'];
  String selectedSort = '캠프 추천순';
  List<bool> liked = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/logo_3d.png',
                  width: 30.w,
                  height: 30.h,
                ),
                SizedBox(width: 6.w),
                Text(
                  '청춘북',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () {},
              label: Text(
                '🛒 장바구니',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 12.h,
              left: 16.w,
              right: 16.w,
              bottom: 4.h,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.regionName,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20.sp,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          const Filter(),
          SizedBox(height: 12.h),
          _buildSortBar(),
          SizedBox(height: 8.h),
          Expanded(
            child: FutureBuilder<List<Village>>(
              future:
                  widget.isOthers
                      ? repo.fetchOthers()
                      : repo.fetchByRegionName(widget.regionName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('불러오는 중 오류: ${snapshot.error}'));
                }
                final villages = snapshot.data;
                if (villages == null || villages.isEmpty) {
                  return const Center(child: Text('등록된 체험마을이 없습니다.'));
                }

                if (liked.length != villages.length) {
                  liked = List.generate(villages.length, (_) => false);
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: villages.length,
                  itemBuilder: (context, index) {
                    final v = villages[index];
                    final avgText =
                        v.averageRatingStored?.toStringAsFixed(1) ?? '0.0';
                    final count = v.reviewCountStored ?? 0;
                    final displayCount =
                        count >= 100 ? '99+' : count.toString();

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VillageDetailPage(village: v),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(30.r),
                                  child:
                                      v.photoUrls != null &&
                                              v.photoUrls!.isNotEmpty
                                          ? Image.network(
                                            v.photoUrls!.first,
                                            width: 36.w,
                                            height: 36.w,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (c, e, s) => Container(
                                                  width: 36.w,
                                                  height: 36.w,
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(
                                                    Icons.broken_image,
                                                    size: 20,
                                                  ),
                                                ),
                                          )
                                          : Container(
                                            width: 36.w,
                                            height: 36.w,
                                            color: Colors.grey.shade200,
                                            child: const Icon(
                                              Icons.image,
                                              size: 20,
                                            ),
                                          ),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        v.name,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(
                                      () => liked[index] = !liked[index],
                                    );
                                  },
                                  child: Icon(
                                    liked[index]
                                        ? Icons.favorite
                                        : Icons.favorite_outline_rounded,
                                    size: 25.sp,
                                    color: Color(0xFFFF6F61),
                                  ),
                                ),
                                SizedBox(width: 12.w),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child:
                                  v.photoUrls != null && v.photoUrls!.isNotEmpty
                                      ? Image.network(
                                        v.photoUrls!.first,
                                        width: double.infinity,
                                        height: 160.h,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (c, e, s) => Container(
                                              width: double.infinity,
                                              height: 160.h,
                                              color: Colors.grey.shade200,
                                              child: const Icon(
                                                Icons.broken_image,
                                                size: 48,
                                              ),
                                            ),
                                      )
                                      : Container(
                                        width: double.infinity,
                                        height: 160.h,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image,
                                          size: 48,
                                        ),
                                      ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              '[${v.name}] ${v.categoryRaw}',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              '간단한 소개 문구를 여기에 표시할 수 있습니다.',
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
                                Icon(
                                  Icons.comment_outlined,
                                  size: 18.sp,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '리뷰 $displayCount개',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Icon(
                                  Icons.star,
                                  size: 16.sp,
                                  color: Colors.orange,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  avgText,
                                  style: TextStyle(fontSize: 12.sp),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '($displayCount)',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
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
                    setState(() => selectedSort = value);
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
}
