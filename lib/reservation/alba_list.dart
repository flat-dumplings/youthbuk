import 'package:flutter/material.dart';

class AlbaList extends StatelessWidget {
  final List<Map<String, dynamic>> albas;
  final ScrollController? scrollController;

  const AlbaList({required this.albas, this.scrollController, super.key});

  @override
  Widget build(BuildContext context) {
    if (albas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: albas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final alba = albas[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.work_outline,
                    size: 50,
                    color: Colors.pinkAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alba['title'] ?? '알바명 없음',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (alba['company'] != null &&
                          alba['company'].toString().isNotEmpty)
                        Text(
                          alba['company'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      if (alba['salary'] != null &&
                          alba['salary'].toString().isNotEmpty)
                        Text(
                          '급여: ${alba['salary']}',
                          style: const TextStyle(
                            color: Colors.pinkAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (alba['workTime'] != null &&
                          alba['workTime'].toString().isNotEmpty)
                        Text(
                          '근무시간: ${alba['workTime']}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
