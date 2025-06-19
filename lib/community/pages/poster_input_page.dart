import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PosterInputPage extends StatefulWidget {
  const PosterInputPage({super.key});

  @override
  State<PosterInputPage> createState() => _PosterInputPageState();
}

class _PosterInputPageState extends State<PosterInputPage> {
  bool _loading = false;
  final Random random = Random();

  // 근무기간 옵션
  final List<int> workPeriods = [3, 6, 12];
  // 근무시간 옵션
  final List<String> workTimes = ['8시~18시', '9시~19시'];

  Future<void> createAlbaCollections() async {
    final firestore = FirebaseFirestore.instance;

    try {
      // 모든 마을 문서 가져오기
      final snapshot = await firestore.collection('Villages').get();

      // 문서 아이디(마을명) 리스트 가져와 섞기 후 최대 10개 선택
      final allVillages = snapshot.docs.map((doc) => doc.id).toList();
      allVillages.shuffle(random);
      final targetVillages =
          allVillages.length > 10 ? allVillages.sublist(0, 10) : allVillages;

      for (final villageId in targetVillages) {
        // 해당 마을 문서 찾기
        final villageDoc =
            snapshot.docs.where((d) => d.id == villageId).isNotEmpty
                ? snapshot.docs.firstWhere((d) => d.id == villageId)
                : null;

        if (villageDoc == null) {
          print('[$villageId] 문서 없음, 스킵');
          continue;
        }

        final villageData = villageDoc.data();

        // 마을 필드 값들 가져오기
        final latitude = villageData['위도'];
        final longitude = villageData['경도'];
        final representative = villageData['대표자명'];
        final phone = villageData['대표전화번호'];

        // 알바 서브컬렉션 참조
        final albaCollectionRef = firestore
            .collection('Villages')
            .doc(villageId)
            .collection('alba');

        // 랜덤 필드 생성
        final workPeriod = workPeriods[random.nextInt(workPeriods.length)];
        final residenceProvided = random.nextBool();
        final governmentSupport = random.nextBool();
        final hourlyWage = 10030 + random.nextInt(20000 - 10030 + 1);
        final workTime = workTimes[random.nextInt(workTimes.length)];
        final recruitNumber = 1 + random.nextInt(5); // 1~5명

        // 생성할 문서 데이터
        final albaData = {
          '경도': longitude,
          '위도': latitude,
          '대표자명': representative,
          '대표전화번호': phone,
          '마을명': villageId,
          '근무기간(개월)': workPeriod,
          '거주지제공여부': residenceProvided,
          '시급': hourlyWage,
          '근무시간': workTime,
          '정부지원금가능여부': governmentSupport,
          '모집인원': recruitNumber,
          'createdAt': FieldValue.serverTimestamp(),
        };

        try {
          // 문서 ID는 'info'로 고정 (필요하면 랜덤으로 생성 가능)
          final albaDocRef = albaCollectionRef.doc('info');

          await albaDocRef.set(albaData);
          print('[$villageId] alba/info 문서 생성 완료');
        } catch (e) {
          print('[$villageId] alba/info 문서 생성 실패: $e');
        }
      }

      print('모든 마을에 alba 서브컬렉션 생성 완료');
    } catch (e) {
      print('alba 서브컬렉션 생성 중 오류 발생: $e');
    }
  }

  Future<void> _handleCreateAlbaCollections() async {
    setState(() {
      _loading = true;
    });

    try {
      await createAlbaCollections();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('alba 서브컬렉션 생성 완료')));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마을 alba 서브컬렉션 생성')),
      body: Center(
        child:
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _handleCreateAlbaCollections,
                  child: const Text('alba 서브컬렉션 생성 및 데이터 입력'),
                ),
      ),
    );
  }
}
