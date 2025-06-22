import 'package:flutter/material.dart';

// 배경 꾸미기 헬퍼 클래스
class BackgroundDecorator {
  static BoxDecoration buildBackgroundDecoration({
    Map<String, dynamic>? backgroundStyle,
    String? backgroundImageUrl,
  }) {
    if (backgroundImageUrl != null && backgroundImageUrl.isNotEmpty) {
      return BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(backgroundImageUrl),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(
          (backgroundStyle?['borderRadius'] ?? 24).toDouble(),
        ),
        border: Border.all(
          color:
              backgroundStyle != null &&
                      backgroundStyle.containsKey('borderColor')
                  ? _parseHexColor(backgroundStyle['borderColor'])
                  : Colors.grey.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              (backgroundStyle?['shadowOpacity'] ?? 0.1).toDouble(),
            ),
            blurRadius: 16,
            offset: const Offset(4, 8),
          ),
        ],
      );
    }

    if (backgroundStyle == null) {
      return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(4, 8),
          ),
        ],
      );
    }

    try {
      final type = backgroundStyle['type'] ?? 'color';

      BorderRadius radius = BorderRadius.circular(
        (backgroundStyle['borderRadius'] ?? 24).toDouble(),
      );

      Color borderColor =
          backgroundStyle.containsKey('borderColor')
              ? _parseHexColor(backgroundStyle['borderColor'])
              : Colors.grey.shade300;

      double shadowOpacity =
          (backgroundStyle['shadowOpacity'] ?? 0.1).toDouble();

      List<Color> colors = [];
      if (type == 'gradient') {
        List<dynamic> colStrs =
            backgroundStyle['colors'] ?? ['#FFFFFF', '#FFFFFF'];
        colors = colStrs.map((c) => _parseHexColor(c.toString())).toList();
      } else if (type == 'color') {
        colors = [_parseHexColor(backgroundStyle['color'] ?? '#FFFFFF')];
      } else {
        colors = [Colors.white];
      }

      Alignment begin = Alignment.topLeft;
      Alignment end = Alignment.bottomRight;

      if (backgroundStyle.containsKey('begin')) {
        begin = _parseAlignment(backgroundStyle['begin']);
      }
      if (backgroundStyle.containsKey('end')) {
        end = _parseAlignment(backgroundStyle['end']);
      }

      return BoxDecoration(
        gradient:
            (type == 'gradient')
                ? LinearGradient(colors: colors, begin: begin, end: end)
                : null,
        color: (type == 'color') ? colors.first : null,
        borderRadius: radius,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(shadowOpacity),
            blurRadius: 16,
            offset: const Offset(4, 8),
          ),
        ],
      );
    } catch (e) {
      return BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(4, 8),
          ),
        ],
      );
    }
  }

  static Color _parseHexColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  static Alignment _parseAlignment(String input) {
    switch (input.toLowerCase()) {
      case 'topleft':
      case 'top_left':
        return Alignment.topLeft;
      case 'topright':
      case 'top_right':
        return Alignment.topRight;
      case 'bottomleft':
      case 'bottom_left':
        return Alignment.bottomLeft;
      case 'bottomright':
      case 'bottom_right':
        return Alignment.bottomRight;
      case 'center':
        return Alignment.center;
      default:
        return Alignment.topLeft;
    }
  }
}

// 1. 참가자 모집 카드 (마을명 village_name 필드 추가, 홍보 문구 promo_message 추가, 가능 요일 possible_days 추가)
class RecruitInfoCard extends StatelessWidget {
  final Map<String, dynamic> aiData;

  const RecruitInfoCard({super.key, required this.aiData});

  // 비용에 원 붙이기
  String _formatPrice(String price) {
    if (price.isEmpty) return '';
    return price.trim().endsWith('원') ? price.trim() : '${price.trim()}원';
  }

  // 모집 인원에 명 붙이기
  String _formatParticipants(String participants) {
    if (participants.isEmpty) return '';
    return participants.trim().endsWith('명')
        ? participants.trim()
        : '${participants.trim()}명';
  }

