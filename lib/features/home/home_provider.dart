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

  HomeProvider({required this.newsApiService, required this.firestoreService});

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

  Future<List<ArticleModel>> getMixedArticles({int limit = 10}) async {
    try {
      final firestoreSnapshot =
          await firestoreService.getAllArticles(); 

      final firestoreArticles = firestoreSnapshot;

      final apiArticles = await newsApiService.fetchTopHeadlines();

      final all = [...firestoreArticles, ...apiArticles];

      all.shuffle();

      return all.take(limit).toList();
    } catch (e) {
      debugPrint("Lỗi mix dữ liệu: $e");
      return [];
    }
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

      for (final category in _categories) {
        print(
          'Category: ${category.name} (ID: ${category.id}, Value: ${category.value})',
        );
      }

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

      await loadCategories();

      final results = await Future.wait([
        _loadFromFirebase(category: category),
        _loadFromApi(category: category), 
      ], eagerError: false);

      final List<ArticleModel> firebaseArticles = results[0];
      final List<ArticleModel> apiArticles = results[1];

      _firebaseCount = firebaseArticles.length;
      _apiCount = apiArticles.length;

      print('Firebase: $_firebaseCount articles for category: $category');
      print('API: $_apiCount articles for category: $category');

      final combinedArticles = _combineAndRemoveDuplicates(
        firebaseArticles,
        apiArticles,
      );

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

  Future<List<ArticleModel>> _loadFromFirebase({
    String category = 'general',
  }) async {
    try {
      final articles = await firestoreService.getFirebaseArticles();
      print('Firebase loaded ${articles.length} articles');

      final mappedArticles = articles.map((article) {
        if (article.categoryId != null) {
          final categoryModel = _categories.firstWhere(
            (cat) => cat.id == article.categoryId,
            orElse: () =>
                CategoryModel(id: '', name: 'General', value: 'general'),
          );
          return article.copyWith(category: categoryModel.value);
        }
        return article;
      }).toList();

      print('Mapped ${mappedArticles.length} articles with category');

      for (var i = 0; i < mappedArticles.length && i < 3; i++) {
        final article = mappedArticles[i];
        print(
          'Firebase Article ${i + 1}: "${article.title}" -> Category: ${article.category} (ID: ${article.categoryId})',
        );
      }

      if (category != 'general') {
        final filtered = mappedArticles.where((article) {
          final articleCategory = article.category ?? 'general';
          final isMatch =
              articleCategory.toLowerCase() == category.toLowerCase();
          if (isMatch) {
            print(
              'Firebase FILTERED: "${article.title}" -> $articleCategory',
            );
          }
          return isMatch;
        }).toList();
        print(
          'Firebase filtered to ${filtered.length} articles for category: $category',
        );
        return filtered;
      }

      return mappedArticles;
    } catch (e) {
      print('Firebase load error: $e');
      return [];
    }
  }

  Future<List<ArticleModel>> _loadFromApi({String category = 'general'}) async {
    try {
      String mapToNewsApiCategory(String ourCategory) {
        switch (ourCategory) {
          case 'technology':
            return 'technology';
          case 'business':
            return 'business';
          case 'sports':
            return 'sports';
          case 'entertainment':
            return 'entertainment';
          case 'health':
            return 'health';
          case 'science':
            return 'science';
          default:
            return 'general';
        }
      }

      final apiCategory = mapToNewsApiCategory(category);
      print(
        'Loading from API with mapped category: $apiCategory (our: $category)',
      );

      final newsResponse = await newsApiService.fetchNews(
        category: apiCategory,
      );
      final articles = newsResponse.articles
          .where(
            (article) =>
                article.title != '[Removed]' &&
                article.title.isNotEmpty &&
                article.url.isNotEmpty,
          )
          .map((apiArticle) => ArticleModel.fromApiArticle(apiArticle))
          .toList();

      print(
        'API processed ${articles.length} valid articles for category: $apiCategory',
      );
      return articles;
    } catch (e) {
      print('API load error: $e');
      return [];
    }
  }

  List<ArticleModel> _combineAndRemoveDuplicates(
    List<ArticleModel> list1,
    List<ArticleModel> list2,
  ) {
    final allArticles = [...list1, ...list2];
    final uniqueArticles = <String, ArticleModel>{};

    for (final article in allArticles) {
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
      print('Searching for: "$query"');

      final results = await Future.wait([
        _searchInFirebase(query),
        _searchInApi(query),
      ], eagerError: false);

      final List<ArticleModel> firebaseArticles = results[0];
      final List<ArticleModel> apiArticles = results[1];

      print('Firebase search results: ${firebaseArticles.length}');
      print('API search results: ${apiArticles.length}');

      final combinedArticles = _combineAndRemoveDuplicates(
        firebaseArticles,
        apiArticles,
      );

      _articles = combinedArticles;

      print('Total search results: ${_articles.length} for "$query"');
    } catch (e) {
      _error = 'Failed to search news: $e';
      print('Search error: $e');
      _articles = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ArticleModel>> _searchInFirebase(String query) async {
    try {
      final articles = await firestoreService.getFirebaseArticles();

      final filteredArticles = articles.where((article) {
        final searchText = query.toLowerCase();
        return article.title.toLowerCase().contains(searchText) ||
            (article.description?.toLowerCase().contains(searchText) ??
                false) ||
            (article.content?.toLowerCase().contains(searchText) ?? false) ||
            (article.author?.toLowerCase().contains(searchText) ?? false);
      }).toList();

      print(
        'Firebase search found ${filteredArticles.length} articles for "$query"',
      );

      final mappedArticles = filteredArticles.map((article) {
        if (article.categoryId != null && _categories.isNotEmpty) {
          final categoryModel = _categories.firstWhere(
            (cat) => cat.id == article.categoryId,
            orElse: () =>
                CategoryModel(id: '', name: 'General', value: 'general'),
          );
          return article.copyWith(category: categoryModel.value);
        }
        return article;
      }).toList();

      return mappedArticles;
    } catch (e) {
      print('Firebase search error: $e');
      return [];
    }
  }

  Future<List<ArticleModel>> _searchInApi(String query) async {
    try {
      final newsResponse = await newsApiService.searchNews(query);
      final articles = newsResponse.articles
          .where(
            (article) =>
                article.title != '[Removed]' &&
                article.title.isNotEmpty &&
                article.url.isNotEmpty,
          )
          .map((apiArticle) => ArticleModel.fromApiArticle(apiArticle))
          .toList();

      print('API search found ${articles.length} articles for "$query"');
      return articles;
    } catch (e) {
      print('API search error: $e');
      return [];
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
