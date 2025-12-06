import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home_provider.dart';
import '../widgets/category_chips.dart';
import '../widgets/personalized_news_list.dart';
import '../../../models/article_model.dart';
import '../../../routes/route_names.dart';
import '../../auth/auth_provider.dart';
import '../../profile/profile_provider.dart';
import '../../bookmark/bookmark_provider.dart';
import 'package:newsverse/features/home/widgets/breaking_news_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().initializeData();
      _initializeUserData();
    });
  }

  void _initializeUserData() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    
    if (user != null) {
      context.read<ProfileProvider>().loadUserPreferences(user['id']);
      context.read<BookmarkProvider>().loadUserBookmarks(user['id']);
    }
  }

  void _onCategorySelected(String category) {
    context.read<HomeProvider>().loadCombinedNews(category: category.toLowerCase());
  }

  void _onTapArticle(ArticleModel article) {
    Navigator.pushNamed(
      context,
      RouteNames.newsDetail,
      arguments: article,
    );
  }

  void _refreshData() {
    context.read<HomeProvider>().refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    if (provider.isLoading && provider.articles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Đang tải tin tức...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.error.isNotEmpty && provider.articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                provider.error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _refreshData,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: BreakingNewsCarousel(),
        ),
        if (provider.categories.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CategoryChips(
              categories: provider.categories,
              onCategorySelected: _onCategorySelected,
            ),
          ),

        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await context.read<HomeProvider>().refreshData();
            },
            child: PersonalizedNewsList(
              articles: provider.articles,
              onTapArticle: _onTapArticle,
            ),
          ),
        ),
      ],
    );
  }
}