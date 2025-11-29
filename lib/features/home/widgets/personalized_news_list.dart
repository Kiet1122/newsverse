import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/article_model.dart';
import '../../auth/auth_provider.dart';
import '../../profile/profile_provider.dart';

class PersonalizedNewsList extends StatelessWidget {
  final List<ArticleModel> articles;
  final Function(ArticleModel) onTapArticle;
  final ScrollController? scrollController;

  const PersonalizedNewsList({
    super.key,
    required this.articles,
    required this.onTapArticle,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    if (authProvider.user == null) {
      return _buildDefaultNewsList();
    }

    if (profileProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final personalizedArticles = _getPersonalizedArticles(
      articles,
      profileProvider.preferences.favoriteCategories,
    );

    return _buildNewsList(personalizedArticles);
  }

  List<ArticleModel> _getPersonalizedArticles(
    List<ArticleModel> allArticles,
    List<String> favoriteCategories,
  ) {
    if (favoriteCategories.isEmpty || favoriteCategories.contains('general')) {
      return allArticles;
    }

    final filteredArticles = allArticles.where((article) {
      final articleCategory = _extractCategoryFromArticle(article);
      return favoriteCategories.contains(articleCategory);
    }).toList();

    return filteredArticles.isNotEmpty ? filteredArticles : allArticles;
  }

  String _extractCategoryFromArticle(ArticleModel article) {
    if (article.category != null && article.category!.isNotEmpty) {
      return article.category!;
    }

    final title = article.title.toLowerCase();

    if (title.contains('công nghệ') ||
        title.contains('tech') ||
        title.contains('ai')) {
      return 'technology';
    } else if (title.contains('kinh doanh') ||
        title.contains('business') ||
        title.contains('market')) {
      return 'business';
    } else if (title.contains('thể thao') ||
        title.contains('sports') ||
        title.contains('bóng')) {
      return 'sports';
    } else if (title.contains('giải trí') ||
        title.contains('entertainment') ||
        title.contains('phim')) {
      return 'entertainment';
    } else if (title.contains('sức khỏe') ||
        title.contains('health') ||
        title.contains('y tế')) {
      return 'health';
    } else if (title.contains('khoa học') || title.contains('science')) {
      return 'science';
    }

    return 'general';
  }

  Widget _buildNewsList(List<ArticleModel> articles) {
    if (articles.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return _buildNewsItem(article);
      },
    );
  }

  Widget _buildDefaultNewsList() {
    return ListView.builder(
      controller: scrollController,
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return _buildNewsItem(article);
      },
    );
  }

  Widget _buildNewsItem(ArticleModel article) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onTapArticle(article),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildArticleImage(article),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article.summary,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              article.source,
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(article.publishedAt),
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArticleImage(ArticleModel article) {
    if (article.imageUrl != null && article.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          article.imageUrl!,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildPlaceholderImage();
          },
        ),
      );
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.article, color: Colors.grey[400], size: 32),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Không có tin tức',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thử chọn danh mục khác',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ';
    } else {
      return '${difference.inDays} ngày';
    }
  }
}