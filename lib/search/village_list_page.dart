// lib/search/village_list_page.dart

import 'package:flutter/material.dart';
import 'package:youthbuk/search/services/village_repository.dart';
import 'package:youthbuk/search/models/village.dart';
import 'package:youthbuk/search/village_detail_page%20.dart';

/// Iterable<Widget> 전용 intersperse 확장
extension WidgetIntersperseExtension on Iterable<Widget> {
  Iterable<Widget> intersperse(Widget separator) sync* {
    bool first = true;
    for (var element in this) {
      if (!first) {
        yield separator;
      }
      yield element;
      first = false;
    }
  }
}

class VillageListPage extends StatelessWidget {
  final String regionName;
  final bool isOthers;

  const VillageListPage({
    super.key,
    required this.regionName,
    this.isOthers = false,
  });

  @override
  Widget build(BuildContext context) {
    final repo = VillageRepository();

    return Scaffold(
      appBar: AppBar(title: Text(isOthers ? '그 외 지역' : regionName)),
      body:
          isOthers
              ? FutureBuilder<Map<String, List<Village>>>(
                future: repo.fetchOthersGroupedByCity(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('불러오는 중 오류: ${snapshot.error}'));
                  }
                  final grouped = snapshot.data;
                  if (grouped == null || grouped.isEmpty) {
                    return const Center(child: Text('등록된 체험마을이 없습니다.'));
                  }
                  // 키 정렬: repository 내부에서 이미 정렬했다면 그대로 사용해도 되고,
                  // 여기서 재정렬하려면 아래처럼:
                  final keys = grouped.keys.toList()..sort();
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: keys.length,
                    itemBuilder: (context, idx) {
                      final city = keys[idx];
                      final listForCity = grouped[city]!;
                      return _CityGroupSection(
                        cityName: city,
                        villages: listForCity,
                      );
                    },
                  );
                },
              )
              : FutureBuilder<List<Village>>(
                future: repo.fetchByRegionName(regionName),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('불러오는 중 오류: ${snapshot.error}'));
                  }
                  final villages = snapshot.data;
                  if (villages == null || villages.isEmpty) {
                    return const Center(child: Text('등록된 체험마을이 없습니다.'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: villages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final v = villages[index];
                      return VillageListTile(village: v);
                    },
                  );
                },
              ),
    );
  }
}

class _CityGroupSection extends StatelessWidget {
  final String cityName;
  final List<Village> villages;

  const _CityGroupSection({
    super.key,
    required this.cityName,
    required this.villages,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 시군구명 헤더
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Text(
            cityName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // 각 마을 항목: Padding + intersperse로 간격
        ...villages
            .map<Widget>(
              (v) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: VillageListTile(village: v),
              ),
            )
            .intersperse(const SizedBox(height: 8)),
        const SizedBox(height: 16),
      ],
    );
  }
}

class VillageListTile extends StatelessWidget {
  final Village village;
  const VillageListTile({super.key, required this.village});

  @override
  Widget build(BuildContext context) {
    final avgText = village.averageRatingStored?.toStringAsFixed(1) ?? '0.0';
    final count = village.reviewCountStored ?? 0;
    final displayCount = count >= 100 ? '99+' : count.toString();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VillageDetailPage(village: village),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              if (village.photoUrls != null &&
                  village.photoUrls!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    village.photoUrls!.first,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (c, e, s) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      village.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      village.categoryRaw,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.orange),
                      const SizedBox(width: 2),
                      Text(avgText, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '($displayCount)',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
