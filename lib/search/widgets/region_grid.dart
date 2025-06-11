import 'package:flutter/material.dart';
import 'package:youthbuk/search/village_list_page.dart';

class RegionGrid extends StatelessWidget {
  const RegionGrid({super.key});

  final List<Map<String, dynamic>> fixedRegions = const [
    {'name': '청주시', 'icon': Icons.location_city, 'color': Color(0xFFE3F2FD)},
    {'name': '충주시', 'icon': Icons.park, 'color': Color(0xFFFFF9C4)},
    {'name': '제천시', 'icon': Icons.waves, 'color': Color(0xFFF8BBD0)},
    {'name': '보은군', 'icon': Icons.nature_people, 'color': Color(0xFFD1C4E9)},
    {'name': '옥천군', 'icon': Icons.forest, 'color': Color(0xFFC8E6C9)},
    {'name': '영동군', 'icon': Icons.wine_bar, 'color': Color(0xFFFFF3E0)},
    {'name': '진천군', 'icon': Icons.agriculture, 'color': Color(0xFFE1BEE7)},
    {'name': '괴산군', 'icon': Icons.terrain, 'color': Color(0xFFDCEDC8)},
    {'name': '음성군', 'icon': Icons.villa, 'color': Color(0xFFFFCDD2)},
    {'name': '단양군', 'icon': Icons.landscape, 'color': Color(0xFFB3E5FC)},
    {'name': '증평군', 'icon': Icons.home_work, 'color': Color(0xFFFFF9C4)},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: fixedRegions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final region = fixedRegions[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => VillageListPage(
                      regionName: region['name'],
                      isOthers: false,
                    ),
              ),
            );
          },
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: region['color'],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(region['icon'], size: 30, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                region['name'],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
