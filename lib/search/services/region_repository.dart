// lib/search/services/region_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youthbuk/search/models/region.dart';

class RegionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const List<String> mainRegions = ['괴산군', '충주시', '보은군', '단양군', '제천시'];

  Future<List<RegionCount>> fetchRegionCounts() async {
    final snap = await _firestore.collection('Villages').get();
    final docs = snap.docs;
    final Map<String, int> counts = {};
    for (var doc in docs) {
      final data = doc.data();
      final rn = data['시군구명'] as String? ?? '알수없음';
      counts[rn] = (counts[rn] ?? 0) + 1;
    }
    // 주요 5개
    final List<RegionCount> result = [];
    int othersSum = 0;
    for (var mr in mainRegions) {
      result.add(RegionCount(name: mr, count: counts[mr] ?? 0));
    }
    counts.forEach((key, value) {
      if (!mainRegions.contains(key)) {
        othersSum += value;
      }
    });
    result.add(RegionCount(name: '그 외', count: othersSum));
    return result;
  }
}
