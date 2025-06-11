// lib/search/widgets/like_button.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:youthbuk/search/models/village.dart';

class LikeButton extends StatefulWidget {
  final Village village;
  const LikeButton({super.key, required this.village});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  bool _isLiked = false;
  List<String> _likedCategories = [];

  @override
  void initState() {
    super.initState();
    _loadLikeStatus();
  }

  @override
  void didUpdateWidget(covariant LikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // village가 바뀌면 상태 재로딩
    if (oldWidget.village.id != widget.village.id) {
      _loadLikeStatus();
    }
  }

  Future<void> _loadLikeStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLiked = false;
        _likedCategories = [];
      });
      return;
    }
    setState(() {
      _isLoading = true;
    });
    final uid = user.uid;
    List<String> likedCats = [];

    debugPrint(
      'LikeButton: loading status for village.id="${widget.village.id}"',
    );
    try {
      // 1) 상위 카테고리 문서 목록 조회
      final catSnap =
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('likes')
              .get();
      final docsCat = catSnap.docs;
      debugPrint(
        'LikeButton: found categories = ${docsCat.map((d) => d.id).toList()}',
      );

      // 2) 각 카테고리마다 villages 하위 문서 존재 확인
      final futures =
          docsCat.map((docCat) {
            final categoryId = docCat.id;
            final docRef = _firestore
                .collection('users')
                .doc(uid)
                .collection('likes')
                .doc(categoryId)
                .collection('villages')
                .doc(widget.village.id);
            debugPrint(
              'LikeButton: checking path: users/$uid/likes/$categoryId/villages/${widget.village.id}',
            );
            return docRef.get().then(
              (snap) => MapEntry(categoryId, snap.exists),
            );
          }).toList();

      final results = await Future.wait(futures);
      for (var entry in results) {
        if (entry.value == true) {
          likedCats.add(entry.key);
        }
      }
      debugPrint('LikeButton: likedCats after load = $likedCats');
    } catch (e, st) {
      debugPrint('LikeButton: load status error: $e\n$st');
    }

    setState(() {
      _likedCategories = likedCats;
      _isLiked = likedCats.isNotEmpty;
      _isLoading = false;
    });
  }

  Future<void> _onPressed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }
    final uid = user.uid;

    if (_isLiked) {
      await _showRemoveDialog(uid);
    } else {
      await _showAddDialog(uid);
    }
    await _loadLikeStatus();
  }

  Future<void> _showAddDialog(String uid) async {
    // 1) 기존 카테고리 목록 조회
    List<String> existingCategories = [];
    try {
      final catSnap =
          await _firestore
              .collection('users')
              .doc(uid)
              .collection('likes')
              .get();
      existingCategories = catSnap.docs.map((doc) => doc.id).toList();
      debugPrint(
        'LikeButton: existingCategories for add = $existingCategories',
      );
    } catch (e, st) {
      debugPrint('LikeButton: load categories error: $e\n$st');
      existingCategories = [];
    }

    // 2) 카테고리 선택/입력 다이얼로그
    final selectedCategory = await showDialog<String>(
      context: context,
      builder: (context) {
        String? chosen;
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
                      result = newCategory.trim();
                    } else if (chosen != null && chosen!.isNotEmpty) {
                      result = chosen;
                    }
                    if (result == null || result.isEmpty) {
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

    if (selectedCategory == null || selectedCategory.isEmpty) {
      return;
    }
    final categoryId = selectedCategory.trim();
    if (categoryId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('유효한 카테고리 이름이 아닙니다.')));
      return;
    }

    // 3) 상위 카테고리 문서 생성 (필드 기록)
    final categoryDocRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('likes')
        .doc(categoryId);
    try {
      await categoryDocRef.set({
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e, st) {
      debugPrint('LikeButton: failed to set category doc: $e\n$st');
    }

    // 4) villages 하위 문서 생성
    GeoPoint? geo;
    if (widget.village.geoPoint != null) {
      geo = widget.village.geoPoint;
    } else if (widget.village.latitude != null &&
        widget.village.longitude != null) {
      geo = GeoPoint(widget.village.latitude!, widget.village.longitude!);
    }
    final dataToSave = <String, dynamic>{
      'villageName': widget.village.name,
      if (geo != null) 'location': geo,
      'likedAt': FieldValue.serverTimestamp(),
    };
    try {
      final docRef = categoryDocRef
          .collection('villages')
          .doc(widget.village.id);
      debugPrint(
        'LikeButton: saving like at path users/$uid/likes/$categoryId/villages/${widget.village.id}',
      );
      await docRef.set(dataToSave);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '“${widget.village.name}”을/를 [$categoryId] 카테고리에 저장했습니다.',
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('LikeButton: save like error: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('좋아요 저장 중 오류가 발생했습니다: $e')));
    }
  }

  Future<void> _showRemoveDialog(String uid) async {
    if (_likedCategories.isEmpty) return;

    String? toRemove;
    if (_likedCategories.length == 1) {
      toRemove = _likedCategories.first;
    } else {
      // 여러 카테고리 중 선택
      toRemove = await showDialog<String>(
        context: context,
        builder: (context) {
          String? chosenCat;
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('좋아요 취소할 카테고리 선택'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _likedCategories.length,
                    itemBuilder: (context, index) {
                      final cat = _likedCategories[index];
                      final selectedFlag = (chosenCat == cat);
                      return ListTile(
                        title: Text(cat),
                        leading: Icon(
                          selectedFlag
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                        ),
                        onTap: () {
                          setState(() {
                            chosenCat = cat;
                          });
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (chosenCat == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('카테고리를 선택하세요.')),
                        );
                        return;
                      }
                      Navigator.pop(context, chosenCat);
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
    if (toRemove == null) return;

    final categoryDocRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('likes')
        .doc(toRemove);
    final villageDocRef = categoryDocRef
        .collection('villages')
        .doc(widget.village.id);

    try {
      debugPrint(
        'LikeButton: removing like at path users/$uid/likes/$toRemove/villages/${widget.village.id}',
      );
      // 1) 하위 villages/{villageId} 삭제
      await villageDocRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '“${widget.village.name}”을/를 [$toRemove] 카테고리에서 제거했습니다.',
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('LikeButton: remove like error: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('좋아요 제거 중 오류: $e')));
      return;
    }

    // 2) 해당 카테고리의 villages 하위 컬렉션이 비어있는지 확인
    try {
      final villagesSnap =
          await categoryDocRef.collection('villages').limit(1).get();
      if (villagesSnap.docs.isEmpty) {
        // 하위에 남은 문서가 없으면 상위 카테고리 문서도 삭제
        debugPrint(
          'LikeButton: no more villages under category "$toRemove", deleting category doc',
        );
        await categoryDocRef.delete();
      } else {
        debugPrint(
          'LikeButton: still has villages under category "$toRemove": count ${villagesSnap.docs.length}',
        );
      }
    } catch (e, st) {
      debugPrint('LikeButton: error checking/deleting empty category: $e\n$st');
      // 실패해도 무시
    }
  }

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    if (_isLoading) {
      iconData = Icons.hourglass_empty;
    } else {
      iconData = _isLiked ? Icons.favorite : Icons.favorite_border;
    }
    // 색칠: 좋아요 되어 있으면 빨간, 아니면 회색 등
    final color = _isLiked ? Colors.red : Colors.grey;
    return IconButton(
      icon: Icon(iconData, color: color),
      tooltip: _isLiked ? '좋아요 취소' : '좋아요 추가',
      onPressed: _isLoading ? null : _onPressed,
    );
  }
}