  @override
  Widget build(BuildContext context) {
    final villageName = aiData['village_name'] ?? '';
    final promoMessage = aiData['promo_message'] ?? '';
    final possibleDays = aiData['possible_days'] ?? '';
    final backgroundStyle = aiData['background_style'] as Map<String, dynamic>?;
    final backgroundImageUrl = aiData['background_image_url']?.toString();

    final boxDecoration = BackgroundDecorator.buildBackgroundDecoration(
      backgroundStyle: backgroundStyle,
      backgroundImageUrl: backgroundImageUrl,
    );

    return Container(
      width: 1080,
      height: 1080,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: boxDecoration,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '참가자 모집',
                style: TextStyle(
                  fontSize: 75,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF231815),
                  shadows: [
                    Shadow(
                      color: Colors.grey.shade300,
                      blurRadius: 2,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 70),
            _infoRow(
              '모집 인원:',
              _formatParticipants(aiData['info_participants'] ?? ''),
            ),
            _infoRow('비용:', _formatPrice(aiData['info_price'] ?? '')),
            _infoRow('기간:', aiData['info_time'] ?? ''),
            if ((possibleDays ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '가능 요일: $possibleDays',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepOrange.shade700,
                ),
              ),
            ],
            if (villageName.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                villageName,
                style: TextStyle(
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
            if (promoMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                promoMessage,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepOrange.shade700,
                ),
              ),
            ],
            const SizedBox(height: 50),
            Text(
              '환불 지침',
              style: _labelStyle().copyWith(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              (aiData['refund_policy']?.isEmpty ?? true)
                  ? '체험 시작 3일 전까지 전액 환불 가능하며, 이후 환불은 불가합니다.'
                  : (aiData['refund_policy'] ?? ''),
              style: _valueStyle(fontSize: 28),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Text(label, style: _labelStyle()),
          const SizedBox(width: 20),
          Expanded(child: Text(value, style: _valueStyle(fontSize: 30))),
        ],
      ),
    );
  }

  TextStyle _labelStyle() => const TextStyle(
    color: Color(0xFFD23D20),
    fontSize: 37,
    fontFamily: 'Pretendard Variable',
  );

  TextStyle _valueStyle({double fontSize = 35}) => TextStyle(
    color: const Color(0xFF606060),
    fontSize: fontSize,
    fontFamily: 'Pretendard Variable',
  );
}

// 2. 포스터 카드 (배경 이미지 or 스타일 적용 + 텍스트 영역 회색 박스)
class ExperiencePosterCard extends StatelessWidget {
  final Map<String, dynamic> aiData;

  const ExperiencePosterCard({super.key, required this.aiData});

  @override
  Widget build(BuildContext context) {
    final backgroundStyle = aiData['background_style'] as Map<String, dynamic>?;
    final backgroundImageUrl = aiData['background_image_url']?.toString();

    final boxDecoration = BackgroundDecorator.buildBackgroundDecoration(
      backgroundStyle: backgroundStyle,
      backgroundImageUrl: backgroundImageUrl,
    );

    return Container(
      width: 1080,
      height: 1080,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: boxDecoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start, // 위쪽 정렬
        children: [
          const SizedBox(height: 120), // 위쪽 공간 조절 (값 조정 가능)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.5), // 회색 + 투명도 50%
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              aiData['main_title'] ?? '체험명 없음',
              style: const TextStyle(
                fontSize: 65,
                fontWeight: FontWeight.bold,
                color: Color(0xFF231815),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // 아래 여백 또는 다른 위젯 추가 가능
        ],
      ),
    );
  }

  TextStyle _labelStyle() => const TextStyle(
    color: Color(0xFFD23D20),
    fontSize: 30,
    fontFamily: 'Pretendard Variable',
  );

  TextStyle _valueStyle() => const TextStyle(
    color: Color(0xFF606060),
    fontSize: 28,
    fontFamily: 'Pretendard Variable',
  );
}

// 3. 체험 사진 갤러리 카드 (배경 이미지 or 스타일 적용 + 텍스트 영역 흰색 박스)
class ExperienceGalleryCard extends StatelessWidget {
  final Map<String, dynamic> aiData;

  const ExperienceGalleryCard({super.key, required this.aiData});

  @override
  Widget build(BuildContext context) {
    final backgroundStyle = aiData['background_style'] as Map<String, dynamic>?;
    final backgroundImageUrl = aiData['background_image_url']?.toString();
    final List<String> imageUrls = List<String>.from(
      aiData['image_urls'] ?? [],
    );

    final boxDecoration = BackgroundDecorator.buildBackgroundDecoration(
      backgroundStyle: backgroundStyle,
      backgroundImageUrl: backgroundImageUrl,
    );

    return Container(
      width: 1080,
      height: 1080, // 높이를 줄여서 네 이미지가 모두 보이도록 조정
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.only(top: 80, left: 30, right: 30, bottom: 30),
      decoration: boxDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 텍스트 영역 흰색 배경 박스
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              aiData['title'] ?? '체험 사진',
              style: const TextStyle(
                color: Color(0xFF231815),
                fontSize: 75,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8, // 간격 조절
              crossAxisSpacing: 8, // 간격 조절
              childAspectRatio: 1.2, // 가로 세로 비율 조절
              physics: const NeverScrollableScrollPhysics(), // 스크롤 방지
              children:
                  imageUrls
                      .take(4)
                      .map(
                        (url) => ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
