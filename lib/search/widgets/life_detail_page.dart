import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LifeDetailPage extends StatefulWidget {
  const LifeDetailPage({super.key});

  @override
  State<LifeDetailPage> createState() => _LifeDetailPageState();
}

class _LifeDetailPageState extends State<LifeDetailPage> {
  bool isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '농촌활동 스탭 상세 정보',
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
      body: ListView(
        children: [
          // 상단 이미지
          SizedBox(
            height: 220.h,
            child: PageView(
              children: [
                Image.asset('assets/images/staff.jpg', fit: BoxFit.cover),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이름 & 하트
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '농촌활동 스탭 모집🌾',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isLiked = !isLiked;
                        });
                      },
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                        size: 26.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  '농촌 체험을 돕는 따뜻한 동행자, 농촌 활동 스탭 모집!',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 22.h),

                // 위치 및 연락처
                _infoRow(Icons.place, '충북 괴산군 칠성면 산막이옛길 23'),
                SizedBox(height: 8.h),
                _infoRow(Icons.phone, '010-1234-5678'),
                SizedBox(height: 26.h),

                _sectionTitle('📋 담당 역할'),
                _sectionBody('농촌 체험 안내, 프로그램 준비 및 정리, 체험객 응대'),
                SizedBox(height: 26.h),

                _sectionTitle('🕒 참여 가능 시간'),
                _sectionBody('평일 09:00 ~ 18:00, 주말 격주 근무 가능'),
                SizedBox(height: 28.h),

                _sectionTitle('📷 활동 사진'),
                SizedBox(
                  height: 130.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _photoBox('assets/images/review1.png'),
                      _photoBox('assets/images/review2.png'),
                      _photoBox('assets/images/review3.png'),
                    ],
                  ),
                ),
                SizedBox(height: 36.h),

                _sectionTitle('📝 참여 후기'),
                _styledReviewCard(
                  name: '김청년 스탭',
                  date: '2024.10.12',
                  text:
                      '마을 어르신들과 함께하는 시간이 정말 따뜻했습니다.\n아이들과 체험 프로그램을 준비하면서 스스로도 많은 것을 배울 수 있었고,\n매일이 뿌듯한 하루였어요.\n농촌의 매력을 더 많은 분들께 알릴 수 있어 행복했습니다!',
                  image: 'assets/images/review2.png',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _sectionBody(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Text(
        text,
        style: TextStyle(fontSize: 15.sp, color: Colors.black87, height: 1.6),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: Colors.grey),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _photoBox(String path) {
    return Padding(
      padding: EdgeInsets.only(right: 14.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: Image.asset(
          path,
          width: 130.w,
          height: 130.h,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _styledReviewCard({
    required String name,
    required String date,
    required String text,
    required String image,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 14.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Color(0xFFF7F9FB),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Colors.teal, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                name,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Text(date, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.asset(image, height: 140.h, fit: BoxFit.cover),
          ),
          SizedBox(height: 12.h),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
