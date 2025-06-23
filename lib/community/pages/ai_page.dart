import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'poster_create_page.dart';
import 'character_create_page.dart';
import 'detail_create_page.dart';

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  void _onCreatePressed(String type) {
    if (type == 'AI 홍보 포스터 제작') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PosterCreatePage()),
      );
    } else if (type == '마을만의 캐릭터 제작') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CharacterCreatePage()),
      );
    } else if (type == 'AI 상세페이지 제작') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DetailCreatePage()),
      );
    }
  }

  Widget _buildCard({
    required String imagePath,
    required String title,
    required String costText,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            child: Image.asset(imagePath, height: 160.h, fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h), // 간격 줄임
                Row(
                  children: [
                    Text(
                      costText,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _onCreatePressed(title),
                      icon: Icon(Icons.auto_awesome, size: 18.sp),
                      label: Text('만들기', style: TextStyle(fontSize: 14.sp)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9E80),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 20.w,
        title: Row(
          children: [
            Image.asset('assets/images/logo_3d.png', width: 30.w, height: 30.w),
            SizedBox(width: 8.w),
            Text(
              '청춘북',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Text('🛒'),
              label: Text(
                '장바구니',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey.shade300),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Column(
          children: [
            _buildCard(
              imagePath: 'assets/images/ai_poster.png',
              title: 'AI 홍보 포스터 제작',
              costText: '비용 : 1회 1000원',
            ),
            _buildCard(
              imagePath: 'assets/images/character_poster.png',
              title: '마을만의 캐릭터 제작',
              costText: '비용 : 1회 1000원',
            ),
            _buildCard(
              imagePath: 'assets/images/detail_poster.png',
              title: 'AI 상세페이지 제작',
              costText: '비용 : 1회 1000원',
            ),
          ],
        ),
      ),
    );
  }
}
