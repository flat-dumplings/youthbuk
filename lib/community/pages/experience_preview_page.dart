import 'package:flutter/material.dart';
import 'experience_cards.dart';

class ExperiencePreviewPage extends StatelessWidget {
  final Map<String, dynamic> aiData; // Map<String, dynamic> 으로 변경
  final String mainImageUrl;
  final List<String> galleryImageUrls;

  const ExperiencePreviewPage({
    super.key,
    required this.aiData,
    required this.mainImageUrl,
    required this.galleryImageUrls,
  });

  @override
  Widget build(BuildContext context) {
    final enrichedAiData = Map<String, dynamic>.from(aiData);

    if (mainImageUrl.isNotEmpty) {
      enrichedAiData['poster_url'] = mainImageUrl;
    }

    // gallery 이미지 URL 목록을 aiData에 포함시키기
    enrichedAiData['image_urls'] = galleryImageUrls;

    return Scaffold(
      appBar: AppBar(title: const Text('AI 상세페이지 미리보기')),
      body: PageView(
        children: [
          Center(
            child: FittedBox(
              child: ExperiencePosterCard(aiData: enrichedAiData),
            ),
          ),
          Center(
            child: FittedBox(child: RecruitInfoCard(aiData: enrichedAiData)),
          ),
          Center(
            child: FittedBox(
              child: ExperienceGalleryCard(aiData: enrichedAiData),
            ),
          ),
        ],
      ),
    );
  }
}
