// lib/search/services/village_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youthbuk/search/models/village.dart';

class VillageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 제외할 주요 5개 지역명
  static const List<String> excludedRegions = [
    '청주시',
    '충주시',
    '제천시',
    '보은군',
    '옥천군',
  ];

  /// 특정 시군구명(regionName)으로 조회
  Future<List<Village>> fetchByRegionName(String regionName) async {
    final snap =
        await _firestore
            .collection('Villages')
            .where('시군구명', isEqualTo: regionName)
            .get();
    return snap.docs.map((d) => Village.fromDoc(d)).toList();
  }

  /// “그 외” 지역: excludedRegions에 없는 문서들 조회
  Future<List<Village>> fetchOthers() async {
    // Firestore의 whereNotIn 연산:
    //   whereNotIn 리스트에 없는 시군구명 문서만 가져옴.
    //
    // 주의: whereNotIn에 사용되는 리스트의 길이는 최대 10개까지 허용됩니다.
    // excludedRegions가 5개이므로 안전합니다.
    //
    // 또 한 가지: Firestore 쿼리는 '시군구명' 필드가 없는 문서는 whereNotIn 결과에 포함되지 않을 수 있습니다.
    //   - Firestore 문서에는 whereNotIn 동작이 “필드가 없으면 일치하지 않는 것으로 본다”는 명세가 있습니다.
    //   - 만약 '시군구명' 필드가 없는 문서까지 “그 외”에 포함시키고 싶다면,
    //     쿼리로는 필드가 없는 문서를 포함하기 어려우므로,
    //     모든 문서를 가져온 뒤 클라이언트에서 필터링해야 합니다. (다만 비용 문제 발생 가능)
    //
    // 일반적으로는 모든 문서가 '시군구명' 필드를 가지도록 데이터를 설계하는 편이 바람직합니다.
    final snap =
        await _firestore
            .collection('Villages')
            .where('시군구명', whereNotIn: excludedRegions)
            .get();
    return snap.docs.map((d) => Village.fromDoc(d)).toList();
  }

  /// “그 외” 지역을 시군구명별로 그룹핑해서 Map으로 반환
  Future<Map<String, List<Village>>> fetchOthersGroupedByCity() async {
    final villages = await fetchOthers();
    final Map<String, List<Village>> grouped = {};
    for (var v in villages) {
      // Village 모델에 cityName 필드를 추가하여, Firestore의 '시군구명'을 저장해두었다고 가정
      // 예: Village.fromDoc 생성자에서 data['시군구명']을 v.cityName에 할당
      final city = v.cityName?.trim() ?? '기타';
      if (city.isEmpty) continue;
      grouped.putIfAbsent(city, () => []).add(v);
    }
    // 그룹별로 정렬이 필요하면, 예: 키 알파벳 순 또는 다른 기준
    final sortedKeys = grouped.keys.toList()..sort((a, b) => a.compareTo(b));
    final Map<String, List<Village>> sortedGrouped = {
      for (var k in sortedKeys)
        k: grouped[k]!..sort((a, b) => a.name.compareTo(b.name)),
    };
    return sortedGrouped;
  }
}
