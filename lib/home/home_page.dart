import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:youthbuk/home/widgets/Image_category.dart';
import 'package:youthbuk/home/widgets/banner_widget.dart';
import 'package:youthbuk/home/widgets/deadline_section.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      body: Stack(
        children: [
          // 캐릭터 이미지
          Positioned(
            top: 70.h,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/main_half.png',
                height: 120.h,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 검색창
          Positioned(
            top: 180.h,
            left: 16.w,
            right: 16.w,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: '원하는 상품이나 체험을 검색하세요',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // 전체 콘텐츠
          Positioned.fill(
            top: 240.h,
            child: ListView(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
              children: [
                // Carousel Banner
                BannerWidget(
                  imagePaths: [
                    'assets/images/banner/001.png',
                    'assets/images/banner/002.png',
                    'assets/images/banner/003.png',
                    'assets/images/banner/004.png',
                    'assets/images/banner/005.png',
                  ],
                  onTap: (index) {
                    print('배너 $index 클릭됨');
                    // 원하는 동작 처리
                  },
                ),
                //const SizedBox(height: 20),

                // Category Icons
                GridView.count(
                  padding: EdgeInsets.only(top: 20.h),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 5,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  children: const [
                    ImageCategory(
                      imagePath: 'assets/icons/3d/all.png',
                      label: '전체',
                    ),
                    ImageCategory(
                      imagePath: 'assets/icons/3d/rural_activities.png',
                      label: '농촌활동',
                    ),
                    ImageCategory(
                      imagePath: 'assets/icons/3d/experience.png',
                      label: '체험',
                    ),
                    ImageCategory(
                      imagePath: 'assets/icons/3d/sightseeing.png',
                      label: '관광',
                    ),
                    ImageCategory(
                      imagePath: 'assets/icons/3d/health.png',
                      label: '건강',
                    ),
                    ImageCategory(
                      imagePath: 'assets/icons/3d/craft.png',
                      label: '공예',
                    ),
                    ImageCategory(
                      imagePath: 'assets/icons/3d/cooking.png',
                      label: '요리',
                    ),
                    ImageCategory(
                      imagePath: 'assets/icons/3d/insect_observation.png',
                      label: '곤충 관찰',
                    ),
                    ImageCategory(
                      imagePath: 'assets/icons/3d/fishhook.png',
                      label: '낚시',
                    ),
                    ImageCategory(
                      imagePath: 'assets/icons/3d/food.png',
                      label: '먹거리',
                    ),
                  ],
                ),
                SizedBox(height: 28.h),
                //const SectionDivider(),
                // 마감 임박 상품
                const DeadlineSection(),

                SizedBox(height: 28.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
