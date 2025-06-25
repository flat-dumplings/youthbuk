import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:cross_file/cross_file.dart';
import 'package:fal_client/fal_client.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'video_player_page.dart';

class DetailCreatePage extends StatefulWidget {
  const DetailCreatePage({super.key});

  @override
  State<DetailCreatePage> createState() => _DetailCreatePageState();
}

class _DetailCreatePageState extends State<DetailCreatePage> {
  late final TextEditingController titleController;
  late final TextEditingController scriptController;
  late final TextEditingController imageDescriptionController;
  List<XFile> selectedImages = [];
  bool isLoading = false;

  late FalClient fal;
  late String openAiApiKey;
  late String falApiKey;
  late String creatomateApiKey;
  late String googleTtsApiKey;

  String? falVideoUrl;
  String? ttsAudioUrl;

  List<Map<String, dynamic>> timedScript = [];

  double ttsDuration = 10.0;

  String selectedAspectRatio = "9:16";
  final List<String> aspectRatioOptions = ["16:9", "9:16", "1:1"];

  @override
  void initState() {
    super.initState();

    Firebase.initializeApp();

    titleController = TextEditingController();
    scriptController = TextEditingController();
    imageDescriptionController = TextEditingController();

    openAiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    falApiKey = dotenv.env['FAL_AI_API_KEY'] ?? '';
    creatomateApiKey = dotenv.env['CREATOMATE_API_KEY'] ?? '';
    googleTtsApiKey = dotenv.env['GOOGLE_API_KEY'] ?? '';

    fal = FalClient.withCredentials(falApiKey);
  }

