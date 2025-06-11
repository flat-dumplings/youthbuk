// functions/index.js

const admin = require('firebase-admin');
// v1 함수(https.onRequest)용 import 유지
const functions = require('firebase-functions');
// node-fetch가 설치되어 있어야 합니다.
const fetch = require('node-fetch');
const { parseStringPromise } = require('xml2js');

// v2 스케줄러 import
const { onSchedule } = require('firebase-functions/v2/scheduler');
// Params import: defineString 등을 사용해 환경변수/파라미터화 설정
const { defineString } = require('firebase-functions/params');
// logger 사용 권장 (console 대신)
const { logger } = require('firebase-functions');

admin.initializeApp();
const db = admin.firestore();

// --------------------------------------------------
// Params 선언: Tour API 키
// 배포 전 .env 또는 CLI 프롬프트로 TOUR_API_KEY 값을 설정해두세요.
// 예: functions/.env 에서 TOUR_API_KEY=발급받은_API_키
const TOUR_API_KEY = defineString('TOUR_API_KEY');

// --------------------------------------------------
// 핵심 로직 분리 함수: updateTourFestivals
// fetchTourFestivalsNow, monthlyFetchTourFestivals 등에서 호출
async function updateTourFestivals() {
  logger.info('updateTourFestivals 시작');

  // 1) API 키 읽기: Params 방식
  const serviceKeyRaw = TOUR_API_KEY.value();
  if (!serviceKeyRaw) {
    throw new Error('환경변수/Params TOUR_API_KEY가 설정되어 있지 않습니다.');
  }
  const serviceKey = encodeURIComponent(serviceKeyRaw);

  // 2) 날짜 범위: 오늘부터 1년 뒤 (YYYYMMDD)
  const today = new Date();
  const pad2 = (n) => String(n).padStart(2, '0');
  const start = `${today.getFullYear()}${pad2(today.getMonth() + 1)}${pad2(today.getDate())}`;
  const future = new Date(today);
  future.setFullYear(future.getFullYear() + 1);
  const end = `${future.getFullYear()}${pad2(future.getMonth() + 1)}${pad2(future.getDate())}`;

  // 3) 파라미터 설정
  const areaCode = '33'; // 예: 충청북도. 필요시 변경
  const numOfRows = 100;
  let pageNo = 1;
  let moreData = true;
  const collRef = db.collection('festivals');

  // 4) 페이징 처리하며 API 호출
  while (moreData) {
    const url =
      `https://apis.data.go.kr/B551011/KorService1/searchFestival1?serviceKey=${serviceKey}` +
      `&eventStartDate=${start}&eventEndDate=${end}` +
      `&areaCode=${areaCode}&listYN=Y&arrange=A&numOfRows=${numOfRows}&pageNo=${pageNo}`;
    // 필요에 따라 KorService2/searchFestival2 엔드포인트로 변경 가능
    logger.info(`>> 요청 URL (page ${pageNo}): ${url}`);

    let resp;
    try {
      resp = await fetch(url);
    } catch (fetchErr) {
      throw new Error(`HTTP 요청 중 오류 발생: ${fetchErr.message}`);
    }
    if (!resp.ok) {
      throw new Error(`HTTP 요청 실패: ${resp.status} ${resp.statusText}`);
    }
    const xmlData = await resp.text();

    // 5) XML → JSON 파싱
    let jsonObj;
    try {
      jsonObj = await parseStringPromise(xmlData, { explicitArray: false, trim: true });
    } catch (e) {
      throw new Error(`XML 파싱 오류: ${e.message}`);
    }

    // 6) items 배열 추출
    let items = [];
    try {
      const body = jsonObj.response?.body;
      if (body && body.items && body.items.item) {
        const it = body.items.item;
        items = Array.isArray(it) ? it : [it];
      }
    } catch (e) {
      logger.warn('items 추출 중 예외:', e);
    }
    logger.info(`>> 가져온 축제 개수: ${items.length}`);
    if (!items.length) break;

    // 7) Firestore upsert (batch)
    const batch = db.batch();
    items.forEach((item) => {
      const title = item.title || item.eventTitle || '';
      const startDate = item.eventStartDate || item.eventstartdate || '';
      const rawId = item.contentid ? String(item.contentid) : `${title}-${startDate}`;
      // 문서 ID 생성: contentid가 있으면 사용, 없으면 title-startDate 식으로. 
      const docId = encodeURIComponent(rawId);
      const docRef = collRef.doc(docId);

      const data = {
        // 기존 필드명에 따라 매핑
        contentId: item.contentid || null,
        title: title || null,
        description: item.overview || item.eventDescription || null,
        startDate: startDate || null,
        endDate: item.eventEndDate || item.eventenddate || null,
        addr1: item.addr1 || null,
        addr2: item.addr2 || null,
        zipcode: item.zipcode || null,
        imageUrl: item.firstImageUrl || item.firstimage || null,
        imageUrl2: item.firstImage2 || item.firstimage2 || null,
        detailUrl: item.homepageUrl || null,
        tel: item.tel || null,
        mapx: item.mapx ? parseFloat(item.mapx) : null,
        mapy: item.mapy ? parseFloat(item.mapy) : null,
        areaCode: item.areaCode || item.areacode || null,
        sigunguCode: item.sigunguCode || item.sigungucode || null,
        category1: item.cat1 || null,
        category2: item.cat2 || null,
        category3: item.cat3 || null,
        source: 'TourAPI',
        lastFetched: admin.firestore.FieldValue.serverTimestamp(),
      };
      batch.set(docRef, data, { merge: true });
    });
    await batch.commit();
    logger.info(`>> page ${pageNo} 저장 완료 (${items.length}개)`);

    // 8) 페이징 종료 조건
    if (items.length < numOfRows) {
      moreData = false;
    } else {
      pageNo += 1;
    }
  }

  logger.info('updateTourFestivals 완료');
}

