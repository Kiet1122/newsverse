import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newsverse/models/article_model.dart';

class BookmarkModel {
  final String id;
  final String userId;
  final String articleId;
  final String articleTitle;
  final String? articleDescription;
  final String? articleImage;
  final String articleUrl;
  final String source;
  final DateTime savedAt;

  BookmarkModel({
    required this.id,
    required this.userId,
    required this.articleId,
    required this.articleTitle,
    this.articleDescription,
    this.articleImage,
    required this.articleUrl,
    required this.source,
    required this.savedAt,
  });

  /// Create bookmark from ArticleModel
  factory BookmarkModel.fromArticle({
    required String userId,
    required ArticleModel article,
  }) {
    return BookmarkModel(
      id: 'bookmark_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      articleId: article.id,
      articleTitle: article.title,
      articleDescription: article.description,
      articleImage: article.imageUrl,
      articleUrl: article.url,
      source: article.source,
      savedAt: DateTime.now(),
    );
  }

  /// Create bookmark from Firestore document
  factory BookmarkModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BookmarkModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      articleId: data['articleId'] ?? '',
      articleTitle: data['articleTitle'] ?? '',
      articleDescription: data['articleDescription'],
      articleImage: data['articleImage'],
      articleUrl: data['articleUrl'] ?? '',
      source: data['source'] ?? '',
      savedAt: (data['savedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert BookmarkModel to ArticleModel
  ArticleModel toArticleModel() {
    return ArticleModel(
      id: articleId,
      title: articleTitle,
      description: articleDescription,
      author: null,
      url: articleUrl,
      imageUrl: articleImage,
      publishedAt: savedAt,
      content: null,
      source: source,
    );
  }

  /// Convert bookmark to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'articleId': articleId,
      'articleTitle': articleTitle,
      'articleDescription': articleDescription,
      'articleImage': articleImage,
      'articleUrl': articleUrl,
      'source': source,
      'savedAt': Timestamp.fromDate(savedAt),
    };
  }
}