// lib/search/services/village_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youthbuk/search/models/village.dart';

class VillageRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 특정 시군구명(regionName)으로 조회
  Future<List<Village>> fetchByRegionName(String regionName) async {
    final snap =
        await _firestore
            .collection('Villages')
            .where('시군구명', isEqualTo: regionName)
            .get();
    return snap.docs.map((d) => Village.fromDoc(d)).toList();
  }
}
