import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedPreference = '여행';
  double distance = 5;
  RangeValues dateRange = const RangeValues(1, 30);
  final List<String> preferences = ['여행', '캠핑', '등산', '체험'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('청년아, 충북으로 와!'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner with responsive aspect ratio
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  'assets/banner.jpg',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // AI 추천 필터
            const Text(
              'AI 맞춤 체험 추천',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children:
                  preferences.map((pref) {
                    final isSelected = pref == selectedPreference;
                    return ChoiceChip(
                      label: Text(pref),
                      selected: isSelected,
                      onSelected:
                          (_) => setState(() => selectedPreference = pref),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 16),

            // Distance Slider
            const Text('활동 거리 (km)'),
            Slider(
              min: 1,
              max: 50,
              divisions: 49,
              value: distance,
              label: '${distance.round()}km',
              onChanged: (v) => setState(() => distance = v),
            ),
            const SizedBox(height: 8),

            // Date Range Slider
            const Text('여행 기간 (일)'),
            RangeSlider(
              min: 1,
              max: 30,
              divisions: 29,
              values: dateRange,
              labels: RangeLabels(
                '${dateRange.start.round()}일',
                '${dateRange.end.round()}일',
              ),
              onChanged: (r) => setState(() => dateRange = r),
            ),
            const SizedBox(height: 16),

            // Search Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('나에게 맞는 체험 찾기'),
              ),
            ),
            const SizedBox(height: 24),

            // Popular Programs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '인기 체험 프로그램',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('전체 보기', style: TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3 / 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 4,
              itemBuilder:
                  (context, i) => _ProgramCard(
                    title: '프로그램 ${i + 1}',
                    location: '보은군',
                    price: '${(i + 1) * 2}만원',
                  ),
            ),
            const SizedBox(height: 24),

            // Support Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '정착 지원 정보',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('더보기', style: TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 12),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              children: const [
                _SupportCard(
                  icon: Icons.home,
                  title: '공공 빈집',
                  subtitle: '리모델링 지원 주택 정보',
                ),
                _SupportCard(
                  icon: Icons.work,
                  title: '지역 일자리',
                  subtitle: '취업 및 창업 정보',
                ),
                _SupportCard(
                  icon: Icons.info,
                  title: '지원금 안내',
                  subtitle: '청년 정착 지원 혜택',
                ),
                _SupportCard(
                  icon: Icons.calculate,
                  title: '생활비 계산기',
                  subtitle: '지역별 생활 비용 비교',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Reviews & Community
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '체험 후기 & 커뮤니티',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('글쓰기', style: TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 12),
            const _ReviewTile(
              name: '김지연',
              time: '한 달 전',
              rating: 5,
              title: '괴산에서 찾은 새로운 시작',
              content:
                  '한 달 살이로 시작했는데 이제는 정착을 준비하고 있어요. 지역 주민들의 따뜻한 환대와 아름다운 자연환경에 반해 귀농을 결심했습니다.',
              tags: ['#괴산', '#한 달 살이', '#귀농'],
            ),
            const Divider(),
            const _ReviewTile(
              name: '박민수',
              time: '2주 전',
              rating: 5,
              title: '충주에서의 창업 멘토링, 대만족!',
              content:
                  '일주일 창업 체험 프로그램에 참여했는데, 로컬 비즈니스에 대한 인사이트를 많이 얻었습니다. 멘토링이 특히 도움이 되었어요.',
              tags: ['#충주', '#창업', '#멘토링'],
            ),
          ],
        ),
      ),

      // Removed nested bottomNavigationBar; navigation handled by RootPage
    );
  }
}

// Program Card
class _ProgramCard extends StatelessWidget {
  final String title, location, price;
  const _ProgramCard({
    super.key,
    required this.title,
    required this.location,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                'assets/program.jpg',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const SizedBox.shrink(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(location),
                const SizedBox(height: 4),
                Text(price, style: const TextStyle(color: Colors.blue)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Support Card
class _SupportCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _SupportCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Review Tile
class _ReviewTile extends StatelessWidget {
  final String name, time, title, content;
  final int rating;
  final List<String> tags;
  const _ReviewTile({
    super.key,
    required this.name,
    required this.time,
    required this.title,
    required this.content,
    required this.rating,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Text(name[0])),
      title: Row(
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(
              rating,
              (_) => const Icon(Icons.star, size: 16, color: Colors.amber),
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(content, maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            children:
                tags
                    .map(
                      (t) => Chip(
                        label: Text(t, style: const TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}
