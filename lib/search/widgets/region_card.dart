// lib/search/widgets/region_card.dart
import 'package:flutter/material.dart';

class RegionCard extends StatelessWidget {
  final String name;
  final int count;
  final VoidCallback? onTap;

  /// 선택 상태 표시를 원할 때 사용.
  final bool isSelected;

  /// 선택 상태일 때 강조할 색상. 기본: Theme의 primaryColor
  final Color? selectedColor;

  /// 기본 배경 색상
  final Color? backgroundColor;

  /// 카드 모서리 둥글기 정도
  final BorderRadius? borderRadius;

  const RegionCard({
    super.key,
    required this.name,
    required this.count,
    this.onTap,
    this.isSelected = false,
    this.selectedColor,
    this.backgroundColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color primary = selectedColor ?? theme.primaryColor;
    final BorderRadius br = borderRadius ?? BorderRadius.circular(8);

    return InkWell(
      onTap: onTap,
      borderRadius: br,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? primary.withOpacity(0.1)
                  : (backgroundColor ?? Colors.white),
          border: Border.all(
            color: isSelected ? primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: br,
          // 선택 상태일 때 살짝 그림자 추가
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: primary.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 지역명
            Text(
              name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? primary : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            // 프로그램 개수
            Text(
              '$count개 프로그램',
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? primary : Colors.grey.shade600,
              ),
            ),
            // 선택 상태라면 체크 아이콘 표시 (선택 표시용)
            if (isSelected) ...[
              const SizedBox(height: 6),
              Icon(Icons.check_circle, size: 20, color: primary),
            ],
          ],
        ),
      ),
    );
  }
}
