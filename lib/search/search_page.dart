import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youthbuk/search/widgets/search_activity_tab.dart';
import 'package:youthbuk/search/widgets/search_region_tab.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _TabFilterPageState();
}

class _TabFilterPageState extends State<SearchPage>
    with TickerProviderStateMixin {
  late final TabController _mainTabController;
  int selectedCategory = 0;

  final List<String> mainTabs = ['지역별', '체험별'];

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: mainTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Column(
        children: [
          SizedBox(height: 5.h), // 필요에 따라 상단 여백 조정
          TabBar(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            controller: _mainTabController,
            indicatorColor: Color(0xFFFFB085), // 선택된 탭 아래 라인 색상
            indicatorWeight: 4.0, // 👉 라인 두께 조절 (기본: 2.0)
            indicatorSize: TabBarIndicatorSize.label,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontSize: 19.sp),
            tabs: mainTabs.map((e) => Tab(text: e)).toList(),
          ),
          SizedBox(height: 10.h),
          SizedBox(height: 8.h),
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [
                SearchRegionTab(), // 지역별 탭
                SearchActivityTab(), // 체험별 탭
              ],
            ),
          ),
        ],
      ),
    );
  }
}
