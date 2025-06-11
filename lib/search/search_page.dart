import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:youthbuk/search/models/village.dart';
import 'package:youthbuk/search/village_detail_page%20.dart';
import 'package:youthbuk/search/village_list_page.dart';
import 'package:youthbuk/search/widgets/region_grid.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  int selectedTabIndex = 0;
  bool filterExpanded = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('탐색'),
          centerTitle: true,
          bottom: const TabBar(
            indicatorColor: Colors.black,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [Tab(text: '지역별 보기'), Tab(text: '조건별 보기')],
          ),
        ),
        body: TabBarView(children: [RegionGrid(), _buildFilterTab()]),
      ),
    );
  }

  Widget _buildFilterTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildFilterChips(),
        const SizedBox(height: 24),
        const Text(
          '추천 프로그램',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildRecommendedPrograms(),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('더 많은 프로그램 보기'),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final List<Map<String, String>> tabsWithEmoji = [
      {'emoji': '📋', 'label': '전체'},
      {'emoji': '🌾', 'label': '농활'},
      {'emoji': '🧪', 'label': '체험'},
      {'emoji': '🗺️', 'label': '관광'},
      {'emoji': '💪', 'label': '건강'},
      {'emoji': '🎨', 'label': '공예'},
      {'emoji': '🍳', 'label': '요리'},
      {'emoji': '🐞', 'label': '곤충 관찰'},
      {'emoji': '🎣', 'label': '낚시'},
      {'emoji': '🍱', 'label': '먹거리'},
    ];

    final visibleCount = filterExpanded ? tabsWithEmoji.length : 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(visibleCount, (i) {
              final isSelected = selectedTabIndex == i;
              return InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  setState(() {
                    selectedTabIndex = i;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tabsWithEmoji[i]['emoji']!,
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        tabsWithEmoji[i]['label']!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                filterExpanded = !filterExpanded;
              });
            },
            icon: Icon(
              filterExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
            ),
            label: Text(filterExpanded ? '접기' : '전체 보기'),
            style: TextButton.styleFrom(foregroundColor: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedPrograms() {
    return StreamBuilder<QuerySnapshot>(
      stream:
          _firestore
              .collection('Villages')
              .orderBy('rating', descending: true)
              .limit(5)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text(
            '추천 프로그램 오류: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Text('추천할 프로그램이 없습니다.');
        }
        final villages = docs.map((d) => Village.fromDoc(d)).toList();
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: villages.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final v = villages[i];
            final countStr =
                v.reviewCount >= 100 ? '99+' : v.reviewCount.toString();
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VillageDetailPage(village: v),
                    ),
                  ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child:
                    v.photoUrls != null && v.photoUrls!.isNotEmpty
                        ? Image.network(
                          v.photoUrls!.first,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                        : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image),
                        ),
              ),
              title: Text(
                v.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(v.categoryRaw),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(v.rating.toStringAsFixed(1)),
                    ],
                  ),
                  Text(
                    '($countStr)',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
