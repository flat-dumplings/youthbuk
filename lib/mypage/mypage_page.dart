// lib/mypage/my_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('마이페이지'), centerTitle: true),
        body: const Center(child: Text('로그인이 필요합니다.')),
      );
    }
    final uid = user.uid;
    final userDocStream =
        FirebaseFirestore.instance.collection('users').doc(uid).snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: userDocStream,
      builder: (context, snapUser) {
        if (snapUser.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('마이페이지'), centerTitle: true),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapUser.hasData ||
            snapUser.data == null ||
            !snapUser.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text('마이페이지'), centerTitle: true),
            body: const Center(child: Text('유저 정보를 불러올 수 없습니다.')),
          );
        }

        final data = snapUser.data!.data()!;
        // 기본 필드
        final nickname = data['nickname'] as String? ?? '닉네임 없음';
        final points = data['point'] as int? ?? 0;
        final photoUrl = data['photoUrl'] as String?;

        // complete: List 형태
        final completeList = data['complete'] as List<dynamic>? ?? [];
        final completeCount = completeList.length;

        // inProgress: List 형태
        final inProgressList = data['inProgress'] as List<dynamic>? ?? [];
        // 예: 첫 번째 요소만 현재 체험으로 표시
        String? currentTitle;
        String? currentPeriod;
        if (inProgressList.isNotEmpty) {
          final first = inProgressList.first;
          if (first is Map<String, dynamic>) {
            // Map에 'title'/'period' 필드가 있다고 가정
            currentTitle = first['title'] as String? ?? '정보 없음';
            currentPeriod = first['period'] as String? ?? '기간 정보 없음';
          } else if (first is String) {
            // 만약 ID 문자열이라면, 별도 문서에서 조회 필요
            // 예시: Firestore에서 해당 ID 문서 fetch 로직을 추가해야 함
            // 이 경우 FutureBuilder 혹은 StreamBuilder를 중첩 사용.
          } else if (first is DocumentReference) {
            // DocumentReference 형태라면:
            // currentTitle/currentPeriod을 얻기 위해 하위 StreamBuilder를 사용
          }
        }

        // reviews 서브컬렉션 개수
        final reviewsStream =
            FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection('reviews')
                .snapshots();

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: reviewsStream,
          builder: (context, snapReviews) {
            int reviewCount = 0;
            if (snapReviews.hasData) {
              reviewCount = snapReviews.data!.docs.length;
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('마이페이지'),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      // 설정 페이지 이동 등
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundImage:
                              photoUrl != null
                                  ? NetworkImage(photoUrl) as ImageProvider
                                  : const AssetImage('assets/avatar.jpg'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nickname,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                data['address'] as String? ?? '',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '리뷰 $reviewCount',
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            // 프로필 편집 페이지로 이동
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(count: completeCount, label: '현장 경험'),
                        _StatItem(count: reviewCount, label: '체험 후기'),
                        _StatItem(count: points, label: '포인트'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Current Reservation (현재 체험)
                    const Text(
                      '현재 체험',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (currentTitle != null && currentPeriod != null)
                      AspectRatio(
                        aspectRatio: 16 / 5,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '진행 중',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentPeriod,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                const Spacer(),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // 상세보기 로직
                                    },
                                    child: const Text('상세보기'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        child: const Text('진행 중인 체험이 없습니다.'),
                      ),
                    const SizedBox(height: 24),

                    // Quick Menu
                    const Text(
                      '빠른 메뉴',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _QuickMenu(
                          icon: Icons.bookmark,
                          label: '예약 관리',
                          onTap: () {},
                        ),
                        _QuickMenu(
                          icon: Icons.favorite,
                          label: '찜한 체험',
                          onTap: () {},
                        ),
                        _QuickMenu(
                          icon: Icons.history,
                          label: '포인트 내역',
                          onTap: () {},
                        ),
                        _QuickMenu(
                          icon: Icons.person,
                          label: '멘토링',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // History (체험 이력) - 예: completeList 같은 별도 List 필드가 있다면 매핑
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          '체험 이력',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('전체보기', style: TextStyle(color: Colors.blue)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (data['completeList'] is List)
                      Column(
                        children: List<Widget>.from(
                          (data['completeList'] as List).map((item) {
                            final map = item as Map<String, dynamic>;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _HistoryItem(
                                title: map['title'] as String? ?? '제목 없음',
                                period: map['period'] as String? ?? '기간 없음',
                                rating: map['rating'] as int? ?? 0,
                              ),
                            );
                          }),
                        ),
                      )
                    else
                      const Text('이력 정보가 없습니다.'),
                    const SizedBox(height: 24),

                    // Settings
                    const Text(
                      '설정',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SettingItem(
                      icon: Icons.notifications,
                      label: '알림 설정',
                      onTap: () {},
                    ),
                    _SettingItem(
                      icon: Icons.lock,
                      label: '개인정보 설정',
                      onTap: () {},
                    ),
                    _SettingItem(
                      icon: Icons.support_agent,
                      label: '고객센터',
                      onTap: () {},
                    ),
                    _SettingItem(
                      icon: Icons.logout,
                      label: '로그아웃',
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushReplacementNamed('/login');
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final dynamic count;
  final String label;
  const _StatItem({super.key, required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }
}

class _QuickMenu extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _QuickMenu({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String title, period;
  final int rating;
  const _HistoryItem({
    super.key,
    required this.title,
    required this.period,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(period, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            Row(
              children: List.generate(
                rating,
                (_) => const Icon(Icons.star, size: 16, color: Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _SettingItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.grey.shade700),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap ?? () {},
    );
  }
}