// --------------------------------------------------
// 1) HTTP 즉시 실행 테스트 함수 (v1 방식)
//    - 배포 후 초기 호출용: fetchTourFestivalsNow를 한 번 호출하면 즉시 updateTourFestivals 실행
//    - 즉시 응답 + 백그라운드 처리 방식
// --------------------------------------------------
exports.fetchTourFestivalsNow = functions.https.onRequest((req, res) => {
  logger.info('>> fetchTourFestivalsNow 호출 (즉시 응답)');
  res.status(200).send('갱신 작업을 시작했습니다. 백그라운드에서 처리 중입니다.');
  updateTourFestivals()
    .then(() => {
      logger.info('fetchTourFestivalsNow: updateTourFestivals 완료');
    })
    .catch((e) => {
      logger.error('fetchTourFestivalsNow: updateTourFestivals 예외:', e);
    });
});

// --------------------------------------------------
// 2) 월간 스케줄러 (v2 방식)
//    - 매월 1일 KST 02:00에 실행: 초기 호출 이후 매월 자동 갱신
// --------------------------------------------------
exports.monthlyFetchTourFestivals = onSchedule(
  {
    schedule: '0 2 1 * *',   // cron: 매월 1일 02:00
    timeZone: 'Asia/Seoul',
  },
  async (event) => {
    logger.info('>> monthlyFetchTourFestivals 시작');
    try {
      await updateTourFestivals();
      logger.info('<< monthlyFetchTourFestivals 완료');
    } catch (e) {
      logger.error('monthlyFetchTourFestivals 예외:', e);
    }
  }
);

// --------------------------------------------------
// 3) (선택) 기존 daily 스케줄러가 필요하다면 남기거나 주석 처리
// --------------------------------------------------
// 예를 들어 매일 실행이 필요 없고 월간만 필요하다면 아래 코드를 제거하거나 주석 처리하세요.
// exports.scheduledFetchTourFestivalsDaily = onSchedule(
//   {
//     schedule: '0 2 * * *',  // cron: 매일 02:00
//     timeZone: 'Asia/Seoul',
//   },
//   async (event) => {
//     logger.info('>> scheduledFetchTourFestivalsDaily 시작');
//     try {
//       await updateTourFestivals();
//       logger.info('<< scheduledFetchTourFestivalsDaily 완료');
//     } catch (e) {
//       logger.error('scheduledFetchTourFestivalsDaily 예외:', e);
//     }
//   }
// );

// --------------------------------------------------
// 4) XML 업로드 트리거 (필요 시 활성화)
// --------------------------------------------------
/*
const { onObjectFinalized } = require('firebase-functions/v2/storage');
const { Storage } = require('@google-cloud/storage');
const fs = require('fs');
const path = require('path');
const storage = new Storage();

exports.onXmlUpload = onObjectFinalized(async (event) => {
  logger.info('>> onXmlUpload 시작');
  // (기존 업로드 트리거 로직 그대로 유지)
});
*/

// --------------------------------------------------
// 5) 공통 유틸 함수 분리(필요 시)
// --------------------------------------------------
// 필요하다면 updateTourFestivals처럼 다른 공통 함수도 분리해 호출하세요.
