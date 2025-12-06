import 'package:newsverse/core/services/api/news_api_service.dart';
import 'package:newsverse/core/services/firebase/firestore_service.dart';
import 'package:newsverse/models/article_model.dart';

class ArticleRepository {
  final FirestoreService firestoreService;
  final NewsApiService newsApiService;

  ArticleRepository({
    required this.firestoreService,
    required this.newsApiService,
  });

  Future<List<ArticleModel>> getMixedArticles({required int limit}) async {
    final firestoreArticles = await firestoreService.getAllArticles();
    final apiArticles = await newsApiService.fetchTopHeadlines();

    List<ArticleModel> mixed = [...firestoreArticles, ...apiArticles];

    mixed.shuffle();

    return mixed;
  }
}
