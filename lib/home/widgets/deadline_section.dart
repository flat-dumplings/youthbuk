import 'package:flutter/material.dart';
import 'package:youthbuk/home/widgets/title_header.dart';

class DeadlineSection extends StatelessWidget {
  const DeadlineSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dummyData = [
      {
        'title': '(잠실)잠실원샷 4층 3루',
        'company': '라지칠리새우(4층)',
        'price': '23,500원',
        'imagePath': 'assets/images/login_logo.png',
        'deadline': DateTime.now(),
        'region': '충주',
      },
      {
        'title': '(잠실)잠실원샷 4층 3루',
        'company': '라지어니언텅지치킨(4층)',
        'price': '19,000원',
        'imagePath': 'assets/images/login_logo.png',
        'deadline': DateTime.now().add(Duration(days: 1)),
        'region': '제천',
      },
      {
        'title': '(미스터피자)광장점',
        'company': '포테이토골드킹',
        'price': '39,500원',
        'imagePath': 'assets/images/login_logo.png',
        'deadline': DateTime.now().add(Duration(days: 100)),
        'region': '청주',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TitleHeader(title: '마감 임박 체험 🔥', subTitle: '마감 임박한 체험 입니다!'),
        const SizedBox(height: 5),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: dummyData.length,
            separatorBuilder: (_, __) => const SizedBox(width: 18),
            itemBuilder: (context, index) {
              final data = dummyData[index];
              // deadline: DateTime 타입이라 가정
              final DateTime deadline = data['deadline'] as DateTime;
              final DateTime today = DateTime.now();

              // 날짜만 비교하기 위해 시간 제외
              final DateTime todayDateOnly = DateTime(
                today.year,
                today.month,
                today.day,
              );
              final DateTime deadlineDateOnly = DateTime(
                deadline.year,
                deadline.month,
                deadline.day,
              );

              final difference =
                  deadlineDateOnly.difference(todayDateOnly).inDays;

              String deadlineText;
              if (difference > 0) {
                deadlineText = 'D-$difference';
              } else if (difference == 0) {
                deadlineText = '오늘 마감';
              } else {
                deadlineText = '마감';
              }
              return Container(
                width: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.asset(
                            data['imagePath']!,
                            width: double.infinity,
                            height: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.7),
                                  blurRadius: 2,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              deadlineText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min, // 크기 텍스트와 아이콘만큼만
                              children: [
                                const Icon(
                                  Icons.location_on, // 위치 아이콘
                                  size: 14,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 4), // 아이콘과 텍스트 간격
                                Text(
                                  data['region']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['price']!,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Color(0xFF222222),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '1.2억',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['title']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF222222),
                            ),
                          ),
                        ],
                      ),
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
}
