// lib/search/services/review_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:youthbuk/search/models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _firestore;

  ReviewService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// 최근 n개 리뷰 조회
  Future<List<Review>> fetchRecentReviews({
    required String villageName,
    int limit = 5,
  }) async {
    final querySnap =
        await _firestore
            .collection('villages_review')
            .where('체험마을명', isEqualTo: villageName)
            .orderBy('create_at', descending: true)
            .limit(limit)
            .get();
    return querySnap.docs.map((d) => Review.fromDocument(d)).toList();
  }

  /// 전체 리뷰 조회
  Future<List<Review>> fetchAllReviews({required String villageName}) async {
    final querySnap =
        await _firestore
            .collection('villages_review')
            .where('체험마을명', isEqualTo: villageName)
            .orderBy('create_at', descending: true)
            .get();
    return querySnap.docs.map((d) => Review.fromDocument(d)).toList();
  }

  /// 사용자별 리뷰 조회
  Future<List<Review>> fetchReviewsByUser({required String authorId}) async {
    final querySnap =
        await _firestore
            .collection('villages_review')
            .where('authorId', isEqualTo: authorId)
            .orderBy('create_at', descending: true)
            .get();
    return querySnap.docs.map((d) => Review.fromDocument(d)).toList();
  }

  /// 리뷰 저장 (중복 허용)
  Future<void> saveReviewAllowDuplicates({
    required String villageName,
    required String content,
    required double star,
    String? title,
    List<String>? hashtags,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'NOT_SIGNED_IN',
        message: '로그인이 필요합니다.',
      );
    }
    final uid = user.uid;

    // 현재 사용자의 닉네임을 가져옴: users 컬렉션의 nickname 우선, 없으면 FirebaseAuth displayName 사용
    final nickname = await _getCurrentUserNickname(uid);
    final authorNickname = nickname.isNotEmpty ? nickname : '익명';

    final collectionRef = _firestore.collection('villages_review');
    final serverNow = FieldValue.serverTimestamp();

    // 문서 ID: uid 또는 uid_suffix 형태로 중복 허용
    String docIdBase = uid;
    String newDocId = docIdBase;
    int suffix = 0;
    while (true) {
      final docRef = collectionRef.doc(newDocId);
      final docSnap = await docRef.get();
      if (!docSnap.exists) break;
      suffix += 1;
      newDocId = '${docIdBase}_$suffix';
    }

    // 데이터 맵 구성: authorId, authorNickname 포함
    final docRef = collectionRef.doc(newDocId);
    final dataMap = <String, dynamic>{
      'authorId': uid,
      'authorNickname': authorNickname,
      '체험마을명': villageName,
      'content': content,
      'star': star,
      'create_at': serverNow,
      'update_at': serverNow,
    };
    if (title != null && title.trim().isNotEmpty) {
      dataMap['title'] = title.trim();
    }
    if (hashtags != null && hashtags.isNotEmpty) {
      dataMap['hashtags'] = hashtags;
    }

    await docRef.set(dataMap);

    // Villages 집계 업데이트: 가능하면 Cloud Function으로 이전 권장
    await updateVillageRating(villageName);
  }

  /// 리뷰 삭제
  Future<void> deleteReview({required String docId}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'NOT_SIGNED_IN',
        message: '로그인이 필요합니다.',
      );
    }
    final uid = user.uid;

    final docRef = _firestore.collection('villages_review').doc(docId);
    final docSnap = await docRef.get();
    if (!docSnap.exists) {
      throw FirebaseException(plugin: 'Firestore', message: '리뷰가 존재하지 않습니다.');
    }
    final data = docSnap.data();
    if (data == null || data['authorId'] != uid) {
      throw FirebaseException(plugin: 'Firestore', message: '삭제 권한이 없습니다.');
    }

    final villageName = data['체험마을명'] as String? ?? '';
    await docRef.delete();

    if (villageName.isNotEmpty) {
      await updateVillageRating(villageName);
    }
  }

  /// 리뷰 수정
  Future<void> updateReview({
    required String docId,
    required String villageName,
    required String content,
    required double star,
    String? title,
    List<String>? hashtags,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'NOT_SIGNED_IN',
        message: '로그인이 필요합니다.',
      );
    }
    final uid = user.uid;

    final docRef = _firestore.collection('villages_review').doc(docId);
    final docSnap = await docRef.get();
    if (!docSnap.exists) {
      throw FirebaseException(plugin: 'Firestore', message: '리뷰가 존재하지 않습니다.');
    }
    final dataExisting = docSnap.data();
    if (dataExisting == null || dataExisting['authorId'] != uid) {
      throw FirebaseException(plugin: 'Firestore', message: '수정 권한이 없습니다.');
    }

    // 기존 create_at, authorNickname, 체험마을명 보존
    final createAtValue = dataExisting['create_at'];
    final originalVillageName = dataExisting['체험마을명'] as String? ?? villageName;

    final serverNow = FieldValue.serverTimestamp();

    final updateMap = <String, dynamic>{
      'content': content,
      'star': star,
      'update_at': serverNow,
      'create_at': createAtValue,
    };
    if (title != null && title.trim().isNotEmpty) {
      updateMap['title'] = title.trim();
    } else {
      updateMap['title'] = FieldValue.delete();
    }
    if (hashtags != null) {
      updateMap['hashtags'] =
          hashtags.isNotEmpty ? hashtags : FieldValue.delete();
    }

    await docRef.update(updateMap);

    if (originalVillageName.isNotEmpty) {
      await updateVillageRating(originalVillageName);
    }
  }

  /// 마을 평점/리뷰 수 갱신
  Future<void> updateVillageRating(String villageName) async {
    final reviewsQuery =
        await _firestore
            .collection('villages_review')
            .where('체험마을명', isEqualTo: villageName)
            .get();

    final docs = reviewsQuery.docs;
    final reviewCount = docs.length;

    if (reviewCount == 0) {
      await _firestore.collection('Villages').doc(villageName).update({
        'reviewCount': 0,
        'rating': 0,
      });
      return;
    }

    double totalStar = 0;
    for (var doc in docs) {
      final star = doc.data()['star'];
      if (star is num) {
        totalStar += star.toDouble();
      }
    }
    final average = double.parse((totalStar / reviewCount).toStringAsFixed(1));

    await _firestore.collection('Villages').doc(villageName).update({
      'reviewCount': reviewCount,
      'rating': average,
    });
  }

  /// 현재 사용자의 nickname 가져오기:
  /// Firestore users/{uid}.nickname 우선, 없으면 FirebaseAuth displayName 사용
  Future<String> _getCurrentUserNickname(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        final nick = data?['nickname'] as String?;
        if (nick != null && nick.trim().isNotEmpty) {
          return nick.trim();
        }
        final dispField = data?['displayName'] as String?;
        if (dispField != null && dispField.trim().isNotEmpty) {
          return dispField.trim();
        }
      }
    } catch (_) {
      // Firestore 조회 실패 시 폴백
    }

    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName;
    if (displayName != null && displayName.trim().isNotEmpty) {
      return displayName.trim();
    }

    return '';
  }
}
