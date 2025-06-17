import 'package:flutter/material.dart';
import 'dart:async';

import 'package:youthbuk/home/widgets/Image_category.dart';
import 'package:youthbuk/home/widgets/banner_widget.dart';
import 'package:youthbuk/home/widgets/deadline_section.dart';
import 'package:youthbuk/home/widgets/section_divider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _banners = [
    {
      'title': '장박 용품 최저가 보장!',
      'subtitle': '11/14까지 80% 할인!',
      'image': 'assets/images/login_logo.png',
    },
    {
      'title': '따뜻한 캠핑을 위한 히터 특가',
      'subtitle': '지금 바로 확인해보세요!',
      'image': 'assets/images/login_logo.png',
    },
    {
      'title': '겨울 침낭 할인 이벤트',
      'subtitle': '최대 70% 세일',
      'image': 'assets/images/login_logo.png',
    },
    {
      'title': '차박 필수템 모음전',
      'subtitle': '이불부터 버너까지 한 번에!',
      'image': 'assets/images/login_logo.png',
    },
    {
      'title': '텐트 세트 구성 할인',
      'subtitle': '캠핑 초보도 완벽 준비!',
      'image': 'assets/images/login_logo.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % _banners.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset('assets/images/logo_3d.png', width: 30, height: 30),
                const SizedBox(width: 6),
                const Text(
                  '청춘북',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.search, size: 18),
              label: const Text('예약조회', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // 캐릭터 이미지
          Positioned(
            top: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/main_half.png',
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 검색창
          Positioned(
            top: 180,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: '원하는 상품이나 체험을 검색하세요',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // 전체 콘텐츠
          Positioned.fill(
            top: 240,
            child: ListView(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              children: [
                // Carousel Banner
                SizedBox(
                  height: 140,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _banners.length,
                    itemBuilder: (context, index) {
                      final banner = _banners[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F5F1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    banner['title']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    banner['subtitle']!,
                                    style: const TextStyle(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                banner['image']!,
                                width: 80,
                                height: 80,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    onPageChanged:
                        (index) => setState(() => _currentPage = index),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_banners.length, (index) {
                    return Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            _currentPage == index ? Colors.black : Colors.grey,
                      ),
                    );
                  }),
                ),
                //const SizedBox(height: 20),

                // Category Icons
                GridView.count(
                  padding: const EdgeInsets.only(top: 20),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 5,
                  childAspectRatio: 0.7,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  children: const [
                    ImageCategory(
                      imagePath: 'assets/icons/3d/all.png',
                      label: '전체',
                    ),
                    ImageCategory(
                      imagePath: 'assets/icons/3d/rural_activities.png',
                      label: '농촌활동',
                    ),
                    ImageCategory(
                      imagePath: 'assets/icons/3d/experience.png',
                      label: '체험',
                    ),
                    ImageCategory(
                      imagePath: 'assets/icons/3d/sightseeing.png',
                      label: '관광',
                    ),
                    ImageCategory(
                      imagePath: 'assets/icons/3d/health.png',
                      label: '건강',
                    ),
                    ImageCategory(
                      imagePath: 'assets/icons/3d/craft.png',
                      label: '공예',
                    ),
                    ImageCategory(
                      imagePath: 'assets/icons/3d/cooking.png',
                      label: '요리',
                    ),
                    ImageCategory(
                      imagePath: 'assets/icons/3d/insect_observation.png',
                      label: '곤충 관찰',
                    ),
                    ImageCategory(
                      imagePath: 'assets/icons/3d/fishhook.png',
                      label: '낚시',
                    ),
                    ImageCategory(
                      imagePath: 'assets/icons/3d/food.png',
                      label: '먹거리',
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                //const SectionDivider(),
                BannerWidget(
                  title: '헬퍼 청년',
                  subtitle: '마을 일손 도와주고, 무료 숙식 지원받기!',
                  buttonText: '신청하기',
                  onPressed: () {
                    // 버튼 클릭 시 동작
                  },
                  imagePath: 'assets/images/login_logo.png', // 이미지 경로
                ),
                // 마감 임박 상품
                const SizedBox(height: 28),
                const DeadlineSection(),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
