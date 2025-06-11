// community_page.dart
import 'package:flutter/material.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final List<String> tabs = ['전체', '새등록순', '정착일기', '질문답변'];
  int selectedTabIndex = 0;

  final List<_Post> popularPosts = [
    _Post(
      author: '이서연',
      time: '3시간 전',
      title: '괴산 한 달 살이 전과 후기 (장단점 솔직하게)',
      tags: ['#괴산', '#한달살이'],
      views: 156,
      comments: 24,
      likes: 10,
      isHot: true,
    ),
    _Post(
      author: '박준석',
      time: '5시간 전',
      title: '충주에 커피 찻집하면 좋을까? (매장 공유)',
      tags: ['#충주', '#카페창업'],
      views: 98,
      comments: 12,
      likes: 6,
      isHot: true,
    ),
  ];

  final List<_Post> recentPosts = [
    _Post(
      author: '김민지',
      time: '1시간 전',
      title: '보은 농촌 살이 후기 🌾',
      tags: ['#보은', '#농촌살이'],
      views: 45,
      comments: 2,
      likes: 5,
    ),
    _Post(
      author: '정유성',
      time: '1시간 전',
      title: '충북 정착 3년차가 답하는 Q&A',
      tags: ['#충북', '#정착'],
      views: 30,
      comments: 8,
      likes: 3,
    ),
    _Post(
      author: '홍길동',
      time: '2시간 전',
      title: '음성 빈집 리모델링 경험 공유',
      tags: ['#음성', '#빈집지원'],
      views: 20,
      comments: 4,
      likes: 2,
    ),
    _Post(
      author: '이탁민',
      time: '3시간 전',
      title: '[질문] 제천 겨울 생활 어떨까요?',
      tags: ['#제천', '#겨울살이'],
      views: 12,
      comments: 6,
      likes: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // 화면 너비 기준으로 콘텐츠 패딩
    final padding = 16.0;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('커뮤니티'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs
            Wrap(
              spacing: 8,
              children: List.generate(tabs.length, (i) {
                final selected = i == selectedTabIndex;
                return ChoiceChip(
                  label: Text(tabs[i]),
                  selected: selected,
                  onSelected: (_) => setState(() => selectedTabIndex = i),
                );
              }),
            ),
            const SizedBox(height: 24),

            // 인기 게시글
            const Text(
              '인기 게시글',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...popularPosts.map(
              (post) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PostTile(post: post),
              ),
            ),

            const SizedBox(height: 24),
            // 최신 게시글
            const Text(
              '최신 게시글',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...recentPosts.map(
              (post) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PostTile(post: post),
              ),
            ),
          ],
        ),
      ),
      // 내비게이션 바는 RootPage에서만 정의합니다.
    );
  }
}

class _Post {
  final String author;
  final String time;
  final String title;
  final List<String> tags;
  final int views;
  final int comments;
  final int likes;
  final bool isHot;
  const _Post({
    required this.author,
    required this.time,
    required this.title,
    required this.tags,
    required this.views,
    required this.comments,
    required this.likes,
    this.isHot = false,
  });
}

class _PostTile extends StatelessWidget {
  final _Post post;
  const _PostTile({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // 반응형 높이: 제목 + 메트릭 + 태그 공간 확보
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 작성자, 시간, HOT
            Row(
              children: [
                CircleAvatar(child: Text(post.author[0])),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${post.author} • ${post.time}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
                if (post.isHot)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'HOT',
                      style: TextStyle(fontSize: 10, color: Colors.red),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // 제목
            Text(
              post.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // 태그
            Wrap(
              spacing: 6,
              children:
                  post.tags
                      .map(
                        (t) => Chip(
                          label: Text(t, style: const TextStyle(fontSize: 12)),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 8),
            // 메트릭
            Row(
              children: [
                const Icon(Icons.remove_red_eye, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  post.views.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.comment, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  post.comments.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.thumb_up, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  post.likes.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
