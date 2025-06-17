// search_activity_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchActivityTab extends StatefulWidget {
  const SearchActivityTab({super.key});

  @override
  State<SearchActivityTab> createState() => _SearchActivityTabState();
}

class _SearchActivityTabState extends State<SearchActivityTab> {
  final List<String> baseCategories = ['전체', '케이크', '꽃다발', '주얼리'];
  final List<String> extraFilters = [
    '반려동물',
    '디저트',
    '핸드폰악세서리',
    '토퍼',
    '공예',
    '드로잉',
    '의류',
    '10분',
    '건강한 식단',
    '단짠',
    '플로리 낮은',
  ];

  int selectedBaseIndex = 0;
  Set<int> selectedExtraIndexes = {};
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 👉 접힌 상태: 한 줄 필터 요약 UI
        if (!isExpanded)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_alt_outlined, size: 18),
                SizedBox(width: 8.w),
                Text(
                  '필터',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () => setState(() => isExpanded = true),
                  child: Row(
                    children: [
                      Text(
                        baseCategories[selectedBaseIndex],
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.expand_more,
                        size: 18.sp,
                        color: Colors.deepOrange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        /// 👉 펼친 상태: 상세 필터 UI
        if (isExpanded)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
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
                /// 제목 및 접기
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.filter_alt_outlined, size: 18),
                        SizedBox(width: 6.w),
                        Text(
                          '필터',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => setState(() => isExpanded = false),
                      child: Row(
                        children: [
                          Text(
                            '접기',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.expand_less,
                            size: 18.sp,
                            color: Colors.deepOrange,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                /// 기본 카테고리
                Wrap(
                  spacing: 10.w,
                  runSpacing: 8.h,
                  children: List.generate(baseCategories.length, (i) {
                    final selected = selectedBaseIndex == i;
                    return ChoiceChip(
                      label: Text(baseCategories[i]),
                      selected: selected,
                      selectedColor: Colors.deepOrange,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      backgroundColor: Colors.grey.shade100,
                      shape: StadiumBorder(
                        side: BorderSide(
                          color:
                              selected
                                  ? Colors.deepOrange
                                  : Colors.grey.shade300,
                        ),
                      ),
                      onSelected: (_) {
                        setState(() => selectedBaseIndex = i);
                      },
                    );
                  }),
                ),
                SizedBox(height: 16.h),

                /// 추가 필터 (인기 키워드)
                Wrap(
                  spacing: 10.w,
                  runSpacing: 8.h,
                  children: List.generate(extraFilters.length, (i) {
                    final selected = selectedExtraIndexes.contains(i);
                    return FilterChip(
                      label: Text(extraFilters[i]),
                      selected: selected,
                      selectedColor: Colors.deepOrange.shade100,
                      labelStyle: TextStyle(
                        color: selected ? Colors.deepOrange : Colors.black87,
                      ),
                      shape: StadiumBorder(
                        side: BorderSide(
                          color:
                              selected
                                  ? Colors.deepOrange
                                  : Colors.grey.shade300,
                        ),
                      ),
                      backgroundColor: Colors.grey.shade100,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            selectedExtraIndexes.add(i);
                          } else {
                            selectedExtraIndexes.remove(i);
                          }
                        });
                      },
                    );
                  }),
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
      ],
    );
  }
}
