import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youthbuk/search/widgets/search_activity_tab.dart';
import 'package:youthbuk/search/widgets/search_region_tab.dart';

class SearchPage extends StatefulWidget {
  final int initialTabIndex;
  final Set<int> initialSelectedFilterIndexes;

  const SearchPage({
    super.key,
    this.initialTabIndex = 0,
    this.initialSelectedFilterIndexes = const {0},
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  late final TabController _tabController;
  late Set<int> _selectedFilterIndexes;

  final List<String> mainTabs = ['지역별', '체험별'];

  @override
  void initState() {
    super.initState();

    _selectedFilterIndexes = widget.initialSelectedFilterIndexes;

    _tabController = TabController(
      length: mainTabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void didUpdateWidget(covariant SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      _tabController.dispose();
      _tabController = TabController(
        length: mainTabs.length,
        vsync: this,
        initialIndex: widget.initialTabIndex,
      );
      setState(() {});
    }

    if (oldWidget.initialSelectedFilterIndexes !=
        widget.initialSelectedFilterIndexes) {
      setState(() {
        _selectedFilterIndexes = widget.initialSelectedFilterIndexes;
      });
    }
  }

  void _onFilterChanged(Set<int> selectedIndexes) {
    setState(() {
      _selectedFilterIndexes = selectedIndexes;
    });
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
              icon: const Icon(Icons.shopping_cart_outlined),
              label: Text(
                '장바구니',
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
          SizedBox(height: 5.h),
          TabBar(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            controller: _tabController,
            indicatorColor: const Color(0xFFFFB085),
            indicatorWeight: 4.0,
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
              controller: _tabController,
              children: [
                SearchRegionTab(),
                SearchActivityTab(
                  initialSelectedFilterIndexes: _selectedFilterIndexes,
                  key: ValueKey(_selectedFilterIndexes), // 필터 변경시 rebuild 용
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
