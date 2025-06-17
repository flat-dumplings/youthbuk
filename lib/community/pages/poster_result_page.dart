import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PosterResultPage extends StatefulWidget {
  final List<String> htmlPages;

  const PosterResultPage({super.key, required this.htmlPages});

  @override
  State<PosterResultPage> createState() => _PosterResultPageState();
}

class _PosterResultPageState extends State<PosterResultPage> {
  int currentPage = 0;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(
            Uri.dataFromString(
              widget.htmlPages[currentPage],
              mimeType: 'text/html',
              encoding: Encoding.getByName('utf-8'),
            ),
          );
  }

  void _loadPage(int index) {
    setState(() => currentPage = index);
    _controller.loadRequest(
      Uri.dataFromString(
        widget.htmlPages[index],
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6F9),
      appBar: AppBar(
        title: Text(
          '카드뉴스 ${currentPage + 1} / ${widget.htmlPages.length}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed:
                currentPage > 0 ? () => _loadPage(currentPage - 1) : null,
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed:
                currentPage < widget.htmlPages.length - 1
                    ? () => _loadPage(currentPage + 1)
                    : null,
          ),
        ],
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          margin: const EdgeInsets.all(16),
          child: AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: WebViewWidget(controller: _controller),
            ),
          ),
        ),
      ),
    );
  }
}
