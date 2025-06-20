import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youthbuk/search/widgets/life_detail_page.dart';

class VillageDetailTab1 extends StatelessWidget {
  const VillageDetailTab1({super.key, required this.villageId});
  final String villageId;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mockPrograms = [
      {
        'name': '스탭 신청하기',
        'imageUrl': 'assets/images/staff.jpg',
        'tag': '스탭',
        'totalReviewCount': 5,
      },
      {
        'name': '한달 살이 / 봉사',
        'imageUrl': 'assets/images/one_month.png',
        'tag': '한달 살이 / 봉사',
        'totalReviewCount': 18,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: mockPrograms.length,
        itemBuilder: (context, index) {
          final data = mockPrograms[index];
          final String name = data['name'] ?? '';
          final String imageUrl = data['imageUrl'] ?? '';
          final String tag = data['tag'] ?? '';
          final int reviewCount = data['totalReviewCount'] ?? 0;

          return Padding(
            padding: EdgeInsets.only(bottom: 24.h),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => LifeDetailPage()),
                );
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
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
                    // 이미지
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r),
                      ),
                      child:
                          imageUrl.isNotEmpty
                              ? Image.asset(
                                imageUrl,
                                width: double.infinity,
                                height: 200.h,
                                fit: BoxFit.cover,
                              )
                              : Image.asset(
                                'assets/images/test.png',
                                width: double.infinity,
                                height: 200.h,
                                fit: BoxFit.cover,
                              ),
                    ),
                    // 내용
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  _buildTag(tag, const Color(0xFFFFEBEE)),
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
                              _buildTag(
                                '신청하기',
                                const Color(0xFFE3F2FD),
                                icon: Icons.edit_calendar_outlined,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
}
