import 'package:flutter/material.dart';
import 'package:newsverse/models/ArticleRepository.dart';
import 'package:newsverse/models/article_model.dart';
import 'package:newsverse/core/services/firebase/firestore_service.dart';
import 'package:newsverse/routes/route_names.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../../core/services/api/news_api_service.dart';

class BreakingNewsCarousel extends StatelessWidget {
  const BreakingNewsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<ArticleRepository>(context, listen: false);

    return FutureBuilder<List<ArticleModel>>(
      future: repo.getMixedArticles(limit: 5),
      builder: (context, snapshot) {
        
        // LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _CarouselLoading();
        }

        // ERROR
        if (snapshot.hasError) {
          return _CarouselError(onRetry: () {
            (context as Element).markNeedsBuild();
          });
        }

        // DATA
        final articles = snapshot.data ?? [];

        if (articles.isEmpty) {
          return const Center(child: Text("Không có dữ liệu"));
        }

        return CarouselSlider(
          items: articles
              .map(
                (article) => _CarouselItem(
                  article: article,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      RouteNames.newsDetail,
                      arguments: article,
                    );
                  },
                ),
              )
              .toList(),
          options: CarouselOptions(
            height: 220,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
          ),
        );
      },
    );
  }
}

class _CarouselItem extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback onTap;

  const _CarouselItem({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = article.imageUrl?.isNotEmpty == true
        ? article.imageUrl!
        : "https://via.placeholder.com/600x400?text=No+Image";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.35),
              BlendMode.darken,
            ),
            onError: (err, s) {},
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Text(
                article.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 8.0,
                      color: Colors.black54,
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarouselLoading extends StatelessWidget {
  const _CarouselLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 220,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _CarouselError extends StatelessWidget {
  final VoidCallback onRetry;

  const _CarouselError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Center(
        child: Column(
          children: [
            const Text("Lỗi tải dữ liệu"),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text("Thử lại"),
            )
          ],
        ),
      ),
    );
  }
}
