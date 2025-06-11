// reservation_page.dart
import 'package:flutter/material.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  int selectedTab = 0; // 0: 진행중, 1: 완료된, 2: 취소된

  @override
  Widget build(BuildContext context) {
    // 화면 너비에 따라 카드 너비를 잡기 위한 MediaQuery
    final width = MediaQuery.of(context).size.width;
    // 카드 가로 16:9 비율
    final cardAspectRatio = 16 / 9;

    return Scaffold(
      appBar: AppBar(
        title: const Text('예약 관리'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTab('진행중 예약', 0),
                _buildTab('완료된 예약', 1),
                _buildTab('취소된 예약', 2),
              ],
            ),
            const SizedBox(height: 16),

            // AI 추천 카드 (반응형 가로폭)
            SizedBox(
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: cardAspectRatio,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  color: Colors.blue.shade600,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '새로운 체험 예약하기',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'AI 추천으로 나에게 딱 맞는 프로그램을 찾아봐요',
                          style: TextStyle(color: Colors.white70),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: width * 0.5, // 화면 폭의 절반으로 버튼 넓이 조정
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              '새 프로그램 둘러보기',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 진행중 예약 리스트
            if (selectedTab == 0) ...[
              _buildOngoingReservation(
                width,
                cardAspectRatio,
                title: '괴산 메밀 가공 농촌살이',
                period: '2024.06.15 - 2024.07.15',
                price: '600,000원',
                status: '진행중',
                progress: 0.4,
              ),
              const SizedBox(height: 16),
              _buildOngoingReservation(
                width,
                cardAspectRatio,
                title: '보은 농촌 매칭',
                period: '2024.06.29 - 2024.07.02',
                price: '50,000원',
                status: '예약완료',
                progress: 1.0,
              ),
            ],

            const SizedBox(height: 24),
            // 다가오는 일정
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  '다가오는 일정',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('전체보기', style: TextStyle(color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 12),
            _buildUpcomingItem('체험 알림', '괴산 메밀 가공 농촌살이', '내일 14:00'),
            const SizedBox(height: 24),

            // 나의 체험 통계
            const Text(
              '나의 체험 통계',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _StatisticItem(count: 3, label: '총 체험 수'),
                _StatisticItem(count: 28, label: '체험 인원'),
                _StatisticItem(count: 4.8, label: '평균 평점'),
              ],
            ),
            const SizedBox(height: 24),

            // 긴급 연락처
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('긴급 연락처', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('체험 중 응급상황 시 연락하세요'),
                  SizedBox(height: 12),
                  Text(
                    '☎ 043-123-4567',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // 하단 내비게이션은 RootPage에서만 정의합니다.
    );
  }

  Widget _buildTab(String label, int index) {
    final selected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: selected ? Colors.blue : Colors.black),
          ),
          if (selected) const SizedBox(height: 4),
          if (selected) Container(width: 40, height: 3, color: Colors.blue),
        ],
      ),
    );
  }

  Widget _buildOngoingReservation(
    double width,
    double aspectRatio, {
    required String title,
    required String period,
    required String price,
    required String status,
    required double progress,
  }) {
    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(period, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text('참가비: $price'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      status,
                      style: TextStyle(
                        color: status == '진행중' ? Colors.green : Colors.blue,
                      ),
                    ),
                    Text('${(progress * 100).round()}%'),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: progress),
                const Spacer(),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('위치 보기'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: () {}, child: const Text('연락하기')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingItem(String badge, String title, String time) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        badge == '체험 알림' ? Icons.notifications_active : Icons.event,
      ),
      title: Text(title),
      subtitle: Text(time),
      horizontalTitleGap: 0,
    );
  }
}

class _StatisticItem extends StatelessWidget {
  final dynamic count;
  final String label;
  const _StatisticItem({super.key, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
