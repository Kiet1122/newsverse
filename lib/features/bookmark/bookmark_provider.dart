import 'package:flutter/foundation.dart';
import '../../../core/services/firebase/bookmark_service.dart';
import '../../../models/bookmark_model.dart';
import '../../../models/article_model.dart';

class BookmarkProvider with ChangeNotifier {
  final BookmarkService _bookmarkService = BookmarkService();

  List<BookmarkModel> _bookmarks = [];
  bool _isLoading = false;
  String? _error;

  List<BookmarkModel> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Toggle bookmark status for an article
  Future<void> toggleBookmark({
    required String userId,
    required ArticleModel article,
  }) async {
    try {
      final isBookmarked = await _bookmarkService.isArticleBookmarked(
        userId: userId,
        articleId: article.id,
      );

      if (isBookmarked) {
        await _bookmarkService.removeArticle(
          userId: userId,
          articleId: article.id,
        );
        print('Bookmark removed: ${article.title}');
      } else {
        await _bookmarkService.saveArticle(userId: userId, article: article);
        print('Bookmark saved: ${article.title}');
      }

      await loadUserBookmarks(userId);
    } catch (e) {
      _error = 'Lỗi lưu bài viết: $e';
      notifyListeners();
    }
  }

  /// Check if an article is bookmarked by the user
  Future<bool> isArticleBookmarked({
    required String userId,
    required String articleId,
  }) async {
    return await _bookmarkService.isArticleBookmarked(
      userId: userId,
      articleId: articleId,
    );
  }

  /// Load all bookmarks for a user
  Future<void> loadUserBookmarks(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookmarks = await _bookmarkService.getUserBookmarks(userId);
      print('Loaded ${_bookmarks.length} bookmarks');
    } catch (e) {
      _error = 'Lỗi tải bookmark: $e';
      print('Error loading bookmarks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> migrateBookmarks(String userId) async {
    await _bookmarkService.migrateOldBookmarks(userId);
  }

  /// Clear any existing error messages
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
