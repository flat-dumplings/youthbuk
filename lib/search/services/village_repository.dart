// lib/search/services/village_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youthbuk/search/models/village.dart';

class VillageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 주요 5개 지역명
  static const List<String> _mainRegions = ['괴산군', '충주시', '보은군', '단양군', '제천시'];

  /// regionName에 따라 Villages 조회
  /// - isOthers = false: 시군구명 == regionName
  /// - isOthers = true : 시군구명 NOT IN 주요 5개
  Future<List<Village>> fetchByRegionName(
    String regionName, {
    bool isOthers = false,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('Villages');

    if (isOthers) {
      // '그 외'인 경우: 주요 5개 지역이 아닌 문서만 조회
      // Firestore whereNotIn 제한(최대 10개) 주의. 주요 리스트가 5개라 안전.
      query = query.where('시군구명', whereNotIn: _mainRegions);
    } else {
      // 일반 지역
      query = query.where('시군구명', isEqualTo: regionName);
    }

    final snap = await query.get();
    return snap.docs.map((d) => Village.fromDoc(d)).toList();
  }

  /// 평점 순 상위 N개 조회 (추천 프로그램)
  Future<List<Village>> fetchTopVillagesByRating({int limit = 5}) async {
    final snap =
        await _firestore
            .collection('Villages')
            .orderBy('rating', descending: true)
            .limit(limit)
            .get();
    return snap.docs.map((d) => Village.fromDoc(d)).toList();
  }
}
