// functions/index.js

const admin = require('firebase-admin');
// v1 onRequest 함수용 import
const functions = require('firebase-functions');
// node-fetch 설치되어 있어야 함
const fetch = require('node-fetch');
const { parseStringPromise } = require('xml2js');

// v2 스케줄러 import
const { onSchedule } = require('firebase-functions/v2/scheduler');
// logger
const { logger } = require('firebase-functions');

admin.initializeApp();
const db = admin.firestore();

// --------------------------------------------------
// 핵심 로직 분리 함수: updateTourFestivals
// KorService2/searchFestival2 엔드포인트 사용 예시
async function updateTourFestivals() {
  logger.info('updateTourFestivals 시작');

  // 1) API 키 읽기 (Cloud Run/Functions 환경변수 방식)
  const serviceKeyRaw = process.env.TOUR_API_KEY;
  if (!serviceKeyRaw) {
    throw new Error('환경변수 TOUR_API_KEY가 설정되어 있지 않습니다.');
  }
  // 키를 URL 파라미터에 넣기 전에 인코딩
  const serviceKey = encodeURIComponent(serviceKeyRaw);

  // 2) 날짜 범위: today (YYYYMMDD)
  const today = new Date();
  const pad2 = (n) => String(n).padStart(2, '0');
  const start = `${today.getFullYear()}${pad2(today.getMonth() + 1)}${pad2(today.getDate())}`;
  // KorService2/searchFestival2에서는 eventStartDate만 사용해도 작동하는 예시가 많으므로,
  // 필요 시 문서 확인 후 eventEndDate 파라미터 추가 가능.

  // 3) 지역 코드 등 설정
  const areaCode = '33'; // 예: 충청북도
  const numOfRows = 100;
  let pageNo = 1;
  let moreData = true;
  const collRef = db.collection('festivals');

  // 4) 페이징 처리하며 API 호출
  while (moreData) {
    const url =
      `https://apis.data.go.kr/B551011/KorService2/searchFestival2?serviceKey=${serviceKey}` +
      `&MobileOS=ETC&MobileApp=Youthbuk` +
      `&eventStartDate=${start}` +
      `&areaCode=${areaCode}` +
      `&numOfRows=${numOfRows}&pageNo=${pageNo}`;

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
      logger.error('XML 파싱 오류:', e);
      break;
    }

    // 6) 응답 header 확인 (디버깅용 로그)
    const header = jsonObj.response?.header;
    logger.info('API 응답 header:', JSON.stringify(header));
    // resultCode가 "0000"인지, resultMsg, returnAuthMsg 등을 확인

    // 7) items 배열 추출
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

    // 8) Firestore upsert (batch)
    const batch = db.batch();
    items.forEach((item) => {
      // KorService2 응답 구조에 맞춰 필드 매핑
      const contentId = item.contentid || null;
      const title = item.title || null;
      const startDate = item.eventstartdate || null;
      const endDate = item.eventenddate || null;

      // 문서 ID: contentId가 있으면 그걸 사용, 없으면 title+startDate
      const rawId = contentId ? String(contentId) : `${title}-${startDate}`;
      const docId = encodeURIComponent(rawId);
      const docRef = collRef.doc(docId);

      const data = {
        contentId,
        title,
        description: item.overview || item.eventdescription || null,
        startDate,
        endDate,
        addr1: item.addr1 || null,
        addr2: item.addr2 || null,
        zipcode: item.zipcode || null,
        tel: item.tel || null,
        mapx: item.mapx ? parseFloat(item.mapx) : null,
        mapy: item.mapy ? parseFloat(item.mapy) : null,
        areaCode: item.areacode || null,
        sigunguCode: item.sigungucode || null,
        imageUrl: item.firstimage || null,
        imageUrl2: item.firstimage2 || null,
        homepageUrl: item.homepageurl || null,
        source: 'TourAPI-v2',
        lastFetched: admin.firestore.FieldValue.serverTimestamp(),
      };
      batch.set(docRef, data, { merge: true });
    });
    await batch.commit();
    logger.info(`>> page ${pageNo} 저장 완료 (${items.length}개)`);

    // 9) 페이징 종료 조건
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
// --------------------------------------------------
exports.monthlyFetchTourFestivals = onSchedule(
  {
    schedule: '0 2 1 * *', // 매월 1일 02:00
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
// 3) 필요 시 기존 daily 스케줄러 제거 또는 남기기
// --------------------------------------------------
// exports.scheduledFetchTourFestivalsDaily = onSchedule({...}, async () => { ... });
