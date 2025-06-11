// lib/search/services/like_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LikeService {
  final FirebaseFirestore _firestore;
  LikeService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 현재 로그인된 사용자 UID 반환, 없으면 null
  String? get currentUid {
    final u = FirebaseAuth.instance.currentUser;
    return u?.uid;
  }

  /// 사용자 카테고리 목록 조회: likes 컬렉션 하위의 문서 ID들
  Future<List<String>> fetchCategories() async {
    final uid = currentUid;
    if (uid == null) throw StateError('로그인이 필요합니다.');
    final snapshot =
        await _firestore.collection('users').doc(uid).collection('likes').get();
    // 문서 ID들이 카테고리 이름
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /// 특정 마을을 선택된 카테고리에 좋아요로 저장
  /// villageId: 저장할 문서 ID (보통 village.id)
  /// villageName: 마을 이름
  /// location: GeoPoint (위치) or null
  Future<void> saveLike({
    required String category,
    required String villageId,
    required String villageName,
    GeoPoint? location,
  }) async {
    final uid = currentUid;
    if (uid == null) throw StateError('로그인이 필요합니다.');
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('likes')
        .doc(category)
        .collection('villages')
        .doc(villageId);
    final data = <String, dynamic>{
      'villageName': villageName,
      'likedAt': FieldValue.serverTimestamp(),
    };
    if (location != null) {
      data['location'] = location;
    }
    await docRef.set(data);
  }
}
