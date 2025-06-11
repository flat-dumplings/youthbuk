// lib/search/models/review_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id; // Firestore 문서 ID
  final String authorId;
  final String villageName; // '체험마을명'
  final String content;
  final double star;
  final DateTime createAt;
  final DateTime updateAt;
  final String? title;
  final List<String>? hashtags;

  Review({
    required this.id,
    required this.authorId,
    required this.villageName,
    required this.content,
    required this.star,
    required this.createAt,
    required this.updateAt,
    this.title,
    this.hashtags,
  });

  factory Review.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final authorId = data['authorId'] as String? ?? '';
    final villageName = data['체험마을명'] as String? ?? '';
    final content = data['content'] as String? ?? '';
    double star = 0.0;
    final starRaw = data['star'];
    if (starRaw is num) star = starRaw.toDouble();
    DateTime createAt = DateTime.now();
    DateTime updateAt = DateTime.now();
    if (data['create_at'] is Timestamp) {
      createAt = (data['create_at'] as Timestamp).toDate();
    }
    if (data['update_at'] is Timestamp) {
      updateAt = (data['update_at'] as Timestamp).toDate();
    }
    String? title = data['title'] as String?;
    List<String>? hashtags;
    if (data['hashtags'] is List) {
      try {
        hashtags = List<String>.from(data['hashtags']);
      } catch (_) {}
    }
    return Review(
      id: doc.id,
      authorId: authorId,
      villageName: villageName,
      content: content,
      star: star,
      createAt: createAt,
      updateAt: updateAt,
      title: title,
      hashtags: hashtags,
    );
  }
}
