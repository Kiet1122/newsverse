class ArticleInteraction {
  final String articleId;
  final List<String> likes; 
  final int commentCount;
  
  ArticleInteraction({
    required this.articleId,
    this.likes = const [],
    this.commentCount = 0,
  });
}