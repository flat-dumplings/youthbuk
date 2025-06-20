import 'package:flutter/material.dart';
import 'poster_create_page.dart';
import 'character_create_page.dart';

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  void _onCreatePressed(String type) {
    debugPrint('Pressed: $type');
    if (type == 'AI 홍보 포스터 제작') {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const PosterCreatePage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else if (type == '마을만의 캐릭터 제작') {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const CharacterCreatePage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    } else {
      debugPrint('Unknown button pressed: $type');
    }
  }

  Widget _buildCard({
    required String imagePath,
    required String title,
    required String costText,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 150,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Text(
                    '이미지를 불러올 수 없습니다.',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  costText,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => _onCreatePressed(title),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('만들기'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('체험')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCard(
              imagePath: 'assets/images/ai_poster.png',
              title: 'AI 홍보 포스터 제작',
              costText: '비용 : 1회 1000원',
            ),
            _buildCard(
              imagePath: 'assets/images/character_poster.png',
              title: '마을만의 캐릭터 제작',
              costText: '비용 : 1회 1000원',
            ),
          ],
        ),
      ),
    );
  }
}
