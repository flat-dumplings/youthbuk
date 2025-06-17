import 'package:flutter/material.dart';
import 'dart:ui';

class ImageCategory extends StatelessWidget {
  final String imagePath;
  final String label;

  const ImageCategory({
    super.key,
    required this.imagePath,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withOpacity(0.25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 0.6,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // 흐림 효과
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Container(color: Colors.white.withOpacity(0.03)),
                ),
                // 이미지 (크게, 잘려도 OK)
                Center(
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain, // ★ 확대 & 잘릴 수 있게
                    width: 68, // ★ 박스보다 큼 → 일부 잘림 발생
                    height: 68,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
              letterSpacing: 0.2,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
