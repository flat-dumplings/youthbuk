// lib/search/services/region_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youthbuk/search/models/region.dart';

class RegionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 주요 5개 지역을 원하는 순서로 정의:
  /// 여기서 순서를 “충주시, 제천시, 보은군, 괴산군, 단양군”으로 지정했습니다.
  static const List<String> mainRegions = ['청주시', '충주시', '제천시', '보은군', '옥천군'];

  Future<List<RegionCount>> fetchRegionCounts() async {
    final snap = await _firestore.collection('Villages').get();
    final docs = snap.docs;
    final Map<String, int> counts = {};
    for (var doc in docs) {
      final data = doc.data();
      final rn = data['시군구명'] as String? ?? '알수없음';
      counts[rn] = (counts[rn] ?? 0) + 1;
    }
    // 주요 5개: mainRegions 순서대로 결과 리스트에 추가
    final List<RegionCount> result = [];
    int othersSum = 0;
    for (var mr in mainRegions) {
      result.add(RegionCount(name: mr, count: counts[mr] ?? 0));
    }
    // “그 외” 계산: mainRegions에 없는 나머지 지역의 합
    counts.forEach((key, value) {
      if (!mainRegions.contains(key)) {
        othersSum += value;
      }
    });
    result.add(RegionCount(name: '그 외', count: othersSum));
    return result;
  }
}
