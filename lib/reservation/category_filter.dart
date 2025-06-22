import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CategoryFilter extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryFilter({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final selected = cat == selectedCategory;
          String emoji = '📍';

          if (cat.contains('살아보기')) {
            emoji = '🏡';
          } else if (cat.contains('알바')) {
            emoji = '📝';
          }

          return GestureDetector(
            onTap: () => onCategorySelected(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color:
                    selected
                        ? const Color(0xFFFFEDE5) // 연한 오렌지 베이지
                        : const Color(0xFFFDFCFB), // 기본 배경도 흰색보다 살짝 색감 추가
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color:
                      selected ? Colors.deepOrangeAccent : Colors.grey.shade300,
                  width: 1.2.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 18.sp,
                      color:
                          selected ? Colors.deepOrange : Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    cat,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          selected ? Colors.deepOrange : Colors.grey.shade900,
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
