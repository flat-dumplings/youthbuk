// lib/services/user_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String nickname;
  final String address;
  final String phone;
  final List<int>? complete;
  final List<int>? inProgress;
  final int like;
  final int point;
  final int review;
  final DateTime? createdAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.nickname,
    required this.address,
    required this.phone,
    this.complete,
    this.inProgress,
    this.like = 0,
    this.point = 0,
    this.review = 0,
    this.createdAt,
  });

  Map<String, dynamic> toMapForCreate() {
    return {
      'name': name,
      'nickname': nickname,
      'address': address,
      'phone': phone,
      'complete': complete,
      'inProgress': inProgress,
      'like': like,
      'point': point,
      'review': review,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    List<int>? parseIntList(dynamic raw) {
      if (raw is List) {
        return raw
            .where((e) => e is int || e is num)
            .map((e) => (e as num).toInt())
            .toList();
      }
      return null;
    }

    DateTime? parseTimestamp(dynamic raw) {
      if (raw is Timestamp) {
        return raw.toDate();
      }
      return null;
    }

    return UserProfile(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      nickname: data['nickname'] as String? ?? '',
      address: data['address'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      complete: parseIntList(data['complete']),
      inProgress: parseIntList(data['inProgress']),
      like:
          (data['like'] is int)
              ? data['like'] as int
              : (data['like'] is num ? (data['like'] as num).toInt() : 0),
      point:
          (data['point'] is int)
              ? data['point'] as int
              : (data['point'] is num ? (data['point'] as num).toInt() : 0),
      review:
          (data['review'] is int)
              ? data['review'] as int
              : (data['review'] is num ? (data['review'] as num).toInt() : 0),
      createdAt: parseTimestamp(data['createdAt']),
    );
  }
}

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  /// 프로필 문서 생성 또는 덮어쓰기
  Future<void> createUserProfile(UserProfile profile) async {
    await _users.doc(profile.uid).set(profile.toMapForCreate());
  }

  /// 프로필 불러오기
  Future<UserProfile?> loadUserProfile(String uid) async {
    final docSnap = await _users.doc(uid).get();
    if (!docSnap.exists) return null;
    return UserProfile.fromFirestore(docSnap);
  }

  /// 프로필 일부 업데이트
  Future<void> updateUserProfile(
    String uid, {
    String? name,
    String? nickname,
    String? address,
    String? phone,
    List<int>? complete,
    List<int>? inProgress,
    int? like,
    int? point,
    int? review,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (nickname != null) data['nickname'] = nickname;
    if (address != null) data['address'] = address;
    if (phone != null) data['phone'] = phone;
    if (complete != null) data['complete'] = complete;
    if (inProgress != null) data['inProgress'] = inProgress;
    if (like != null) data['like'] = like;
    if (point != null) data['point'] = point;
    if (review != null) data['review'] = review;
    if (data.isNotEmpty) {
      await _users.doc(uid).update(data);
    }
  }

  /// 닉네임 중복 검사
  Future<bool> isNicknameTaken(String nickname, String currentUid) async {
    final querySnap =
        await _users.where('nickname', isEqualTo: nickname).limit(1).get();
    if (querySnap.docs.isEmpty) return false;
    final doc = querySnap.docs.first;
    return doc.id != currentUid;
  }

  /// 실시간 구독 예시
  Stream<UserProfile?> streamUserProfile(String uid) {
    return _users.doc(uid).snapshots().map((docSnap) {
      if (!docSnap.exists) return null;
      return UserProfile.fromFirestore(docSnap);
    });
  }
}
