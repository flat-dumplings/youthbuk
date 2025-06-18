import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String authorId;
  final String? authorNickname;
  final String villageName;
  final String content;
  final double star;
  final DateTime createAt;
  final DateTime updateAt;
  final String? title;
  final List<String>? imageUrl;
  final List<String>? hashtags;
  final int? like;

  Review({
    required this.id,
    required this.authorId,
    this.authorNickname,
    required this.villageName,
    required this.content,
    required this.star,
    required this.createAt,
    required this.updateAt,
    this.title,
    this.imageUrl,
    this.hashtags,
    this.like,
  });

  factory Review.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      authorId: data['authorId'] as String,
      authorNickname: data['authorNickname'] as String?,
      villageName: data['체험마을명'] as String,
      content: data['content'] as String,
      star: (data['star'] as num?)?.toDouble() ?? 0.0,
      createAt:
          (data['create_at'] is Timestamp)
              ? (data['create_at'] as Timestamp).toDate()
              : DateTime.now(),
      updateAt:
          (data['update_at'] is Timestamp)
              ? (data['update_at'] as Timestamp).toDate()
              : DateTime.now(),
      like: (data['like'] as int?) ?? 0,
      title: data['title'] as String?,
      imageUrl:
          data['imageUrl'] is List ? List<String>.from(data['imageUrl']) : null,
      hashtags:
          data['hashtags'] is List ? List<String>.from(data['hashtags']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'authorId': authorId,
      '체험마을명': villageName,
      'content': content,
      'star': star,
      'create_at': Timestamp.fromDate(createAt),
      'update_at': Timestamp.fromDate(updateAt),
    };
    if (authorNickname != null) {
      map['authorNickname'] = authorNickname;
    }
    if (title != null) {
      map['title'] = title;
    }
    if (hashtags != null && hashtags!.isNotEmpty) {
      map['hashtags'] = hashtags;
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      map['imageUrl'] = imageUrl;
    }
    if (like != null) {
      map['like'] = like;
    }
    return map;
  }
}
