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

  final List<String> targetVillages = [
    '사기막리마을',
    '미선나무농촌체험휴양마을',
    '도로줌마을',
    '팔음산마을',
    '대실마을',
    '삼태산마을',
    '정안마을',
    '흰여울마을',
    '내포긴들마을',
    '샘양지마을',
    '물안뜰마을',
    '죽리마을',
    '슬로시티수산마을',
    '두메마을',
    '잘산대 대박마을',
    '고래실',
    '덕산누리마을',
    '지내권역마을',
    '흙진주포도마을',
  ];

  final Random random = Random();

  // 오늘부터 앞으로 maxDays일 이내 랜덤 날짜(오전 9시 고정) 생성
  DateTime randomStartDate(int maxDays) {
    final today = DateTime.now();
    final randomDaysFromToday = random.nextInt(maxDays + 1);
    final date = today.add(Duration(days: randomDaysFromToday));
    return DateTime(date.year, date.month, date.day, 9, 0, 0); // 오전 9시 고정
  }

  // 시작일부터 maxDuration일 이내 종료일(오전 9시 고정) 랜덤 생성
  DateTime randomEndDate(DateTime startDate, int maxDuration) {
    final maxEndDate = startDate.add(Duration(days: maxDuration));
    final daysRange = maxEndDate.difference(startDate).inDays;
    final randomDays = random.nextInt(daysRange + 1);
    final endDate = startDate.add(Duration(days: randomDays));
    return DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      9,
      0,
      0,
    ); // 오전 9시 고정
  }

  Future<void> createSubCollectionsWithData() async {
    final firestore = FirebaseFirestore.instance;

    final List<String> detailTypes = ['귀촌형(일반)', '귀농형(일반)'];

    try {
      for (final villageId in targetVillages) {
        final villageDoc =
            await firestore.collection('Villages').doc(villageId).get();
        if (!villageDoc.exists) {
          print('[$villageId] 문서 없음, 스킵');
          continue;
        }

        final villageData = villageDoc.data();
        if (villageData == null) {
          print('[$villageId] 데이터 없음, 스킵');
          continue;
        }

        final representative = villageData['대표자명'];
        final phone = villageData['대표전화번호'];
        final latitude = villageData['위도'];
        final longitude = villageData['경도'];

        // 신청기간 시작일: 오늘부터 30일 이내 랜덤 날짜, 오전 9시 고정
        final applicationStart = randomStartDate(30);

        // 신청기간 종료일: 신청기간 시작일로부터 최대 30일 이내 랜덤, 오전 9시 고정
        final applicationEnd = randomEndDate(applicationStart, 30);

        // 운영기간 시작일: 오늘부터 90일 이내 랜덤 날짜, 오전 9시 고정
        final operationStart = randomStartDate(90);

        // 운영기간 종료일: 운영기간 시작일로부터 최대 90일 이내 랜덤, 오전 9시 고정
        final operationEnd = randomEndDate(operationStart, 90);

        // 모집 인원 (가구 0~10, 명 0~4)
        final recruitHouseholds = random.nextInt(11);
        final recruitPersons = random.nextInt(5);

        // 마을 주민수 (가구 50~100, 명 100~200)
        final villageHouseholds = 50 + random.nextInt(51); // 50~100
        final villagePersons = 100 + random.nextInt(101); // 100~200

        // 세부유형 랜덤 선택
        final detailTypes = ['귀촌형(일반)', '귀농형(일반)'];
        final detailType = detailTypes[random.nextInt(detailTypes.length)];

        // 입주가능일 = 운영기간 시작일
        final moveInDate = operationStart;

        final subCollectionRef = firestore
            .collection('Villages')
            .doc(villageId)
            .collection('living');

        final subDocData = {
          '마을명': villageId,
          '입주가능일': Timestamp.fromDate(moveInDate),
          '신청기간': {
            '시작일': Timestamp.fromDate(applicationStart),
            '종료일': Timestamp.fromDate(applicationEnd),
          },
          '운영기간': {
            '시작일': Timestamp.fromDate(operationStart),
            '종료일': Timestamp.fromDate(operationEnd),
          },
          '모집인원': {'가구': recruitHouseholds, '명': recruitPersons},
          '마을주민수': {'가구': villageHouseholds, '명': villagePersons},
          '세부유형': detailType,
          '대표자명': representative,
          '대표전화번호': phone,
          '위도': latitude,
          '경도': longitude,
          'createdAt': FieldValue.serverTimestamp(),
        };

        final subDocRef = subCollectionRef.doc('info');

        try {
          await subDocRef.set(subDocData);
          print('[$villageId] living 서브컬렉션 문서 생성/업데이트 완료');
        } catch (e) {
          print('[$villageId] living 문서 생성 실패: $e');
        }
      }

      print('모든 마을에 living 서브컬렉션 생성 완료');
    } catch (e) {
      print('서브컬렉션 생성 중 오류 발생: $e');
    }
  }

  Future<void> _handleCreateSubCollections() async {
    setState(() {
      _loading = true;
    });

    try {
      await createSubCollectionsWithData();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('living 서브컬렉션 생성 완료')));
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
      appBar: AppBar(title: const Text('마을 living 서브컬렉션 생성')),
      body: Center(
        child:
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: _handleCreateSubCollections,
                  child: const Text('living 서브컬렉션 생성 및 데이터 입력'),
                ),
      ),
    );
  }
}
