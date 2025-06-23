import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  bool isSheetOpen = false;
  bool showSheet = false;

  List<Map<String, dynamic>> albas = [];
  List<Map<String, dynamic>> livings = [];
  List<Map<String, dynamic>> filteredList = [];
  String selectedCategory = '전체';

  Position? _currentPosition;
  LatLngBounds? _currentBounds;

  final List<String> categories = ['전체', '살아보기', '알바'];
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
            'title': title ?? '알바',
            'lat': lat,
            'lng': lng,
            'company': data['company'] ?? '',
            'salary': data['salary'] ?? '',
            'workTime': data['workTime'] ?? '',
            '모집인원': data['모집인원'] ?? '',
            '대표자명': data['대표자명'] ?? '',
            '대표전화번호': data['대표전화번호'] ?? '',
            '마을명': data['마을명'] ?? '',
            'imageUrl': data['imageUrl'] ?? '',
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
            'imageUrl': data['imageUrl'] ?? '',
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
    List<Map<String, dynamic>> dataSource =
        selectedCategory == '살아보기'
            ? livings
            : selectedCategory == '알바'
            ? albas
            : [...albas, ...livings];

    if (_currentBounds != null) {
      dataSource =
          dataSource.where((pos) {
            final lat = pos['lat'] as double;
            final lng = pos['lng'] as double;
            return _currentBounds!.contains(LatLng(lat, lng));
          }).toList();
    }

    for (var pos in dataSource) {
      BitmapDescriptor icon =
          selectedCategory == '전체'
              ? (livings.contains(pos)
                  ? BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  )
                  : BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ))
              : selectedCategory == '살아보기'
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
              : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

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
          onTap: () {
            setState(() {
              filteredList = [pos];
              showSheet = true;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_sheetController.isAttached) {
                _sheetController.animateTo(
                  0.45,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
                setState(() => isSheetOpen = true);
              }
            });
          },
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
      filteredList.clear();
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

  void _onCameraMoveStarted() {
    setState(() {
      filteredList.clear();
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
      final bounds = await controller.getVisibleRegion();
      setState(() {
        _currentBounds = bounds;
        _updateMarkers();
      });
    }
  }

  void _toggleSheet() {
    if (_sheetController.isAttached) {
      if (isSheetOpen) {
        _sheetController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        setState(() {
          isSheetOpen = false;
          showSheet = false;
        });
      } else {
        _sheetController.animateTo(
          0.45,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
        setState(() {
          isSheetOpen = true;
          showSheet = true;
        });
      }
    } else {
      setState(() => showSheet = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_sheetController.isAttached) {
          _sheetController.animateTo(
            0.45,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
          setState(() => isSheetOpen = true);
        }
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

  Widget _buildMapControlButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white60.withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 2)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.deepOrange.shade400),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        filteredList.isNotEmpty
            ? filteredList
            : _currentBounds != null
            ? (selectedCategory == '살아보기'
                    ? livings
                    : selectedCategory == '알바'
                    ? albas
                    : [...albas, ...livings])
                .where((pos) {
                  final lat = pos['lat'] as double;
                  final lng = pos['lng'] as double;
                  return _currentBounds!.contains(LatLng(lat, lng));
                })
                .toList()
            : (selectedCategory == '전체'
                ? [...albas, ...livings]
                : selectedCategory == '살아보기'
                ? livings
                : albas);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset('assets/images/logo_3d.png', width: 30, height: 30),
                const SizedBox(width: 6),
                const Text(
                  '청춘북',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
              ],
            ),
            const Text(
              '알바 / 살아보기 지도',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
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
                      : const LatLng(36.6244, 127.3034),
              zoom: 13,
            ),
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _mapController.complete(controller),
            onCameraMove: _onCameraMove,
            onCameraMoveStarted: _onCameraMoveStarted,
            onTap: (_) {
              if (filteredList.length == 1) {
                setState(() {
                  filteredList.clear();
                  _updateMarkers();
                });
              }
            },
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
          if (showSheet)
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: 0.45,
              minChildSize: 0.1,
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return NotificationListener<DraggableScrollableNotification>(
                  onNotification: (notification) {
                    if (notification.extent <= 0.12 && isSheetOpen) {
                      _toggleSheet();
                    }
                    return false;
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 12),
                      ],
                    ),
                    child: AlbaList(
                      albas: filtered,
                      scrollController: scrollController,
                      category: selectedCategory == '알바' ? '알바' : '살아보기',
                    ),
                  ),
                );
              },
            ),
          Positioned(
            bottom: 24,
            left: 12,
            child: Column(
              children: [
                _buildMapControlButton(Icons.add, _zoomIn),
                _buildMapControlButton(Icons.remove, _zoomOut),
                const SizedBox(height: 12),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.my_location, color: Colors.orange),
                    onPressed: _goToCurrentLocation,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            right: 12,
            child: ElevatedButton.icon(
              onPressed: _toggleSheet,
              icon: Icon(showSheet ? Icons.map : Icons.list),
              label: Text(showSheet ? '지도보기' : '목록보기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
