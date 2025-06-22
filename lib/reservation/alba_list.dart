import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlbaList extends StatelessWidget {
  final List<Map<String, dynamic>> albas;
  final String category;
  final ScrollController? scrollController;

  const AlbaList({
    required this.albas,
    required this.category,
    this.scrollController,
    super.key,
  });

  String? formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      return null;
    }
    return DateFormat('yyyy.MM.dd').format(date);
  }

  String? formatPeriod(Map<String, dynamic>? period) {
    if (period == null) return null;
    final start = formatTimestamp(period['시작일']);
    final end = formatTimestamp(period['종료일']);
    if (start != null && end != null) return '$start ~ $end';
    if (start != null) return '시작일: $start';
    if (end != null) return '종료일: $end';
    return null;
  }

  String nonEmptyOrDefault(dynamic value) {
    if (value == null || (value is String && value.trim().isEmpty)) {
      return '미제공';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (albas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                '현재 모집 중인 공고가 없습니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        // 상단 회색 바
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 리스트
        Expanded(
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: albas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final alba = albas[index];
              final isAlba = category == '알바';

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이미지 영역
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey.shade200,
                        child: Icon(
                          isAlba ? Icons.work_outline : Icons.home_outlined,
                          size: 40,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),

                    // 텍스트 정보
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.pink.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isAlba ? '알바' : '살아보기',
                                    style: TextStyle(
                                      color: Colors.pink,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isAlba ? '체험' : '체험',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              nonEmptyOrDefault(alba['title']),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isAlba
                                  ? nonEmptyOrDefault(alba['salary'])
                                  : nonEmptyOrDefault(
                                    formatPeriod(_safeMap(alba['운영기간'])),
                                  ),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 찜 아이콘
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Icon(
                        Icons.favorite_border,
                        color: Colors.grey.shade400,
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

  Map<String, dynamic>? _safeMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return null;
  }
}
