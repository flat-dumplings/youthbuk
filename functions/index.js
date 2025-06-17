const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');
const sharp = require('sharp');
const path = require('path');

admin.initializeApp();

// Firebase Functions 환경변수에서 OpenAI API 키 읽기
const OPENAI_API_KEY = functions.config().openai.key;

async function generateText(prompt) {
  const response = await axios.post(
    'https://api.openai.com/v1/chat/completions',
    {
      model: "gpt-3.5-turbo",
      messages: [{ role: "user", content: prompt }],
    },
    {
      headers: {
        Authorization: `Bearer ${OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
      },
    }
  );
  return response.data.choices[0].message.content.trim();
}

async function uploadToStorage(buffer, fileName) {
  const bucket = admin.storage().bucket();
  const file = bucket.file(`posters/${fileName}`);

  await file.save(buffer, { contentType: 'image/png' });

  const [url] = await file.getSignedUrl({
    action: 'read',
    expires: '03-01-2500',
  });

  return url;
}

exports.createPoster = functions.https.onRequest(async (req, res) => {
  console.log('OPENAI_KEY:', OPENAI_API_KEY ? 'Loaded' : 'Not Found');

  try {
    if (req.method !== 'POST') {
      res.status(405).send('Method Not Allowed');
      return;
    }

    const { titlePrompt, subtitlePrompt, aiImageUrl, templateFileName } = req.body;

    if (!titlePrompt || !subtitlePrompt || !aiImageUrl) {
      res.status(400).send('Missing parameters');
      return;
    }

    // 텍스트 생성
    const title = await generateText(titlePrompt);
    const subtitle = await generateText(subtitlePrompt);

    // AI 이미지 불러오기
    const response = await axios.get(aiImageUrl, { responseType: 'arraybuffer' });
    const aiImageBuffer = Buffer.from(response.data, 'binary');

    // 템플릿 이미지 경로
    const templateName = templateFileName || 'template_bg.png';
    const templatePath = path.join(__dirname, 'templates', templateName);

    console.log('Using template image path:', templatePath);

    // sharp 이미지 합성 및 에러 처리
    let posterBuffer;
    try {
      posterBuffer = await sharp(templatePath)
        .composite([{ input: aiImageBuffer, top: 200, left: 50 }])
        .png()
        .toBuffer();
    } catch (sharpError) {
      console.error('Sharp processing error:', sharpError);
      res.status(500).send('Image processing failed');
      return;
    }

    // Firebase Storage에 업로드
    const fileName = `poster_${Date.now()}.png`;
    const posterUrl = await uploadToStorage(posterBuffer, fileName);

    res.json({
      posterUrl,
      generatedTitle: title,
      generatedSubtitle: subtitle,
    });
  } catch (error) {
    console.error('Error in createPoster:', error);
    res.status(500).send('Internal Server Error');
  }
});
