// lib/search/widgets/category_picker_dialog.dart

import 'package:flutter/material.dart';

/// 다이얼로그로 기존 카테고리 목록(existingCategories) 중 선택하거나
/// 새 카테고리 입력(newCategory) 후 확인 시 Future<String?> 로 반환.
/// 선택 취소 시 null 반환.
Future<String?> showCategoryPickerDialog({
  required BuildContext context,
  required List<String> existingCategories,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) {
      String? chosen; // 기존 카테고리 중 선택된 값
      String newCategory = '';
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('좋아요 카테고리 선택'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (existingCategories.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8.0),
                        child: Text('기존 카테고리'),
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        itemCount: existingCategories.length,
                        itemBuilder: (context, index) {
                          final cat = existingCategories[index];
                          final selectedFlag = (chosen == cat);
                          return ListTile(
                            title: Text(cat),
                            leading: Icon(
                              selectedFlag
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                            ),
                            onTap: () {
                              setState(() {
                                chosen = cat;
                                newCategory = '';
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('새 카테고리 추가'),
                  ),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: '카테고리 이름을 입력하세요',
                    ),
                    onChanged: (val) {
                      setState(() {
                        newCategory = val.trim();
                        if (newCategory.isNotEmpty) {
                          chosen = null;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  String? result;
                  if (newCategory.isNotEmpty) {
                    result = newCategory;
                  } else if (chosen != null && chosen!.isNotEmpty) {
                    result = chosen;
                  }
                  if (result == null || result.isEmpty) {
                    // 토스트나 SnackBar 대신 Navigator.pop 없이 경고 표시
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('카테고리를 선택하거나 입력하세요.')),
                    );
                    return;
                  }
                  Navigator.pop(context, result);
                },
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
    },
  );
}
