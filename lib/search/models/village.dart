// lib/search/models/village.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Village {
  final String id;
  final String name; // 체험마을명
  final String categoryRaw;
  final List<String> categories;
  final String programsRaw;
  final List<String> programNames;
  final double? averageRatingStored;
  final int? reviewCountStored;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? phone;
  final String? managerName;
  final String? homepage;
  final DateTime? syncedAt;
  final List<String>? photoUrls;

  // 시군구명 필드 추가 (nullable)
  final String? cityName;

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
    this.cityName,
  });

  factory Village.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // 1) 체험마을명
    final String name = data['체험마을명'] as String? ?? '';

    // 2) 카테고리Raw
    final String categoryRaw = data['체험프로그램구분'] as String? ?? '';
    final List<String> categories =
        categoryRaw.isNotEmpty
            ? categoryRaw
                .split('+')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList()
            : [];

    // 3) 프로그램Raw
    final String programsRaw = data['체험프로그램명'] as String? ?? '';
    final List<String> programNames =
        programsRaw.isNotEmpty
            ? programsRaw
                .split('+')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList()
            : [];

    // 4) 평점, 리뷰개수
    double? avgStored;
    if (data.containsKey('rating')) {
      final v = data['rating'];
      if (v is num) avgStored = v.toDouble();
    }
    int? countStored;
    if (data.containsKey('reviewCount')) {
      final v = data['reviewCount'];
      if (v is int)
        countStored = v;
      else if (v is num)
        countStored = v.toInt();
    }

    // 5) 위치 GeoPoint 또는 개별 위도/경도
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

    // 6) 기타 정보
    String? address = data['소재지도로명주소'] as String?;
    String? phone = data['대표전화번호'] as String?;
    String? managerName = data['관리기관명'] as String?;
    String? homepage = data['홈페이지주소'] as String?;

    DateTime? syncedAt;
    if (data['syncedAt'] is Timestamp) {
      syncedAt = (data['syncedAt'] as Timestamp).toDate();
    }

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

    // 7) 시군구명 (cityName) 안전하게 읽기
    String? cityName;
    if (data.containsKey('시군구명')) {
      final v = data['시군구명'];
      if (v is String) {
        cityName = v.trim();
      }
      // 만약 null 혹은 비문자열이면 cityName은 null 유지
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
      cityName: cityName,
    );
  }

  // --- Getter alias 등 ---
  double get rating => averageRatingStored ?? 0.0;
  int get reviewCount => reviewCountStored ?? 0;

  GeoPoint? get geoPoint {
    if (latitude != null && longitude != null) {
      return GeoPoint(latitude!, longitude!);
    }
    return null;
  }

  bool get hasPrograms => programNames.isNotEmpty;

  String? get thumbnailUrl {
    if (photoUrls != null && photoUrls!.isNotEmpty) {
      return photoUrls!.first;
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      '체험마을명': name,
      '체험프로그램구분': categoryRaw,
      '체험프로그램명': programsRaw,
      if (geoPoint != null) 'location': geoPoint,
      if (address != null) '소재지도로명주소': address,
      if (phone != null) '대표전화번호': phone,
      if (managerName != null) '관리기관명': managerName,
      if (homepage != null) '홈페이지주소': homepage,
      if (photoUrls != null) '체험휴양마을사진': photoUrls,
      if (syncedAt != null) 'syncedAt': Timestamp.fromDate(syncedAt!),
      // rating, reviewCount는 Cloud Function 또는 클라이언트 로직으로 관리
      if (cityName != null) '시군구명': cityName,
    };
    return map;
  }
}