  @override
  void dispose() {
    titleController.dispose();
    scriptController.dispose();
    imageDescriptionController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> assignTimedScriptByTextLength(
    List<String> texts, {
    double speed = 1.2,
  }) {
    const baseCharsPerSecond = 15;
    final charsPerSecond = baseCharsPerSecond * speed;

    List<Map<String, dynamic>> result = [];
    double currentTime = 0.0;

    for (final text in texts) {
      final length = text.length;
      final duration = length / charsPerSecond;

      final start = currentTime;
      final end = currentTime + duration;

      result.add({
        'text': text,
        'start': double.parse(start.toStringAsFixed(2)),
        'end': double.parse(end.toStringAsFixed(2)),
      });

      currentTime = end;
    }

    if (currentTime > 10) {
      final scale = 10 / currentTime;
      for (var item in result) {
        item['start'] = double.parse(
          (item['start'] * scale).toStringAsFixed(2),
        );
        item['end'] = double.parse((item['end'] * scale).toStringAsFixed(2));
      }
      currentTime = 10.0;
    }

    ttsDuration = currentTime;
    return result;
  }

  Future<void> generateAIScript() async {
    final titleText = titleController.text.trim();
    final imageDescription = imageDescriptionController.text.trim();

    if (titleText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 먼저 입력하세요')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final prompt = '''
제목: $titleText
이미지 설명: $imageDescription

10초 내외 길이의 영상 홍보 대사를 만들어 주세요. 
친근하고 설득력 있게, 시청자가 흥미를 가질 수 있도록 문장별로 분리해서  
대사 텍스트만 줄바꿈 형태로 출력해 주세요.
''';

      final url = Uri.parse('https://api.openai.com/v1/chat/completions');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAiApiKey',
      };
      final body = jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content":
                "You are a helpful assistant that returns video narration scripts as plain text separated by newlines.",
          },
          {"role": "user", "content": prompt},
        ],
        "max_tokens": 300,
        "temperature": 0.7,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'].trim();

        final lines =
            content
                .split('\n')
                .where((String line) => line.trim().isNotEmpty)
                .toList();

        timedScript = assignTimedScriptByTextLength(lines, speed: 1.2);

        scriptController.text = lines.join('\n');
      } else {
        throw Exception(
          'OpenAI API Error ${response.statusCode}: ${response.body}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('AI 대사 생성 실패: $e')));
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<String> uploadTtsAudioToFirebase(String base64Audio) async {
    Uint8List audioBytes = base64Decode(base64Audio);

    final storageRef = FirebaseStorage.instance.ref();
    final audioRef = storageRef.child(
      'tts_audios/${DateTime.now().millisecondsSinceEpoch}.mp3',
    );

    final uploadTask = audioRef.putData(
      audioBytes,
      SettableMetadata(contentType: 'audio/mp3'),
    );

    await uploadTask.whenComplete(() {});

    final downloadUrl = await audioRef.getDownloadURL();

    return downloadUrl;
  }

  Future<void> convertScriptToTTSAndUpload() async {
    final scriptText = scriptController.text.trim();
    if (scriptText.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('대사를 입력하거나 생성하세요')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final url = Uri.parse(
        'https://texttospeech.googleapis.com/v1/text:synthesize?key=$googleTtsApiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          "input": {"text": scriptText},
          "voice": {
            "languageCode": "ko-KR",
            "name": "ko-KR-Wavenet-A",
            "ssmlGender": "FEMALE",
          },
          "audioConfig": {
            "audioEncoding": "MP3",
            "speakingRate": 1.2,
            "pitch": 0.0,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Google TTS API error: ${response.statusCode} ${response.body}',
        );
      }

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      final String audioContent = jsonResponse['audioContent'];

      final uploadedUrl = await uploadTtsAudioToFirebase(audioContent);

      ttsAudioUrl = uploadedUrl;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('TTS 음성 생성 및 업로드 완료')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('TTS 변환 실패: $e')));
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<String> uploadImageSafe(XFile xfile) async {
    final file = File(xfile.path);
    if (!await file.exists()) {
      throw Exception('파일이 존재하지 않습니다: ${xfile.path}');
    }
    return await fal.storage.upload(xfile);
  }

  Future<void> pickImages() async {
    if (isLoading) return;
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        selectedImages = pickedFiles;
      });
    }
  }

  Future<void> generateFalVideo() async {
    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이미지를 선택해주세요')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final XFile xfile = selectedImages.first;

      // 안전한 업로드
      final String imageUrl = await uploadImageSafe(xfile);

      final int durationValue = 10; // 항상 10초 고정

      final inputData = {
        "prompt": titleController.text.trim(),
        "image_url": imageUrl,
        "duration": durationValue,
        "aspect_ratio": selectedAspectRatio,
        "negative_prompt": "blur, distort, and low quality",
        "cfg_scale": 0.5,
      };

      final output = await fal.subscribe(
        "fal-ai/kling-video/v1.6/standard/image-to-video",
        input: inputData,
        logs: true,
        onQueueUpdate: (update) {
          print('Queue update: $update');
        },
      );

      final videoUrl = output.data['video']['url'];
      if (videoUrl != null && videoUrl.isNotEmpty) {
        falVideoUrl = videoUrl;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('영상 생성 완료')));
      } else {
        throw Exception('영상 URL을 받지 못했습니다');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('영상 생성 실패: $e')));
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  Future<String> pollRenderStatus(
    String renderId,
    Map<String, String> headers,
  ) async {
    final statusUrl = Uri.parse(
      'https://api.creatomate.com/v1/renders/$renderId',
    );
    const maxAttempts = 40;
    const pollInterval = Duration(seconds: 3);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      print('폴링 시도 $attempt 시작');
      final statusResponse = await http.get(statusUrl, headers: headers);

      if (statusResponse.statusCode != 200) {
        throw Exception(
          'Creatomate 상태 조회 실패: ${statusResponse.statusCode} ${statusResponse.body}',
        );
      }

      final statusData = jsonDecode(statusResponse.body);
      final status = statusData['status'];

      print('폴링 시도 $attempt: 상태 = $status');

      if (status == 'done' || status == 'succeeded') {
        final outputUrl = statusData['url'];
        if (outputUrl != null && outputUrl.isNotEmpty) {
          return outputUrl;
        } else {
          throw Exception('렌더 완료되었으나 출력 URL이 없습니다.');
        }
      } else if (status == 'failed') {
        throw Exception('렌더링 실패');
      }

      await Future.delayed(pollInterval);
    }

    throw Exception('렌더링 완료 대기 시간 초과');
  }

  Future<void> mergeVideoAndAudioWithCreatomate() async {
    if (falVideoUrl == null || falVideoUrl!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('먼저 fal.ai로 영상을 생성하세요')));
      return;
    }
    if (ttsAudioUrl == null || ttsAudioUrl!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('먼저 TTS 음성을 생성하고 업로드하세요')));
      return;
    }
    if (timedScript.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('AI 대사 타임코드 정보를 먼저 생성하세요')));
      return;
    }

    setState(() => isLoading = true);

    try {
      final createUrl = Uri.parse('https://api.creatomate.com/v1/renders');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $creatomateApiKey',
      };

      final modifications = <String, dynamic>{
        "b7a7fa0f-913d-4618-8f9b-544e4a10e023.source": ttsAudioUrl, // Audio
        "2fbea0e0-6323-48f7-8412-70ba04f59696.source": falVideoUrl, // Video
      };

      for (var i = 0; i < timedScript.length; i++) {
        final segment = timedScript[i];
        // 템플릿 내 텍스트 레이어 아이디를 정확히 맞춰야 합니다.
        final textLayerId = "text-layer-100$i";
        modifications["$textLayerId.text"] = segment['text'];
        // 필요시 duration, time 조정 가능 (템플릿 지원 여부에 따름)
        // modifications["$textLayerId.time"] = segment['start'];
        // modifications["$textLayerId.duration"] = segment['end'] - segment['start'];
      }

      final body = jsonEncode({
        "template_id": "311204de-b5e6-49de-bfb3-01816e94a127",
        "output_format": "mp4",
        "modifications": modifications,
      });

      final createResponse = await http.post(
        createUrl,
        headers: headers,
        body: body,
      );

      if (createResponse.statusCode == 202) {
        print('Creatomate 렌더링 예약 상태: 202');
      } else if (createResponse.statusCode != 200 &&
          createResponse.statusCode != 201) {
        throw Exception(
          'Creatomate API error: ${createResponse.statusCode} ${createResponse.body}',
        );
      }

      String? renderId;

      try {
        final decoded = jsonDecode(createResponse.body);
        if (decoded is List && decoded.isNotEmpty) {
          renderId = decoded[0]['id'];
        } else if (decoded is Map<String, dynamic>) {
          renderId = decoded['id'];
        } else {
          renderId = null;
        }
      } catch (e) {
        renderId = null;
        print('JSON 파싱 중 오류 발생: $e');
      }

      if (renderId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('영상 합성 ID를 받아오지 못했습니다.')));
        setState(() => isLoading = false);
        return;
      }

      print('렌더링 시작: renderId = $renderId');

      final renderedVideoUrl = await pollRenderStatus(renderId, headers);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => VideoPlayerPage(
                videoUrl: renderedVideoUrl,
                ttsDuration: Duration(
                  milliseconds: (ttsDuration * 1000).toInt(),
                ),
              ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Creatomate 합성 실패: $e')));
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('영상+음성 합성 데모')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: '제목 입력'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageDescriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: '이미지 설명 입력',
                  hintText: '이미지에 대한 간단한 설명을 입력하세요',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: scriptController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '영상 대사 입력',
                  hintText: '직접 입력하거나 AI로 생성하세요',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: isLoading ? null : generateAIScript,
                    child: const Text('AI 대사 생성'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isLoading ? null : convertScriptToTTSAndUpload,
                    child: const Text('TTS 음성 생성 및 업로드'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: isLoading ? null : pickImages,
                icon: const Icon(Icons.photo_library),
                label: const Text('이미지 선택'),
              ),
              if (selectedImages.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedImages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Image.file(
                          File(selectedImages[index].path),
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: isLoading ? null : generateFalVideo,
                child: const Text('fal.ai 영상 생성'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: isLoading ? null : mergeVideoAndAudioWithCreatomate,
                child: const Text('Creatomate로 영상+음성 합성'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
