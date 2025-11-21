import 'package:flutter/material.dart';
import '../../../models/article_model.dart';
import 'news_card.dart';

class NewsList extends StatelessWidget {
  final List<ArticleModel> articles;
  final Function(ArticleModel) onTapArticle;

  const NewsList({
    super.key,
    required this.articles,
    required this.onTapArticle,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Không có tin tức',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return NewsCard(
          article: article,
          onTap: () => onTapArticle(article),
        );
      },
    );
  }
}