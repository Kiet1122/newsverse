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
  });

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
    );
  }

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
    );
  }

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
    };
  }

  String get summary => description ?? 'No description available';
  
  String get image => imageUrl ?? '';
  
  String get sourceName => source; 
}