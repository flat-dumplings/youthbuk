import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youthbuk/pay/cartpage.dart';

class ProgramDetailPage extends StatefulWidget {
  final String programName;
  const ProgramDetailPage({super.key, required this.programName});

  @override
  State<ProgramDetailPage> createState() => _ProgramDetailPageState();
}

class _ProgramDetailPageState extends State<ProgramDetailPage> {
  int count = 1;
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '프로그램 상세 정보',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future:
            FirebaseFirestore.instance
                .collectionGroup('programs')
                .where('name', isEqualTo: widget.programName)
                .limit(1)
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('해당 프로그램을 찾을 수 없습니다.'));
          }

          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          String getVal(String key, [String fallback = '정보 없음']) =>
              (data[key] != null && data[key].toString().isNotEmpty)
                  ? data[key].toString()
                  : fallback;

          final List<String> steps =
              (data['steps'] as List?)?.map((e) => e.toString()).toList() ?? [];
          final List<String> categories =
              (data['category'] as List?)?.map((e) => e.toString()).toList() ??
              [];
          final List<String> photos =
              (data['photos'] as List?)?.map((e) => e.toString()).toList() ??
              [];

          final startDate = (data['startDate'] as Timestamp?)?.toDate();
          final endDate = (data['endDate'] as Timestamp?)?.toDate();
          final dateString =
              (startDate != null && endDate != null)
                  ? '${startDate.year}.${startDate.month}.${startDate.day} ~ ${endDate.year}.${endDate.month}.${endDate.day}'
                  : '기간 정보 없음';

          final mainContent = getVal('mainContent');

          return SafeArea(
            child: Stack(
              children: [
                ListView(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.h,
                    horizontal: 20.w,
                  ),
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Image.network(
                        data['titlePhoto'] ?? '',
                        height: 200.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => Image.asset(
                              'assets/images/default.png',
                              height: 200.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      getVal('name'),
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      getVal('summary'),
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children:
                          categories
                              .map(
                                (cat) => Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.orange.shade800,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                    ),
                    SizedBox(height: 24.h),
                    _infoBox('📅 기간', dateString),
                    _infoBox('💵 가격', '${getVal('price')}원'),
                    _infoBox('📍 위치', getVal('villageName')),
                    _infoBox('📞 연락처', getVal('phone')),
                    if (mainContent.isNotEmpty) ...[
                      SizedBox(height: 24.h),
                      Text('📖 프로그램 내용', style: _sectionTitle()),
                      SizedBox(height: 10.h),
                      _buildMainContentTable(mainContent),
                    ],
                    if (steps.isNotEmpty) ...[
                      SizedBox(height: 24.h),
                      Text('🛠 체험 순서', style: _sectionTitle()),
                      SizedBox(height: 10.h),
                      ...steps.map(
                        (s) => Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 18.sp,
                                color: Colors.teal,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  s,
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    if (photos.isNotEmpty) ...[
                      SizedBox(height: 24.h),
                      Text('📷 체험 현장 스냅', style: _sectionTitle()),
                      SizedBox(height: 12.h),
                      ...photos.map(
                        (url) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Image.network(
                              url,
                              width: double.infinity,
                              height: 200.h,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Image.asset(
                                    'assets/images/default.png',
                                    width: double.infinity,
                                    height: 200.h,
                                    fit: BoxFit.cover,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    SizedBox(height: 80.h),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: Color(0xFFFFA86A),
              ),
              onPressed: () => showCartCompleteDialog(context),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => _buildReservationSheet(),
                    ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFA86A),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Text(
                  '예약하기',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationSheet() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 10.w,
            right: 10.w,
            top: 20.h,
          ),
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 24.sp),
                    SizedBox(width: 8.w),
                    Text(
                      '예약 인원 및 날짜 선택',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('예약 인원수', style: TextStyle(fontSize: 16.sp)),
                    Row(
                      children: [
                        IconButton(
                          onPressed:
                              () => setState(
                                () => count = count > 1 ? count - 1 : 1,
                              ),
                          icon: Icon(Icons.remove_circle_outline, size: 24.sp),
                        ),
                        Text('$count명', style: TextStyle(fontSize: 16.sp)),
                        IconButton(
                          onPressed: () => setState(() => count++),
                          icon: Icon(Icons.add_circle_outline, size: 24.sp),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('예약 날짜', style: TextStyle(fontSize: 16.sp)),
                    TextButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      child: Text(
                        selectedDate == null
                            ? '날짜 선택'
                            : '${selectedDate!.year}.${selectedDate!.month}.${selectedDate!.day}',
                        style: TextStyle(fontSize: 16.sp, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showCartCompleteDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFA86A),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: StadiumBorder(),
                    ),
                    child: Text(
                      '장바구니 담기',
                      style: TextStyle(fontSize: 16.sp, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoBox(String title, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: 14.sp, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _sectionTitle() => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  Widget _buildMainContentTable(String content) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '내용',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            content,
            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

void showCartCompleteDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: Color(0xFFFFEB3B),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text("😊", style: TextStyle(fontSize: 28.sp)),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "장바구니 담기 완료!",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "장바구니에 상품을 담았습니다.",
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFFFFA86A)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        "계속 구경하기",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFA86A),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => CartPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFFA86A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                      ),
                      child: Text(
                        "장바구니 바로가기",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
