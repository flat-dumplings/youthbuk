// functions/index.js

const admin = require('firebase-admin');
const { onObjectFinalized } = require('firebase-functions/v2/storage');
const xml2js = require('xml2js');
const { Storage } = require('@google-cloud/storage');
const fs = require('fs');
const path = require('path');

// Admin SDK 초기화
admin.initializeApp();
const db = admin.firestore();
const storage = new Storage();

// v2 Storage 트리거: 기본 버킷의 객체가 finalize(업로드)될 때 실행
exports.onXmlUpload = onObjectFinalized(
    // 기본 버킷 사용 시 인자 없이 호출하거나, 명시적으로 bucket 옵션 지정:
    // { bucket: 'youthbuk-ba603.appspot.com' }  // 필요 시 프로젝트 버킷 이름으로 변경
    async (event) => {
        try {
            const object = event.data; // v2 이벤트의 data 속성
            const filePath = object.name; // e.g. "xml/chungbuk_experience_villages.xml"
            if (!filePath) {
                console.log('filePath 없음, 처리하지 않음.');
                return;
            }
            // xml/ 경로 및 .xml 확장자 필터
            if (!filePath.startsWith('xml/') || !filePath.toLowerCase().endsWith('.xml')) {
                console.log('xml/ 폴더 아래 .xml 파일이 아니므로 처리하지 않음:', filePath);
                return;
            }

            const bucketName = object.bucket;
            console.log(`처리 대상 XML 업로드 감지: gs://${bucketName}/${filePath}`);

            // 임시 경로: Cloud Functions v2도 /tmp 디렉터리 사용
            const tmpFilePath = path.join('/tmp', path.basename(filePath));
            // GCS에서 파일 다운로드
            await storage.bucket(bucketName).file(filePath).download({ destination: tmpFilePath });
            console.log('XML 파일 다운로드 완료:', tmpFilePath);

            // XML 읽기 & 파싱
            const xmlData = fs.readFileSync(tmpFilePath, 'utf-8');
            const parser = new xml2js.Parser({ explicitArray: false, trim: true });
            let parsed;
            try {
                parsed = await parser.parseStringPromise(xmlData);
            } catch (parseErr) {
                console.error('XML 파싱 오류:', parseErr);
                return;
            }

            // records 추출: XML 구조에 맞춰 조정
            let records = [];
            if (parsed.records && parsed.records.record) {
                const rec = parsed.records.record;
                records = Array.isArray(rec) ? rec : [rec];
            } else {
                console.warn('parsed.records.record를 찾지 못함. parsed 구조 키:', Object.keys(parsed));
                return;
            }
            console.log(`XML에서 추출된 레코드 수: ${records.length}`);

            // Firestore에 배치 저장
            const BATCH_SIZE = 500;
            for (let i = 0; i < records.length; i += BATCH_SIZE) {
                const batch = db.batch();
                const chunk = records.slice(i, i + BATCH_SIZE);
                chunk.forEach((raw) => {
                    // “체험마을명” 필드명은 XML 스키마에 맞춰 정확히 사용
                    const rawName = raw['체험마을명'] || raw['exprnVilageNm'];
                    if (!rawName) {
                        console.warn('체험마을명 누락, 스킵:', raw);
                        return;
                    }
                    // 문서 ID 치환
                    const docId = rawName.replace(/[\/#\[\]\*?]/g, '_').trim();
                    const docRef = db.collection('Villages').doc(docId);

                    // 데이터 매핑: 필요 필드 확인 후 매핑
                    const data = {
                        체험마을명: raw['체험마을명'] || null,
                        시도명: raw['시도명'] || null,
                        시군구명: raw['시군구명'] || null,
                        소재지도로명주소: raw['소재지도로명주소'] || null,
                        체험프로그램구분: raw['체험프로그램구분'] || null,
                        체험프로그램명: raw['체험프로그램명'] || null,
                        대표자명: raw['대표자명'] || null,
                        대표전화번호: raw['대표전화번호'] || null,
                        홈페이지주소: raw['홈페이지주소'] || null,
                        관리기관명: raw['관리기관명'] || null,
                        체험휴양마을사진: raw['체험휴양마을사진'] || null,
                        syncedAt: admin.firestore.Timestamp.now(),
                    };
                    // 위도/경도 처리
                    if (raw['위도']) {
                        const lat = parseFloat(raw['위도']);
                        if (!isNaN(lat)) data.위도 = lat;
                    }
                    if (raw['경도']) {
                        const lng = parseFloat(raw['경도']);
                        if (!isNaN(lng)) data.경도 = lng;
                    }
                    if (data.위도 != null && data.경도 != null) {
                        data.location = new admin.firestore.GeoPoint(data.위도, data.경도);
                    }
                    batch.set(docRef, data, { merge: true });
                });
                await batch.commit();
                console.log(`배치 커밋: ${i} ~ ${i + chunk.length - 1}`);
            }
            console.log('Firestore 저장 완료');

            // 임시 파일 삭제 (선택)
            try { fs.unlinkSync(tmpFilePath); } catch (e) { }
            return;
        } catch (error) {
            console.error('onXmlUpload 처리 중 오류:', error);
            return;
        }
    }
);
