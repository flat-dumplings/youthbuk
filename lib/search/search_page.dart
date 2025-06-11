// lib/search/search_page.dart
import 'package:flutter/material.dart';
import 'package:youthbuk/search/models/region.dart';
import 'package:youthbuk/search/services/region_repository.dart';
import 'package:youthbuk/search/village_detail_page%20.dart';
import 'package:youthbuk/search/widgets/region_card.dart';
import 'package:youthbuk/search/services/village_repository.dart';
import 'package:youthbuk/search/models/village.dart';

// 아래 import 경로는 실제 프로젝트 경로에 맞춰 조정하세요.
import 'package:youthbuk/search/village_list_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isListView = true;
  final List<String> tabs = ['전체', '한 달 살이', '일주일 체험', '농활'];
  int selectedTabIndex = 0;

  late Future<List<RegionCount>> regionCountsFuture;
  final RegionRepository repo = RegionRepository();

  // VillageRepository 인스턴스
  final VillageRepository villageRepo = VillageRepository();

  @override
  void initState() {
    super.initState();
    regionCountsFuture = repo.fetchRegionCounts();
  }

  @override
  Widget build(BuildContext context) {
    const regionAspect = 3 / 2.5;
    return Scaffold(
      appBar: AppBar(
        title: const Text('탐색'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // 검색 아이콘 동작: 필요 시 구현
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // 필터 아이콘 동작: 필요 시 구현
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 검색 필드
            TextField(
              decoration: InputDecoration(
                hintText: '지역, 프로그램명을 검색하세요',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (text) {
                // 검색어 입력 후 동작: 필요 시 구현
              },
            ),
            const SizedBox(height: 12),

            // 탭 선택 (필터 로직은 필요시 추가 가능)
            Row(
              children: [
                for (var i = 0; i < tabs.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(tabs[i]),
                      selected: i == selectedTabIndex,
                      onSelected:
                          (_) => setState(() {
                            selectedTabIndex = i;
                            // 탭별 필터 로직이 필요하다면 이곳에서 상태를 변경하고,
                            // regionCountsFuture나 추천 프로그램 Future 등을 다시 할당해 반영하세요.
                          }),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // 뷰 토글 (리스트/지도 등)
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(isListView ? Icons.list : Icons.map),
                onPressed: () => setState(() => isListView = !isListView),
              ),
            ),
            const SizedBox(height: 8),

            // 지역 그리드: RegionCount 기반
            FutureBuilder<List<RegionCount>>(
              future: regionCountsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      '지역 정보를 불러오는 중 오류: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('등록된 지역 정보가 없습니다.'),
                  );
                } else {
                  final regionCounts = snapshot.data!;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = 12.0;
                      const itemsPerRow = 3;
                      final totalSpacing = spacing * (itemsPerRow - 1);
                      final itemWidth =
                          (constraints.maxWidth - totalSpacing) / itemsPerRow;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children:
                            regionCounts.map((rc) {
                              return SizedBox(
                                width: itemWidth,
                                child: AspectRatio(
                                  aspectRatio: regionAspect,
                                  child: RegionCard(
                                    name: rc.name,
                                    count: rc.count,
                                    onTap: () {
                                      final isOthers = rc.name == '그 외';
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => VillageListPage(
                                                regionName: rc.name,
                                                isOthers: isOthers,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }).toList(),
                      );
                    },
                  );
                }
              },
            ),

            // ====== 추천 프로그램 영역 ======
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '추천 프로그램',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                // Text('정렬 ▶', style: TextStyle(color: Colors.blue)), // 필요시 정렬 UI 추가
              ],
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Village>>(
              future: villageRepo.fetchTopVillagesByRating(limit: 5),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      '추천 프로그램을 불러오는 중 오류: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                final topVillages = snapshot.data;
                if (topVillages == null || topVillages.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('추천할 프로그램이 없습니다.'),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: topVillages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final v = topVillages[index];
                    return GestureDetector(
                      onTap: () {
                        // 추천 프로그램 클릭 시 상세 페이지로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VillageDetailPage(village: v),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              // (선택) 이미지가 있다면 왼쪽에 추가
                              if (v.photoUrls != null &&
                                  v.photoUrls!.isNotEmpty) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.network(
                                    v.photoUrls!.first,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stack) => Container(
                                          width: 60,
                                          height: 60,
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

                              // 왼쪽: 이름 및 카테고리
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      v.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      v.categoryRaw,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 우측: 평점 및 리뷰 개수
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Colors.orange,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        v.averageRatingStored != null
                                            ? v.averageRatingStored!
                                                .toStringAsFixed(1)
                                            : '0.0',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '(${v.reviewCountStored ?? 0})',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // ========================================
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // “더 많은 프로그램 보기” 동작: 예를 들어 평점순 전체 페이지로 이동 등
                  // Navigator.push(...);
                },
                child: const Text('더 많은 프로그램 보기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
