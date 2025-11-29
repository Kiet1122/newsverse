import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/article_model.dart';
import '../../../models/category_model.dart';
import '../../../models/bookmark_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all categories from Firestore
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();

      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi tải danh mục: $e');
    }
  }

  /// Get all articles from Firestore
  Future<List<ArticleModel>> getFirebaseArticles() async {
    try {
      final snapshot = await _firestore.collection('articles').get();

      return snapshot.docs
          .map((doc) => ArticleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi tải bài viết từ Firebase: $e');
    }
  }

  /// Search articles in Firestore based on query
  Future<List<ArticleModel>> searchFirebaseArticles(String query) async {
    try {
      final querySnapshot = await _firestore.collection('articles').get();

      final allArticles = querySnapshot.docs
          .map((doc) => ArticleModel.fromFirestore(doc))
          .toList();

      final filteredArticles = allArticles.where((article) {
        final searchText = query.toLowerCase();
        return article.title.toLowerCase().contains(searchText) ||
            (article.description?.toLowerCase().contains(searchText) ??
                false) ||
            (article.content?.toLowerCase().contains(searchText) ?? false) ||
            (article.author?.toLowerCase().contains(searchText) ?? false) ||
            (article.source.toLowerCase().contains(searchText));
      }).toList();

      print(
        'Firestore search for "$query" found ${filteredArticles.length} articles',
      );
      return filteredArticles;
    } catch (e) {
      print('Error searching Firebase articles: $e');
      return [];
    }
  }

  /// Add a bookmark to Firestore
  Future<void> addBookmark(BookmarkModel bookmark) async {
    try {
      await _firestore.collection('bookmarks').add(bookmark.toJson());
    } catch (e) {
      throw Exception('Lỗi thêm bookmark: $e');
    }
  }

  /// Get user's bookmarks from Firestore
  Future<List<BookmarkModel>> getUserBookmarks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('bookmarks')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => BookmarkModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi tải bookmark: $e');
    }
  }

  /// Get a specific article by its ID
  Future<ArticleModel?> getArticleById(String articleId) async {
    try {
      final doc = await _firestore.collection('articles').doc(articleId).get();

      if (doc.exists) {
        return ArticleModel.fromFirestore(doc);
      }
      return null; 
    } catch (e) {
      throw Exception('Lỗi lấy bài viết: $e');
    }
  }
}