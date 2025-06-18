import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'filter.dart';

class SearchActivityTab extends StatefulWidget {
  const SearchActivityTab({super.key});

  @override
  State<SearchActivityTab> createState() => _SearchActivityTabState();
}

class _SearchActivityTabState extends State<SearchActivityTab> {
  final Color themePrimary = const Color(0xFFFF8C69);
  final Color themeBackground = const Color(0xFFFFF1EC);
  final Color themeTextColor = const Color(0xFF5C4B3B);

  final List<String> sortOptions = ['캠프 추천순', '최신순', '가격 낮은순', '가격 높은순'];
  String selectedSort = '캠프 추천순';

  List<bool> liked = List.generate(5, (_) => false);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Filter(),
        SizedBox(height: 12.h),
        _buildSortBar(),
        SizedBox(height: 8.h),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
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
                          child: Image.asset(
                            'assets/images/test.png',
                            width: 36.w,
                            height: 36.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '청주 효마을',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() => liked[index] = !liked[index]);
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    liked[index]
                                        ? Icons.favorite
                                        : Icons.favorite_outline_rounded,
                                    size: 25.sp,
                                    color: Color(0xFFFF6F61),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 12.w),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.asset(
                            'assets/images/test.png',
                            width: double.infinity,
                            height: 160.h,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      '[청주효마을] 딸기따기 체험',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '집안일 필수템 · 부지런한 몸\n운동복, 수건 같은 젖은 빨래와 때는 식초 넣기 그 외에도 다양한 꿀팁이 있으니 참고하세요!',
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
                          '리뷰 5개',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
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
