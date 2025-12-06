import 'package:cloud_firestore/cloud_firestore.dart';
import './api/api_article.dart';

class ArticleModel {
  final String id;
  final String title;
  final String? description;
  final String? author;
  final String url;
  final String? imageUrl;
  final DateTime publishedAt;
  final String? content;
  final String source;
  final String? categoryId; 
  final String? category;   

  ArticleModel({
    required this.id,
    required this.title,
    this.description,
    this.author,
    required this.url,
    this.imageUrl,
    required this.publishedAt,
    this.content,
    required this.source,
    this.categoryId,
    this.category,
  });

  /// Create ArticleModel from API article data
  factory ArticleModel.fromApiArticle(ApiArticle apiArticle) {
    return ArticleModel(
      id: 'api_${DateTime.now().millisecondsSinceEpoch}',
      title: apiArticle.title,
      description: apiArticle.description,
      author: apiArticle.author,
      url: apiArticle.url,
      imageUrl: apiArticle.urlToImage,
      publishedAt: apiArticle.publishedAt,
      content: apiArticle.content,
      source: apiArticle.sourceName,
      category: 'general', // Default for API articles
    );
  }

  /// Create ArticleModel from Firestore document
  factory ArticleModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ArticleModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'],
      author: data['author'],
      url: data['url'] ?? '',
      imageUrl: data['imageUrl'],
      publishedAt: (data['publishedAt'] as Timestamp).toDate(),
      content: data['content'],
      source: data['source'] ?? 'Firebase',
      categoryId: data['category'], // Store categoryId from Firestore
    );
  }

  /// Create a copy of the article with updated fields
  ArticleModel copyWith({
    String? id,
    String? title,
    String? description,
    String? author,
    String? url,
    String? imageUrl,
    DateTime? publishedAt,
    String? content,
    String? source,
    String? categoryId,
    String? category,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      author: author ?? this.author,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      content: content ?? this.content,
      source: source ?? this.source,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
    );
  }

  /// Convert article to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'author': author,
      'url': url,
      'imageUrl': imageUrl,
      'publishedAt': Timestamp.fromDate(publishedAt),
      'content': content,
      'source': source,
      if (categoryId != null) 'category': categoryId,
    };
  }

  /// Get article summary (description or default message)
  String get summary => description ?? 'No description available';
  
  /// Get article image URL or empty string
  String get image => imageUrl ?? '';
  
  /// Get source name
  String get sourceName => source; 
}