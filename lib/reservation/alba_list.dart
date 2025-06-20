import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AlbaList extends StatelessWidget {
  final List<Map<String, dynamic>> albas;
  final String category; // '아르바이트' or '살아보기'
  final ScrollController? scrollController;

  const AlbaList({
    required this.albas,
    required this.category,
    this.scrollController,
    super.key,
  });

  // Timestamp -> 'yyyy년 M월 d일' 형식으로 변환, null이면 null 반환
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
    return DateFormat('yyyy년 M월 d일').format(date);
  }

  // 기간 필드(시작일, 종료일) 포맷팅, 없으면 null 반환
  String? formatPeriod(Map<String, dynamic>? period) {
    if (period == null) return null;
    final start = formatTimestamp(period['시작일']);
    final end = formatTimestamp(period['종료일']);
    if (start == null && end == null) return null;

    if (start != null && end != null) {
      return '$start ~ $end';
    }
    if (start != null) {
      return '시작일: $start';
    }
    if (end != null) {
      return '종료일: $end';
    }
    return null;
  }

  // 빈 문자열이나 null일 때 "미제공" 리턴
  String nonEmptyOrDefault(dynamic value) {
    if (value == null) return '미제공';
    if (value is String && value.trim().isEmpty) return '미제공';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    // 데이터 없을 때 로딩/빈 상태 처리
    if (albas.isEmpty) {
      return const _LoadingOrEmpty();
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: albas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final alba = albas[index];

        if (category == '아르바이트') {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.pink.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.work_outline,
                      size: 50,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nonEmptyOrDefault(alba['title']),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          nonEmptyOrDefault(alba['company']),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          '시급: ${nonEmptyOrDefault(alba['salary'])}',
                          style: const TextStyle(
                            color: Colors.pinkAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '근무시간: ${nonEmptyOrDefault(alba['workTime'])}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '모집인원: ${nonEmptyOrDefault(alba['모집인원'])}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '마을명: ${nonEmptyOrDefault(alba['마을명'])}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '대표자: ${nonEmptyOrDefault(alba['대표자명'])}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '전화번호: ${nonEmptyOrDefault(alba['대표전화번호'])}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (category == '살아보기') {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.home_outlined,
                      size: 50,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nonEmptyOrDefault(alba['title']),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '마을명: ${nonEmptyOrDefault(alba['마을명'])}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          '대표자: ${nonEmptyOrDefault(alba['대표자명'])}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '전화번호: ${nonEmptyOrDefault(alba['대표전화번호'])}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '모집인원: ${nonEmptyOrDefault(alba['모집인원'])}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '세부유형: ${nonEmptyOrDefault(alba['세부유형'])}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '입주가능일: ${formatTimestamp(alba['입주가능일']) ?? '미제공'}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '신청기간: ${formatPeriod(_safeMap(alba['신청기간'])) ?? '미제공'}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          '운영기간: ${formatPeriod(_safeMap(alba['운영기간'])) ?? '미제공'}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  // null 체크용 Map 변환 헬퍼
  Map<String, dynamic>? _safeMap(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    return null;
  }
}

// 로딩 및 빈 데이터 안내 위젯
class _LoadingOrEmpty extends StatelessWidget {
  const _LoadingOrEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(
            '데이터를 불러오는 중입니다...',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
