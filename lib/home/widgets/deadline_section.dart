import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youthbuk/home/widgets/title_header.dart';

class DeadlineSection extends StatelessWidget {
  const DeadlineSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dummyData = [
      {
        'title': '딸기 따기 체험',
        'company': '충주 효마을',
        'imagePath': 'assets/images/login_logo.png',
        'deadline': DateTime.now(),
        'region': '충주',
      },
      {
        'title': '목공예 체험',
        'company': '제천 도화리마을',
        'imagePath': 'assets/images/login_logo.png',
        'deadline': DateTime.now().add(const Duration(days: 1)),
        'region': '제천',
      },
      {
        'title': '빵 만들기 체험',
        'company': '단양 샘양지마을',
        'imagePath': 'assets/images/login_logo.png',
        'deadline': DateTime.now().add(const Duration(days: 100)),
        'region': '단양',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitleHeader(title: '마감 임박 체험 🔥', subTitle: '마감 전 빠르게 신청하세요!'),
        SizedBox(height: 10.h),
        SizedBox(
          height: 220.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: dummyData.length,
            separatorBuilder: (_, __) => SizedBox(width: 18.w),
            itemBuilder: (context, index) {
              final data = dummyData[index];
              final DateTime deadline = data['deadline'] as DateTime;
              final DateTime today = DateTime.now();

              final DateTime todayOnly = DateTime(
                today.year,
                today.month,
                today.day,
              );
              final DateTime deadlineOnly = DateTime(
                deadline.year,
                deadline.month,
                deadline.day,
              );

              final difference = deadlineOnly.difference(todayOnly).inDays;

              String deadlineText;
              if (difference > 0) {
                deadlineText = 'D-$difference';
              } else if (difference == 0) {
                deadlineText = '오늘 마감';
              } else {
                deadlineText = '마감';
              }

              return Container(
                width: 180.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r),
                      ),
                      child: Stack(
                        children: [
                          Image.asset(
                            data['imagePath']!,
                            width: double.infinity,
                            height: 150.h,
                            fit: BoxFit.cover,
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Color.fromARGB(120, 0, 0, 0),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10.h,
                            right: 10.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.deepOrangeAccent,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.deepOrangeAccent.withOpacity(
                                      0.5,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                deadlineText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8.h,
                            left: 10.w,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 12.sp,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    data['region']!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 60.h,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 6.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data['company']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              data['title']!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.sp,
                                color: Colors.black,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
