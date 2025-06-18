import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    _loadAlbas();
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

    final positionsJson = filtered
        .map(
          (pos) => '''
      {title: "${pos['title']}", latlng: new kakao.maps.LatLng(${pos['lat']}, ${pos['lng']})}
    ''',
        )
        .join(',');

    final htmlString = MapView.buildHtml(positionsJson);
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

          // 카테고리 필터는 상단에 고정 배치
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

          // DraggableScrollableSheet 로 리스트를 드래그 가능하게
          DraggableScrollableSheet(
            initialChildSize: 0.45, // 처음엔 화면 45% 차지
            minChildSize: 0.1, // 최소 10%까지 줄일 수 있음
            maxChildSize: 0.9, // 최대 90%까지 확장 가능
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
                  scrollController: scrollController, // 스크롤 컨트롤러 전달
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
