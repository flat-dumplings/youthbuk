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
    final collectionRef = _firestore.collection('villages_review');
    final serverNow = FieldValue.serverTimestamp();

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

    final docRef = collectionRef.doc(newDocId);
    final dataMap = <String, dynamic>{
      'authorId': uid,
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
    final docRef = _firestore.collection('villages_review').doc(docId);
    final docSnap = await docRef.get();
    if (!docSnap.exists) {
      throw FirebaseException(plugin: 'Firestore', message: '리뷰가 존재하지 않습니다.');
    }
    final data = docSnap.data();
    if (data == null || data['authorId'] != user.uid) {
      throw FirebaseException(plugin: 'Firestore', message: '삭제 권한이 없습니다.');
    }
    final villageName = data['체험마을명'];
    await docRef.delete();
    await updateVillageRating(villageName);
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
    final docRef = _firestore.collection('villages_review').doc(docId);
    final docSnap = await docRef.get();
    if (!docSnap.exists) {
      throw FirebaseException(plugin: 'Firestore', message: '리뷰가 존재하지 않습니다.');
    }
    final dataExisting = docSnap.data();
    if (dataExisting == null || dataExisting['authorId'] != user.uid) {
      throw FirebaseException(plugin: 'Firestore', message: '수정 권한이 없습니다.');
    }

    final createAtValue = dataExisting['create_at'];
    final serverNow = FieldValue.serverTimestamp();
    final updateMap = <String, dynamic>{
      'content': content,
      'star': star,
      'update_at': serverNow,
      '체험마을명': villageName,
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
    await updateVillageRating(villageName);
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
}
