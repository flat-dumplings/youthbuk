import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ShortsPreviewPage extends StatefulWidget {
  final File videoFile;

  const ShortsPreviewPage({super.key, required this.videoFile});

  @override
  State<ShortsPreviewPage> createState() => _ShortsPreviewPageState();
}

class _ShortsPreviewPageState extends State<ShortsPreviewPage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {});
        _controller.setLooping(true);
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('쇼츠 미리보기')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('쇼츠 미리보기')),
      body: Center(
        child: AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
