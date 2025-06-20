import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youthbuk/search/village_list_page.dart';

class SearchRegionTab extends StatelessWidget {
  final List<Map<String, String>> regionData = [
    {"name": "청주시", "image": "assets/images/청주시.jpg"},
    {"name": "충주시", "image": "assets/images/충주시.jpg"},
    {"name": "제천시", "image": "assets/images/제천시.jpg"},
    {"name": "단양군", "image": "assets/images/단양군.jpg"},
    {"name": "보은군", "image": "assets/images/보은군.jpg"},
    {"name": "옥천군", "image": "assets/images/옥천군.jpg"},
    {"name": "영동군", "image": "assets/images/영동군.jpg"},
    {"name": "증평군", "image": "assets/images/증평군.jpg"},
    {"name": "진천군", "image": "assets/images/진천군.jpg"},
    {"name": "괴산군", "image": "assets/images/괴산군.jpg"},
    {"name": "음성군", "image": "assets/images/음성군.jpg"},
  ];

  SearchRegionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),

      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 1, // 정사각형 유지
        ),

        itemCount: regionData.length,
        itemBuilder: (context, index) {
          final region = regionData[index];
          return GestureDetector(
            onTap: () {
              // TODO: 지역 상세 페이지 이동 처리
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VillageListPage(regionName: region['name']!),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 이미지 영역
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16.r),
                      ),
                      child: Image.asset(
                        region['image']!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // 텍스트 영역
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          region['name']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.brown,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              "체험마을 : 5",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.brown,
                                fontWeight: FontWeight.bold,
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
        },
      ),
    );
  }
}
