class ApiArticle {
  final String? author;
  final String title;
  final String? description;
  final String url;
  final String? urlToImage; 
  final DateTime publishedAt; 
  final String? content;
  final Map<String, dynamic>? source;

  ApiArticle({
    this.author,
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    this.content,
    this.source,
  });

  factory ApiArticle.fromJson(Map<String, dynamic> json) {
    return ApiArticle(
      author: json['author'],
      title: json['title'] ?? 'No Title',
      description: json['description'],
      url: json['url'] ?? '',
      urlToImage: json['urlToImage'],
      publishedAt: DateTime.parse(
        json['publishedAt'] ?? DateTime.now().toString(),
      ),
      content: json['content'],
      source: json['source'] is Map ? json['source'] : null,
    );
  }

  String get sourceName {
    return source?['name'] ?? 'Unknown Source';
  }
}
