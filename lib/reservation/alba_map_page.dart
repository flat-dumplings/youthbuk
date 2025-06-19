import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'category_filter.dart';
import 'alba_list.dart';
import 'map_view.dart';

class AlbaMapPage extends StatefulWidget {
  const AlbaMapPage({super.key});

  @override
  State<AlbaMapPage> createState() => _AlbaMapPageState();
}

class _AlbaMapPageState extends State<AlbaMapPage> {
  late final WebViewController _controller;
  List<Map<String, dynamic>> albas = [];
  String selectedCategory = '전체';

  Position? _currentPosition;

  final List<String> categories = [
    '전체',
    '케이크',
    '꽃다발',
    '주얼리',
    '반려동물',
    '디저트',
    '핸드폰악세서리',
    '토퍼',
    '공예',
    '드로잉',
    '의류',
  ];

  @override
  void initState() {
    super.initState();

    _controller =
        WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);

    _determinePosition().then((_) {
      _loadAlbas();
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스 비활성 시 처리
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = pos;
    });
  }

  Future<void> _loadAlbas() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('Villages').get();

      final List<Map<String, dynamic>> tempAlbas = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();

        double? lat;
        double? lng;

        if (data['location'] is GeoPoint) {
          final geo = data['location'] as GeoPoint;
          lat = geo.latitude;
          lng = geo.longitude;
        } else if (data['위도'] != null && data['경도'] != null) {
          lat = (data['위도'] as num).toDouble();
          lng = (data['경도'] as num).toDouble();
        } else {
          continue;
        }

        tempAlbas.add({
          'title':
              data['jobTitle']?.toString().replaceAll('"', '\\"') ?? doc.id,
          'lat': lat,
          'lng': lng,
          'category': data['category'] ?? '기타',
          'company': data['company'] ?? '',
          'salary': data['salary'] ?? '',
          'workTime': data['workTime'] ?? '',
        });
      }

      setState(() {
        albas = tempAlbas;
      });

      _loadMap();
    } catch (e) {
      print('Firestore 데이터 로드 실패: $e');
    }
  }

  void _loadMap() {
    final filtered =
        selectedCategory == '전체'
            ? albas
            : albas.where((e) => e['category'] == selectedCategory).toList();

    final positions =
        filtered.map((pos) {
          return {'title': pos['title'], 'lat': pos['lat'], 'lng': pos['lng']};
        }).toList();

    final positionsJson = jsonEncode(positions);

    final lat = _currentPosition?.latitude ?? 36.3504; // 기본값 설정
    final lng = _currentPosition?.longitude ?? 127.3845;

    final htmlString = MapView.buildHtml(positionsJson, lat, lng);
    _controller.loadHtmlString(htmlString);
  }

  void _onCategoryChanged(String category) {
    setState(() {
      selectedCategory = category;
      _loadMap();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredAlbas =
        selectedCategory == '전체'
            ? albas
            : albas.where((e) => e['category'] == selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('알바 지도 - 카카오 (Firestore)')),
      body: Stack(
        children: [
          Positioned.fill(child: WebViewWidget(controller: _controller)),

          // 카테고리 필터 상단 고정
          Positioned(
            top: 16,
            left: 8,
            right: 8,
            child: CategoryFilter(
              categories: categories,
              selectedCategory: selectedCategory,
              onCategorySelected: _onCategoryChanged,
            ),
          ),

          // 드래그 가능한 리스트
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.1,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 12),
                  ],
                ),
                child: AlbaList(
                  albas: filteredAlbas,
                  scrollController: scrollController,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
