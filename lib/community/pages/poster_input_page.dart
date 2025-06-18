import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PosterInputPage extends StatefulWidget {
  const PosterInputPage({super.key});

  @override
  State<PosterInputPage> createState() => _PosterInputPageState();
}

class _PosterInputPageState extends State<PosterInputPage> {
  bool _loading = false;

  // 대상 마을 리스트
  final List<String> targetVillages = [
    '장수마을',
    '장이익어가는마을',
    '재오개산촌마을',
    '정안마을',
    '지내권역마을',
    '청원사과마을',
    '청풍호권역농촌체험휴양마을',
    '체리마을',
    '초록감투마을',
    '추평호산뜰애마을',
    '팔음산마을',
    '하얀민들레마을',
    '하일한드미마을',
    '학현마을',
    '한두레마을',
    '한드미마을',
    '해평산뜰애마을',
    '햇다래마을',
    '향수뜰마을',
    '황금을따는마을',
    '흙진주포도체험마을',
    '흰여울마을',
  ];

  // 1. 지정된 마을만 대상으로 programs 컬렉션에 프로그램 문서 생성 함수
  Future<void> addProgramsForSelectedVillages() async {
    final firestore = FirebaseFirestore.instance;

    for (final villageId in targetVillages) {
      final docSnapshot =
          await firestore.collection('Villages').doc(villageId).get();
      if (!docSnapshot.exists) {
        print('[$villageId] 문서가 존재하지 않음, 스킵');
        continue;
      }
      final data = docSnapshot.data();
      if (data == null || !data.containsKey('체험프로그램명')) {
        print('[$villageId] 체험프로그램명 필드가 없거나 null, 스킵');
        continue;
      }
      final dynamic combinedProgramsDynamic = data['체험프로그램명'];
      if (combinedProgramsDynamic is! String) {
        print('[$villageId] 체험프로그램명 필드가 문자열이 아님, 스킵');
        continue;
      }
      String combinedPrograms = combinedProgramsDynamic.trim();
      if (combinedPrograms.isEmpty) {
        print('[$villageId] 체험프로그램명 필드가 빈 문자열, 스킵');
        continue;
      }

      List<String> programList = combinedPrograms.split('+');
      final programCollection = firestore
          .collection('Villages')
          .doc(villageId)
          .collection('programs');

      for (final program in programList) {
        final trimmed = program.trim();
        if (trimmed.isEmpty) {
          print('[$villageId] 빈 프로그램명 발견, 스킵');
          continue;
        }

        final docRef = programCollection.doc(trimmed);
        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          try {
            await docRef.set({
              'name': trimmed,
              'createdAt': FieldValue.serverTimestamp(),
            });
            print('[$villageId] 프로그램 추가됨: $trimmed');
          } catch (e) {
            print('[$villageId] 프로그램 추가 실패 ($trimmed): $e');
          }
        } else {
          print('[$villageId] 이미 존재하는 프로그램: $trimmed');
        }
      }
    }

    print('선택된 마을의 모든 체험 프로그램 추가 완료');
  }

  // 2. 프로그램 문서에 필드 일괄 추가 함수 (모든 마을 대상)
  Future<void> addEmptyFieldsToPrograms() async {
    final firestore = FirebaseFirestore.instance;
    try {
      final villagesSnapshot = await firestore.collection('Villages').get();

      for (final villageDoc in villagesSnapshot.docs) {
        final villageId = villageDoc.id;

        final programsSnapshot =
            await firestore
                .collection('Villages')
                .doc(villageId)
                .collection('programs')
                .get();

        for (final programDoc in programsSnapshot.docs) {
          final docRef = programDoc.reference;
          final data = programDoc.data();

          Map<String, dynamic> newFields = {};

          if (!data.containsKey('category')) newFields['category'] = null;
          if (!data.containsKey('price')) newFields['price'] = null;
          if (!data.containsKey('period')) newFields['period'] = null;
          if (!data.containsKey('maxParticipants'))
            newFields['maxParticipants'] = null;
          if (!data.containsKey('photos')) newFields['photos'] = [];
          if (!data.containsKey('duration')) newFields['duration'] = null;
          if (!data.containsKey('totalReviewCount'))
            newFields['totalReviewCount'] = 0;
          if (!data.containsKey('averageRating'))
            newFields['averageRating'] = 0.0;
          if (!data.containsKey('totalParticipants'))
            newFields['totalParticipants'] = 0;
          if (!data.containsKey('totalLikes')) newFields['totalLikes'] = 0;

          if (newFields.isNotEmpty) {
            try {
              await docRef.update(newFields);
              print(
                '[$villageId/${programDoc.id}] 필드 추가됨: ${newFields.keys.toList()}',
              );
            } catch (e) {
              print('[$villageId/${programDoc.id}] 필드 추가 실패: $e');
            }
          } else {
            print('[$villageId/${programDoc.id}] 이미 필드 존재, 스킵');
          }
        }
      }
      print('모든 프로그램에 새 필드 추가 완료');
    } catch (e) {
      print('프로그램 필드 추가 중 오류 발생: $e');
    }
  }

  // 3. 모든 마을의 programs 문서에 villageName 필드 추가 함수
  Future<void> addVillageNameToPrograms() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final villagesSnapshot = await firestore.collection('Villages').get();

      for (final villageDoc in villagesSnapshot.docs) {
        final villageId = villageDoc.id;

        final programsSnapshot =
            await firestore
                .collection('Villages')
                .doc(villageId)
                .collection('programs')
                .get();

        for (final programDoc in programsSnapshot.docs) {
          final docRef = programDoc.reference;
          final data = programDoc.data();

          if (data['villageName'] != villageId) {
            try {
              await docRef.update({'villageName': villageId});
              print('[$villageId/${programDoc.id}] villageName 필드 추가/업데이트됨');
            } catch (e) {
              print('[$villageId/${programDoc.id}] villageName 필드 추가 실패: $e');
            }
          } else {
            print('[$villageId/${programDoc.id}] 이미 villageName 필드 있음, 스킵');
          }
        }
      }
      print('모든 프로그램에 villageName 필드 추가 완료');
    } catch (e) {
      print('villageName 필드 추가 중 오류 발생: $e');
    }
  }

  // --- 버튼 핸들러 ---

  Future<void> _handleAddPrograms() async {
    setState(() {
      _loading = true;
    });

    try {
      await addProgramsForSelectedVillages();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('선택된 마을 체험 프로그램 추가 완료')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _handleAddEmptyFields() async {
    setState(() {
      _loading = true;
    });

    try {
      await addEmptyFieldsToPrograms();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 프로그램 필드 추가 완료')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _handleAddVillageName() async {
    setState(() {
      _loading = true;
    });

    try {
      await addVillageNameToPrograms();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 프로그램에 villageName 필드 추가 완료')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // --- UI 빌드 ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('선택 마을 프로그램 추가 및 필드 관리')),
      body: Center(
        child:
            _loading
                ? const CircularProgressIndicator()
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: _handleAddPrograms,
                      child: const Text('선택된 마을 프로그램 추가 실행'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _handleAddEmptyFields,
                      child: const Text('모든 프로그램 필드 추가 실행'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _handleAddVillageName,
                      child: const Text('모든 프로그램에 villageName 필드 추가'),
                    ),
                  ],
                ),
      ),
    );
  }
}
