import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String authorId;
  final String? authorNickname; // 추가
  final String villageName;
  final String content;
  final double star;
  final DateTime createAt;
  final DateTime updateAt;
  final String? title;
  final List<String>? hashtags;

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
    this.hashtags,
  });

  factory Review.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      authorId: data['authorId'] as String,
      authorNickname: data['authorNickname'] as String?, // 추가
      villageName: data['체험마을명'] as String,
      content: data['content'] as String,
      star: (data['star'] as num).toDouble(),
      createAt: (data['create_at'] as Timestamp).toDate(),
      updateAt: (data['update_at'] as Timestamp).toDate(),
      title: data['title'] as String?,
      hashtags:
          data['hashtags'] != null
              ? List<String>.from(data['hashtags'] as List)
              : null,
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
    if (hashtags != null) {
      map['hashtags'] = hashtags;
    }
    return map;
  }
}
