// lib/search/pages/village_detail_page.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youthbuk/search/all_reviews_page.dart';
import 'package:youthbuk/search/models/village.dart';
import 'package:youthbuk/search/widgets/recent_reviews_section.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youthbuk/search/widgets/like_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VillageDetailPage extends StatefulWidget {
  final Village village;
  const VillageDetailPage({super.key, required this.village});

  @override
  State<VillageDetailPage> createState() => _VillageDetailPageState();
}

class _VillageDetailPageState extends State<VillageDetailPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchWebsite(String url) async {
    Uri uri = Uri.tryParse(url) ?? Uri();
    if (uri.scheme.isEmpty) {
      uri = Uri.parse('https://$url');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchMap(double lat, double lng) async {
    final googleMapUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(googleMapUrl)) {
      await launchUrl(googleMapUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final villageId = widget.village.id;
    final docRef = _firestore.collection('Villages').doc(villageId);

    return StreamBuilder<DocumentSnapshot>(
      stream: docRef.snapshots(),
      builder: (context, snapshot) {
        // 오류 처리
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.village.name),
              leading: BackButton(),
              actions: [LikeButton(village: widget.village)],
            ),
            body: Center(child: Text('오류가 발생했습니다: ${snapshot.error}')),
          );
        }
        // 로딩 상태
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.village.name),
              leading: BackButton(),
              actions: [LikeButton(village: widget.village)],
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final doc = snapshot.data!;
        // 문서 없으면
        if (!doc.exists) {
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.village.name),
              leading: BackButton(),
              actions: [LikeButton(village: widget.village)],
            ),
            body: const Center(child: Text('마을 정보를 찾을 수 없습니다.')),
          );
        }
        final data = doc.data() as Map<String, dynamic>;

        // Village 모델 변환: fromDoc 사용하다가 실패 시 fallback
        late Village village;
        try {
          village = Village.fromDoc(doc);
        } catch (_) {
          // fallback: 최소한 widget.village 정보라도 사용
          village = widget.village;
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(village.name),
            leading: BackButton(),
            actions: [LikeButton(village: village)],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth >= 600;
              Widget imageSection = _buildImageSection(
                constraints.maxWidth,
                village,
              );
              Widget infoSection = _buildInfoSection(context, village);
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth * 0.4,
                      child: imageSection,
                    ),
                    SizedBox(
                      width: constraints.maxWidth * 0.6,
                      child: infoSection,
                    ),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  child: Column(children: [imageSection, infoSection]),
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildImageSection(double maxWidth, Village village) {
    final photos = village.photoUrls;
    if (photos == null || photos.isEmpty) {
      return Container(
        height: maxWidth * 0.6,
        color: Colors.grey.shade200,
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported,
          size: 48,
          color: Colors.grey,
        ),
      );
    }
    return SizedBox(
      height: maxWidth * 0.6,
      child: PageView.builder(
        itemCount: photos.length,
        itemBuilder: (context, index) {
          final url = photos[index];
          return Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stack) => Container(
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, Village village) {
    final List<Widget> items = [];

    // 1) rating, reviewCount 표시
    {
      final rating = village.rating; // getter: averageRatingStored ?? 0.0
      final reviewCount = village.reviewCount; // getter: reviewCountStored ?? 0
      final String displayCount =
          reviewCount >= 100 ? '99+' : reviewCount.toString();
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.orange),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '리뷰 $displayCount개',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // 2) 프로그램 목록
    if (village.programNames.isNotEmpty) {
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            '프로그램',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      );
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children:
                village.programNames
                    .map(
                      (p) => Chip(
                        label: Text(p, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.grey.shade100,
                      ),
                    )
                    .toList(),
          ),
        ),
      );
    }

    // 3) 최근 리뷰 섹션
    items.add(const SizedBox(height: 16));
    items.add(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '최근 리뷰',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => AllReviewsPage(villageName: widget.village.id),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(50, 30),
              ),
              child: const Text('전체 보기', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
    items.add(
      RecentReviewsSection(
        villageName: widget.village.id,
        onViewAll: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AllReviewsPage(villageName: widget.village.id),
            ),
          );
        },
      ),
    );

    // 4) 위치 정보
    if (village.latitude != null && village.longitude != null) {
      items.add(const SizedBox(height: 12));
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.redAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '위도: ${village.latitude!.toStringAsFixed(6)}, 경도: ${village.longitude!.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.map, color: Colors.blue),
                onPressed:
                    () => _launchMap(village.latitude!, village.longitude!),
                tooltip: '지도 열기',
              ),
            ],
          ),
        ),
      );
    }

    // 5) 기타 정보: 관리기관명, 전화번호, 주소, 홈페이지
    if (village.managerName != null && village.managerName!.isNotEmpty) {
      items.add(
        ListTile(
          leading: const Icon(Icons.business, color: Colors.grey),
          title: const Text('관리기관명'),
          subtitle: Text(village.managerName!),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      );
    }
    if (village.phone != null && village.phone!.isNotEmpty) {
      items.add(
        ListTile(
          leading: const Icon(Icons.phone, color: Colors.grey),
          title: const Text('대표전화번호'),
          subtitle: GestureDetector(
            onTap: () => _launchPhone(village.phone!),
            child: Text(
              village.phone!,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      );
    }
    if (village.address != null && village.address!.isNotEmpty) {
      items.add(
        ListTile(
          leading: const Icon(Icons.location_city, color: Colors.grey),
          title: const Text('주소'),
          subtitle: Text(village.address!),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      );
    }
    if (village.homepage != null && village.homepage!.isNotEmpty) {
      items.add(
        ListTile(
          leading: const Icon(Icons.link, color: Colors.grey),
          title: const Text('홈페이지'),
          subtitle: GestureDetector(
            onTap: () => _launchWebsite(village.homepage!),
            child: Text(
              village.homepage!,
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      );
    }

    if (items.isEmpty) {
      items.add(
        Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              '추가 정보가 없습니다.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
      );
    }
    items.add(const SizedBox(height: 24));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: items,
    );
  }
}
