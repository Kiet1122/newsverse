import 'package:cloud_firestore/cloud_firestore.dart';

class BookmarkModel {
  final String id;
  final String userId;
  final String articleId;
  final DateTime createdAt;

  BookmarkModel({
    required this.id,
    required this.userId,
    required this.articleId,
    required this.createdAt,
  });

  factory BookmarkModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BookmarkModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      articleId: data['articleId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'articleId': articleId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}