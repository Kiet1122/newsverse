import 'package:flutter/foundation.dart';
import '../../../core/services/api/news_api_service.dart';
import '../../../core/services/firebase/firestore_service.dart';
import '../../../models/article_model.dart';
import '../../../models/category_model.dart';

class HomeProvider with ChangeNotifier {
  final NewsApiService newsApiService;
  final FirestoreService firestoreService;

  List<ArticleModel> _articles = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String _error = '';
  int _firebaseCount = 0;
  int _apiCount = 0;

  HomeProvider({
    required this.newsApiService,
    required this.firestoreService,
  });

  List<ArticleModel> get articles => _articles;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get loading => _isLoading;
  String get error => _error;
  int get firebaseCount => _firebaseCount;
  int get apiCount => _apiCount;

  Future<void> initializeData() async {
    await loadCategories();
    await loadCombinedNews();
  }

  Future<void> refreshData() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await initializeData();
      print('Data refreshed successfully');
    } catch (e) {
      _error = 'Failed to refresh data: $e';
      print('Refresh error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories() async {
    try {
      print('Loading categories from Firebase...');
      _categories = await firestoreService.getCategories();
      print('Loaded ${_categories.length} categories');
      notifyListeners();
    } catch (e) {
      print('Failed to load categories: $e');
      _error = 'Failed to load categories: $e';
      notifyListeners();
    }
  }

  Future<void> loadCombinedNews({String category = 'general'}) async {
    _isLoading = true;
    _error = '';
    _firebaseCount = 0;
    _apiCount = 0;
    notifyListeners();

    try {
      print('Loading combined news for category: $category');
      
      // Load từ cả hai nguồn song song
      final results = await Future.wait([
        _loadFromFirebase(),
        _loadFromApi(category: category),
      ], eagerError: false);

      final List<ArticleModel> firebaseArticles = results[0];
      final List<ArticleModel> apiArticles = results[1];

      _firebaseCount = firebaseArticles.length;
      _apiCount = apiArticles.length;

      print('Firebase: $_firebaseCount articles');
      print('API: $_apiCount articles');

      // Kết hợp và loại bỏ trùng lặp dựa trên URL
      final combinedArticles = _combineAndRemoveDuplicates(
        firebaseArticles, 
        apiArticles
      );

      // Sắp xếp theo thời gian mới nhất
      combinedArticles.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      _articles = combinedArticles;
      
      print('Combined ${_articles.length} unique articles');
      print('Firebase contributions: $_firebaseCount');
      print('API contributions: $_apiCount');

    } catch (e) {
      print('Error loading combined news: $e');
      _error = 'Lỗi tải tin tức: $e';
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ArticleModel>> _loadFromFirebase() async {
    try {
      final articles = await firestoreService.getFirebaseArticles();
      print('Firebase loaded ${articles.length} articles');
      return articles;
    } catch (e) {
      print('Firebase load error: $e');
      return [];
    }
  }

  Future<List<ArticleModel>> _loadFromApi({String category = 'general'}) async {
    try {
      final newsResponse = await newsApiService.fetchNews(category: category);
      final articles = newsResponse.articles
          .where((article) => 
              article.title != '[Removed]' && 
              article.title.isNotEmpty &&
              article.url.isNotEmpty)
          .map((apiArticle) => ArticleModel.fromApiArticle(apiArticle))
          .toList();
      print('API loaded ${articles.length} articles');
      return articles;
    } catch (e) {
      print('API load error: $e');
      return [];
    }
  }

  List<ArticleModel> _combineAndRemoveDuplicates(
    List<ArticleModel> list1, 
    List<ArticleModel> list2
  ) {
    final allArticles = [...list1, ...list2];
    final uniqueArticles = <String, ArticleModel>{};

    for (final article in allArticles) {
      // Sử dụng URL làm key để loại bỏ trùng lặp
      final key = article.url.toLowerCase();
      if (!uniqueArticles.containsKey(key)) {
        uniqueArticles[key] = article;
      }
    }

    return uniqueArticles.values.toList();
  }

  Future<void> searchNews(String query) async {
    if (query.isEmpty) {
      await loadCombinedNews();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final newsResponse = await newsApiService.searchNews(query);
      _articles = newsResponse.articles
          .where((article) => article.title != '[Removed]' && article.title.isNotEmpty)
          .map((apiArticle) => ArticleModel.fromApiArticle(apiArticle))
          .toList();
      print('Search found ${_articles.length} articles for "$query"');
    } catch (e) {
      _error = 'Failed to search news: $e';
      print('Search error: $e');
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}