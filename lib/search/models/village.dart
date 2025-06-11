// lib/search/models/village.dart
import 'package:cloud_firestore/cloud_firestore.dart';
// 만약 Google Maps Flutter 플러그인 등을 쓸 경우 LatLng 타입을 import
// import 'package:google_maps_flutter/google_maps_flutter.dart';

class Village {
  final String id;
  final String name; // 체험마을명
  final String categoryRaw; // 체험프로그램구분 원문
  final List<String> categories; // categoryRaw.split('+')
  final String programsRaw; // 체험프로그램명 원문
  final List<String> programNames; // programsRaw.split('+')
  final double? averageRatingStored; // 문서에 미리 저장된 평균 평점
  final int? reviewCountStored; // 문서에 미리 저장된 리뷰 개수
  final double? latitude; // 위도
  final double? longitude; // 경도
  final String? address; // 소재지도로명주소
  final String? phone; // 대표전화번호
  final String? managerName; // 관리기관명
  final String? homepage; // 홈페이지주소
  final DateTime? syncedAt; // syncedAt 필드
  final List<String>? photoUrls; // 체험휴양마을사진 URL 리스트

  Village({
    required this.id,
    required this.name,
    required this.categoryRaw,
    required this.categories,
    required this.programsRaw,
    required this.programNames,
    this.averageRatingStored,
    this.reviewCountStored,
    this.latitude,
    this.longitude,
    this.address,
    this.phone,
    this.managerName,
    this.homepage,
    this.syncedAt,
    this.photoUrls,
  });

  factory Village.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // 1. 기본 텍스트 필드들
    final String name = data['체험마을명'] as String? ?? '';
    final String categoryRaw = data['체험프로그램구분'] as String? ?? '';
    final List<String> categories =
        categoryRaw.isNotEmpty
            ? categoryRaw
                .split('+')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList()
            : [];
    final String programsRaw = data['체험프로그램명'] as String? ?? '';
    final List<String> programNames =
        programsRaw.isNotEmpty
            ? programsRaw
                .split('+')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList()
            : [];

    // 2. 평점/리뷰 개수 (optional)
    double? avgStored;
    if (data.containsKey('rating')) {
      final v = data['rating'];
      if (v is num) avgStored = v.toDouble();
    }
    int? countStored;
    if (data.containsKey('reviewCount')) {
      final v = data['reviewCount'];
      if (v is int) countStored = v;
    }

    // 3. 위치: GeoPoint 또는 개별 위도/경도 필드
    double? lat, lng;
    if (data['location'] is GeoPoint) {
      final gp = data['location'] as GeoPoint;
      lat = gp.latitude;
      lng = gp.longitude;
    } else {
      if (data.containsKey('위도')) {
        final v = data['위도'];
        if (v is num) lat = v.toDouble();
      }
      if (data.containsKey('경도')) {
        final v = data['경도'];
        if (v is num) lng = v.toDouble();
      }
    }

    // 4. 기타 정보
    String? address = data['소재지도로명주소'] as String?;
    String? phone = data['대표전화번호'] as String?;
    String? managerName = data['관리기관명'] as String?;
    String? homepage = data['홈페이지주소'] as String?;

    DateTime? syncedAt;
    if (data['syncedAt'] is Timestamp) {
      syncedAt = (data['syncedAt'] as Timestamp).toDate();
    }

    // 5. 사진: '체험휴양마을사진' 필드.
    List<String>? photoUrls;
    if (data.containsKey('체험휴양마을사진')) {
      final raw = data['체험휴양마을사진'];
      if (raw is List) {
        try {
          photoUrls = raw.map((e) => e.toString()).toList();
        } catch (_) {
          photoUrls = null;
        }
      } else if (raw is String) {
        if (raw.trim().isNotEmpty) {
          photoUrls = [raw.trim()];
        }
      }
    }

    return Village(
      id: doc.id,
      name: name,
      categoryRaw: categoryRaw,
      categories: categories,
      programsRaw: programsRaw,
      programNames: programNames,
      averageRatingStored: avgStored,
      reviewCountStored: countStored,
      latitude: lat,
      longitude: lng,
      address: address,
      phone: phone,
      managerName: managerName,
      homepage: homepage,
      syncedAt: syncedAt,
      photoUrls: photoUrls,
    );
  }

  // --- 이하 유틸리티 메서드/Getter 추가 예시 ---

  /// 만약 Google Maps Flutter의 LatLng 타입을 쓰고 싶다면:
  /*
  LatLng? get latLng {
    if (latitude != null && longitude != null) {
      return LatLng(latitude!, longitude!);
    }
    return null;
  }
  */

  /// GeoPoint로 저장하거나 업데이트할 때 사용할 수 있는 Getter
  GeoPoint? get geoPoint {
    if (latitude != null && longitude != null) {
      return GeoPoint(latitude!, longitude!);
    }
    return null;
  }

  /// 프로그램 목록이 비어있지 않다면 Chip 등에 바로 이용
  bool get hasPrograms => programNames.isNotEmpty;

  /// 사진이 있을 경우 첫 번째 대표 이미지 URL
  String? get thumbnailUrl {
    if (photoUrls != null && photoUrls!.isNotEmpty) {
      return photoUrls!.first;
    }
    return null;
  }

  /// toMap: 문서 쓰기/업데이트용으로 변환 (필요 시)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      '체험마을명': name,
      '체험프로그램구분': categoryRaw,
      '체험프로그램명': programsRaw,
      // 위치는 geoPoint가 있을 때만:
      if (geoPoint != null) 'location': geoPoint,
      if (address != null) '소재지도로명주소': address,
      if (phone != null) '대표전화번호': phone,
      if (managerName != null) '관리기관명': managerName,
      if (homepage != null) '홈페이지주소': homepage,
      if (photoUrls != null) '체험휴양마을사진': photoUrls,
      if (syncedAt != null) 'syncedAt': Timestamp.fromDate(syncedAt!),
      // rating, reviewCount 등 aggregate 필드는 별도 로직에서 업데이트
    };
    return map;
  }
}
