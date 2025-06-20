import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'category_filter.dart';
import 'alba_list.dart';

class AlbaMapPage extends StatefulWidget {
  const AlbaMapPage({super.key});

  @override
  State<AlbaMapPage> createState() => _AlbaMapPageState();
}

class _AlbaMapPageState extends State<AlbaMapPage> {
  final Completer<GoogleMapController> _mapController = Completer();

  List<Map<String, dynamic>> albas = [];
  List<Map<String, dynamic>> livings = [];
  String selectedCategory = '전체';

  Position? _currentPosition;
  LatLngBounds? _currentBounds; // 현재 지도에 보이는 영역

  final List<String> categories = ['전체', '살아보기', '아르바이트'];

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _determinePosition().then((_) => _loadData());
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = pos;
    });
  }

  Future<void> _loadData() async {
    try {
      final albaSnapshot =
          await FirebaseFirestore.instance.collectionGroup('alba').get();

      final tempAlbas = <Map<String, dynamic>>[];
      for (var doc in albaSnapshot.docs) {
        final data = doc.data();

        double? lat =
            (data['위도'] ?? data['lat'] ?? data['latitude'])?.toDouble();
        double? lng =
            (data['경도'] ?? data['lng'] ?? data['longitude'])?.toDouble();
        String? title = data['마을명'] ?? data['title'] ?? doc.id;

        if (lat != null && lng != null) {
          tempAlbas.add({
            'title': title ?? '아르바이트',
            'lat': lat,
            'lng': lng,
            'company': data['company'] ?? '',
            'salary': data['salary'] ?? '',
            'workTime': data['workTime'] ?? '',
            '모집인원': data['모집인원'] ?? '',
            '대표자명': data['대표자명'] ?? '',
            '대표전화번호': data['대표전화번호'] ?? '',
            '마을명': data['마을명'] ?? '',
          });
        }
      }

      final livingSnapshot =
          await FirebaseFirestore.instance.collectionGroup('living').get();

      final tempLivings = <Map<String, dynamic>>[];
      for (var doc in livingSnapshot.docs) {
        final data = doc.data();

        double? lat =
            (data['위도'] ?? data['lat'] ?? data['latitude'])?.toDouble();
        double? lng =
            (data['경도'] ?? data['lng'] ?? data['longitude'])?.toDouble();
        String? title = data['마을명'] ?? data['title'] ?? doc.id;

        if (lat != null && lng != null) {
          tempLivings.add({
            'title': title ?? '살아보기',
            'lat': lat,
            'lng': lng,
            'company': data['company'] ?? '',
            'salary': data['salary'] ?? '',
            'workTime': data['workTime'] ?? '',
            '모집인원': data['모집인원'] ?? '',
            '대표자명': data['대표자명'] ?? '',
            '대표전화번호': data['대표전화번호'] ?? '',
            '마을명': data['마을명'] ?? '',
            '세부유형': data['세부유형'] ?? '',
            '입주가능일': data['입주가능일'] ?? '',
            '운영기간': data['운영기간'] ?? '',
          });
        }
      }

      setState(() {
        albas = tempAlbas;
        livings = tempLivings;
        _updateMarkers();
      });
    } catch (e) {
      debugPrint('Firestore 데이터 로드 실패: $e');
    }
  }

  void _updateMarkers() {
    Set<Marker> newMarkers = {};

    List<Map<String, dynamic>> dataSource;
    if (selectedCategory == '살아보기') {
      dataSource = livings;
    } else if (selectedCategory == '아르바이트') {
      dataSource = albas;
    } else {
      dataSource = [...albas, ...livings];
    }

    // 화면에 보이는 영역 기준 필터링
    if (_currentBounds != null) {
      dataSource =
          dataSource.where((pos) {
            final lat = pos['lat'] as double;
            final lng = pos['lng'] as double;
            return _currentBounds!.contains(LatLng(lat, lng));
          }).toList();
    }

    for (var pos in dataSource) {
      // 전체보기일 때 livings는 빨간색, albas는 파란색 마커로 구분
      BitmapDescriptor icon;
      if (selectedCategory == '전체') {
        if (livings.contains(pos)) {
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
        } else {
          icon = BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueBlue,
          );
        }
      } else if (selectedCategory == '살아보기') {
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      } else {
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      }

      newMarkers.add(
        Marker(
          markerId: MarkerId(
            '${selectedCategory}_${pos['title']}_${pos['lat']}_${pos['lng']}',
          ),
          position: LatLng(pos['lat'], pos['lng']),
          icon: icon,
          infoWindow: InfoWindow(
            title: pos['title'],
            snippet: pos['company'] ?? '',
          ),
        ),
      );
    }

    setState(() {
      markers = newMarkers;
    });
  }

  void _onCategoryChanged(String category) {
    setState(() {
      selectedCategory = category;
    });
    _updateMarkers();
  }

  void _onCameraMove(CameraPosition position) async {
    final controller = await _mapController.future;
    final bounds = await controller.getVisibleRegion();
    setState(() {
      _currentBounds = bounds;
      _updateMarkers();
    });
  }

  void _goToCurrentLocation() async {
    final controller = await _mapController.future;
    if (_currentPosition != null) {
      final latLng = LatLng(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      controller.animateCamera(CameraUpdate.newLatLngZoom(latLng, 13));

      // 카메라 이동 후 영역 갱신
      final bounds = await controller.getVisibleRegion();
      setState(() {
        _currentBounds = bounds;
        _updateMarkers();
      });
    }
  }

  void _zoomIn() async {
    final controller = await _mapController.future;
    final currentZoom = await controller.getZoomLevel();
    controller.animateCamera(CameraUpdate.zoomTo(currentZoom + 1));
  }

  void _zoomOut() async {
    final controller = await _mapController.future;
    final currentZoom = await controller.getZoomLevel();
    controller.animateCamera(CameraUpdate.zoomTo(currentZoom - 1));
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filtered;
    if (_currentBounds != null) {
      if (selectedCategory == '살아보기') {
        filtered =
            livings.where((pos) {
              final lat = pos['lat'] as double;
              final lng = pos['lng'] as double;
              return _currentBounds!.contains(LatLng(lat, lng));
            }).toList();
      } else if (selectedCategory == '아르바이트') {
        filtered =
            albas.where((pos) {
              final lat = pos['lat'] as double;
              final lng = pos['lng'] as double;
              return _currentBounds!.contains(LatLng(lat, lng));
            }).toList();
      } else {
        filtered =
            [...albas, ...livings].where((pos) {
              final lat = pos['lat'] as double;
              final lng = pos['lng'] as double;
              return _currentBounds!.contains(LatLng(lat, lng));
            }).toList();
      }
    } else {
      filtered =
          selectedCategory == '전체'
              ? [...albas, ...livings]
              : selectedCategory == '살아보기'
              ? livings
              : albas;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('알바 지도 - 구글 맵 (Firestore)')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  _currentPosition != null
                      ? LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      )
                      : const LatLng(36.6244, 127.3034), // 오송역 기본 좌표
              zoom: 13,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) => _mapController.complete(controller),
            onCameraMove: _onCameraMove,
          ),
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
                  albas: filtered,
                  scrollController: scrollController,
                  category: selectedCategory == '아르바이트' ? '아르바이트' : '살아보기',
                ),
              );
            },
          ),
          Positioned(
            bottom: 24,
            right: 12,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: null,
                  mini: true,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: null,
                  mini: true,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: null,
                  mini: true,
                  onPressed: _goToCurrentLocation,
                  child: const Icon(Icons.my_location),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
