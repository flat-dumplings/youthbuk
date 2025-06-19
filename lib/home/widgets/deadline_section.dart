import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:youthbuk/home/widgets/title_header.dart';

class DeadlineSection extends StatefulWidget {
  const DeadlineSection({super.key});

  @override
  State<DeadlineSection> createState() => _DeadlineSectionState();
}

class _DeadlineSectionState extends State<DeadlineSection> {
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  // 현재 위치 가져오기
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스 비활성 시 처리
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = pos;
    });
  }

  // 거리 계산 (km)
  double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000.0;
  }

  Stream<List<Map<String, dynamic>>> fetchTop5EndingSoonProgramsStream() {
    final firestore = FirebaseFirestore.instance;
    final nowUtc = DateTime.now().toUtc();

    return firestore
        .collectionGroup('programs')
        .where('endDate', isGreaterThan: Timestamp.fromDate(nowUtc))
        .orderBy('endDate')
        .limit(5)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) {
                final data = doc.data();
                return {
                  'title': data['name'] ?? '이름 없음',
                  'company': data['villageName'] ?? '마을명 없음',
                  'imagePath':
                      (data['photos'] != null &&
                              (data['photos'] as List).isNotEmpty)
                          ? (data['photos'] as List).first
                          : 'assets/images/login_logo.png',
                  'deadline': (data['endDate'] as Timestamp).toDate(),
                  'region': data['region'] ?? '지역 정보 없음',
                  'latitude': data['latitude'],
                  'longitude': data['longitude'],
                };
              }).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitleHeader(title: '마감 임박 체험 🔥', subTitle: '마감 전 빠르게 신청하세요!'),
        SizedBox(height: 10.h),
        SizedBox(
          height: 220.h,
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: fetchTop5EndingSoonProgramsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('오류 발생: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('마감 임박 프로그램이 없습니다.'));
              }

              final dataList = snapshot.data!;

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: dataList.length,
                separatorBuilder: (_, __) => SizedBox(width: 18.w),
                itemBuilder: (context, index) {
                  final data = dataList[index];
                  final DateTime deadline = data['deadline'] as DateTime;
                  final DateTime today = DateTime.now();

                  final DateTime todayOnly = DateTime(
                    today.year,
                    today.month,
                    today.day,
                  );
                  final DateTime deadlineOnly = DateTime(
                    deadline.year,
                    deadline.month,
                    deadline.day,
                  );
                  final difference = deadlineOnly.difference(todayOnly).inDays;

                  String deadlineText;
                  if (difference > 0) {
                    deadlineText = 'D-$difference';
                  } else if (difference == 0) {
                    deadlineText = '오늘 마감';
                  } else {
                    deadlineText = '마감';
                  }

                  double? distanceKm;
                  if (_currentPosition != null &&
                      data['latitude'] != null &&
                      data['longitude'] != null) {
                    distanceKm = calculateDistanceKm(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                      data['latitude'] as double,
                      data['longitude'] as double,
                    );
                  }

                  return Container(
                    width: 180.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      color: Colors.white,
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
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16.r),
                          ),
                          child: Stack(
                            children: [
                              Image.asset(
                                data['imagePath']!,
                                width: double.infinity,
                                height: 150.h,
                                fit: BoxFit.cover,
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        Color.fromARGB(120, 0, 0, 0),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10.h,
                                right: 10.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.deepOrangeAccent,
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.deepOrangeAccent
                                            .withOpacity(0.5),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    deadlineText,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              ),

                              // 중복된 거리 텍스트 제거 위해 아래 Positioned 삭제
                              Positioned(
                                bottom: 8.h,
                                left: 10.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6.w,
                                    vertical: 3.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 12.sp,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        distanceKm != null
                                            ? '${distanceKm.toStringAsFixed(1)} km'
                                            : '거리 정보 없음',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 60.h,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 6.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  data['company']!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  data['title']!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14.sp,
                                    color: Colors.black,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
