import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Filter extends StatefulWidget {
  const Filter({super.key});

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  final List<Map<String, String>> baseCategories = [
    {'emoji': '🌐', 'label': '전체'},
    {'emoji': '🌾', 'label': '농촌활동'},
    {'emoji': '🎨', 'label': '체험'},
    {'emoji': '🗺️', 'label': '관광'},
    {'emoji': '💪', 'label': '건강'},
    {'emoji': '🧵', 'label': '공예'},
    {'emoji': '🍳', 'label': '요리'},
    {'emoji': '🐞', 'label': '곤충 관찰'},
    {'emoji': '🎣', 'label': '낚시'},
    {'emoji': '🍱', 'label': '먹거리'},
  ];

  Set<int> selectedIndexes = {0};
  bool isExpanded = false;

  final Color themePrimary = const Color(0xFFFF8C69);
  final Color themeBackground = const Color(0xFFFFF1EC);
  final Color themeTextColor = const Color(0xFF5C4B3B);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isExpanded) _buildCollapsedFilter(),
        if (isExpanded) _buildExpandedFilter(),
      ],
    );
  }

  Widget _buildCollapsedFilter() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          Icon(Icons.filter_alt_rounded, size: 20.sp, color: themePrimary),
          SizedBox(width: 10.w),
          Text(
            '필터',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: themeTextColor,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => setState(() => isExpanded = true),
            borderRadius: BorderRadius.circular(20.r),
            child: Row(
              children: [
                Text(
                  '열기',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: themePrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.expand_more_rounded,
                  size: 20.sp,
                  color: themePrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedFilter() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: _boxDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.filter_alt_rounded,
                    size: 20.sp,
                    color: themePrimary,
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    '필터',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: themeTextColor,
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
                        fontSize: 14.sp,
                        color: themePrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.expand_less, size: 20.sp, color: themePrimary),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 10.w,
            runSpacing: 10.h,
            children: List.generate(baseCategories.length, (i) {
              final selected = selectedIndexes.contains(i);
              return GestureDetector(
                onTap:
                    () => setState(() {
                      if (i == 0) {
                        selectedIndexes.clear();
                        selectedIndexes.add(0);
                      } else {
                        selectedIndexes.remove(0);
                        selectedIndexes.contains(i)
                            ? selectedIndexes.remove(i)
                            : selectedIndexes.add(i);
                      }
                    }),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color:
                        selected ? themePrimary.withOpacity(0.1) : Colors.white,
                    border: Border.all(
                      color: selected ? themePrimary : Colors.grey.shade300,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${baseCategories[i]['emoji']} ${baseCategories[i]['label']}',
                        style: TextStyle(
                          color: selected ? themePrimary : Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: themeBackground,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: themePrimary.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(color: themePrimary.withOpacity(0.3)),
    );
  }
}
