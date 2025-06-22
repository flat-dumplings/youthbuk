import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youthbuk/search/models/village.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youthbuk/search/widgets/village_detail_tab1.dart';
import 'package:youthbuk/search/widgets/village_detail_tab2.dart';
import 'package:youthbuk/search/widgets/village_detail_tab3.dart';

class VillageDetailPage extends StatefulWidget {
  final Village village;
  const VillageDetailPage({super.key, required this.village});

  @override
  State<VillageDetailPage> createState() => _VillageDetailPageState();
}

class _VillageDetailPageState extends State<VillageDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 탭 초기화
  int _selectedTabIndex = 1; // 초기값을 체험으로
  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final villageId = widget.village.id;
    final docRef = _firestore.collection('Villages').doc(villageId);

    return StreamBuilder<DocumentSnapshot>(
      stream: docRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('오류 발생: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final doc = snapshot.data!;
        if (!doc.exists) {
          return const Scaffold(body: Center(child: Text('마을 정보를 찾을 수 없습니다.')));
        }

        final village = Village.fromDoc(doc);
        final firstImageUrl =
            (village.photoUrls?.isNotEmpty ?? false)
                ? village.photoUrls!.first
                : null;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: const BackButton(color: Colors.black87),
            title: Text(
              village.name,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Icon(
                  Icons.bookmark_border,
                  color: Colors.black87,
                  size: 24.sp,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 6.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child:
                      (firstImageUrl != null)
                          ? Image.asset(
                            firstImageUrl,
                            width: double.infinity,
                            height: 200.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 200.h,
                                color: Colors.grey.shade200,
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 48.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          )
                          : Container(
                            width: double.infinity,
                            height: 200.h,
                            color: Colors.grey.shade100,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 48.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                ),
                SizedBox(height: 16.h),
                Center(
                  child: Column(
                    children: [
                      Text(
                        village.name,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star_rate_rounded,
                            color: Colors.amber,
                            size: 25.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  // 별점, star
                                  text: village.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black, // 평점 컬러
                                  ),
                                ),
                                TextSpan(
                                  text: ' (${village.reviewCount}+)',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey, // 후기 개수 컬러
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                SizedBox(height: 30.h),

                // 마을 정보
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(
                        icon: Icons.menu_book_rounded,
                        label: '마을소개',
                        content: village.programsRaw ?? '마을 소개 정보가 없습니다.',
                        iconColor: Colors.orange,
                      ),
                      SizedBox(height: 10.h),
                      _infoRow(
                        icon: Icons.phone,
                        label: '전화번호',
                        content: village.phone ?? '전화번호 정보가 없습니다.',
                        iconColor: Colors.grey.shade700,
                      ),
                      SizedBox(height: 10.h),
                      _infoRow(
                        icon: Icons.calendar_today,
                        label: '홈페이지',
                        content: village.homepage ?? '홈페이지 정보가 없습니다.',
                        iconColor: Colors.redAccent,
                      ),
                      SizedBox(height: 10.h),
                      _infoRow(
                        icon: Icons.maps_home_work,
                        label: '위치',
                        content: village.address ?? '위치 정보가 없습니다.',
                        iconColor: Colors.deepPurpleAccent,
                      ),
                    ],
                  ),
                ),
                // 찜, 공유 버튼
                SizedBox(height: 40.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(179, 247, 247, 247),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _iconTextButton(
                          icon: Icons.call,
                          label: '전화 문의',
                          onTap: () {
                            // 문자 기능 or 미구현 안내
                          },
                        ),
                        Container(
                          width: 1,
                          height: 24.h,
                          color: Colors.grey.shade300,
                        ), // 구분선
                        _iconTextButton(
                          icon: Icons.favorite_border,
                          label: '찜 24',
                          onTap: () {
                            // 찜 기능
                          },
                        ),
                        Container(
                          width: 1,
                          height: 24.h,
                          color: Colors.grey.shade300,
                        ), // 구분선
                        _iconTextButton(
                          icon: Icons.share_outlined,
                          label: '공유',
                          onTap: () {
                            // 공유 기능
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // 마을 정보, 체험 목록, 후기 탭
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: List.generate(5, (index) {
                        // 0, 2, 4: 탭 / 1, 3: 구분선
                        if (index % 2 == 1) {
                          return Container(
                            width: 1,
                            height: 24.h,
                            color: Colors.grey.shade300,
                          );
                        }

                        final tabIndex = index ~/ 2;
                        final titles = ['라이프', '체험', '후기'];
                        final isSelected = _selectedTabIndex == tabIndex;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTabIndex = tabIndex;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border(
                                  bottom: BorderSide(
                                    color:
                                        isSelected
                                            ? Color(0xFFFFA86A)
                                            : Colors.transparent,
                                    width: 3.h,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              child: AnimatedDefaultTextStyle(
                                duration: Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                  color:
                                      isSelected
                                          ? Color(0xFF333333)
                                          : Colors.grey,
                                ),
                                child: Center(child: Text(titles[tabIndex])),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                if (_selectedTabIndex == 0) // 라이프 탭
                  VillageDetailTab1(villageId: village.id)
                else if (_selectedTabIndex == 1) // 체험 탭
                  VillageDetailTab2(villageId: village.id)
                else if (_selectedTabIndex == 2) // 리뷰 탭
                  VillageDetailTab3(villageId: village.id),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }

  String formatUrl(String url) {
    return url.startsWith('http') ? url : 'https://$url';
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String content,
    Color? iconColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Icon(icon, size: 18.sp, color: iconColor ?? Colors.black),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80.w,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                Expanded(
                  child:
                      (label == '홈페이지' && content.trim().isNotEmpty)
                          ? TextButton.icon(
                            onPressed: () async {
                              final uri = Uri.parse(formatUrl(content));
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              } else {
                                print('❌ 실행 불가: $uri');
                              }
                            },
                            icon: Icon(
                              Icons.open_in_new,
                              size: 18.sp,
                              color: Colors.blue,
                            ),
                            label: Text(
                              '${widget.village.name} 홈페이지 바로가기',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.blue,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              alignment: Alignment.centerLeft,
                            ),
                          )
                          : Text(
                            content,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconTextButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    Color iconColor;

    if (icon == Icons.favorite_border || icon == Icons.favorite) {
      iconColor = Colors.red;
    } else if (icon == Icons.share_outlined || icon == Icons.share) {
      iconColor = Colors.blueGrey;
    } else {
      iconColor = Colors.black87;
    }

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: iconColor),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
