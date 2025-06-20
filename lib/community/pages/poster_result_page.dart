import 'package:flutter/material.dart';

class PosterResultPage extends StatelessWidget {
  final String imageUrl;
  final String description;

  const PosterResultPage({
    super.key,
    required this.imageUrl,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('생성된 포스터')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              description,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(child: Image.network(imageUrl, fit: BoxFit.contain)),
          ],
        ),
      ),
    );
  }
}
