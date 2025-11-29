import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/bookmark_model.dart';
import '../../../models/article_model.dart';

class BookmarkService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save an article to user's bookmarks
  Future<void> saveArticle({
    required String userId,
    required ArticleModel article,
  }) async {
    try {
      final bookmark = BookmarkModel.fromArticle(
        userId: userId,
        article: article,
      );

      final documentPath = 'user_bookmarks/$userId/articles/${article.id}';
      print('Saving bookmark to: $documentPath');

      await _firestore
          .collection('user_bookmarks')
          .doc(userId)
          .collection('articles')
          .doc(article.id)
          .set(bookmark.toJson());

      print('Bookmark saved successfully for article: ${article.title}');
    } catch (e) {
      print('Error saving bookmark: $e');
      throw Exception('Lỗi lưu bookmark: $e');
    }
  }

  /// Remove an article from user's bookmarks
  Future<void> removeArticle({
    required String userId,
    required String articleId,
  }) async {
    try {
      final documentPath = 'user_bookmarks/$userId/articles/$articleId';
      print('Removing bookmark from: $documentPath');

      await _firestore
          .collection('user_bookmarks')
          .doc(userId)
          .collection('articles')
          .doc(articleId)
          .delete();

      print('Bookmark removed successfully for article ID: $articleId');
    } catch (e) {
      print('Error removing bookmark: $e');
      throw Exception('Lỗi xóa bookmark: $e');
    }
  }

  /// Check if an article is bookmarked by the user
  Future<bool> isArticleBookmarked({
    required String userId,
    required String articleId,
  }) async {
    try {
      final doc = await _firestore
          .collection('user_bookmarks')
          .doc(userId)
          .collection('articles')
          .doc(articleId)
          .get();

      final isBookmarked = doc.exists;
      print('Check bookmark - User: $userId, Article: $articleId, Result: $isBookmarked');
      
      return isBookmarked;
    } catch (e) {
      print('Error checking bookmark: $e');
      return false;
    }
  }

  /// Get all bookmarks for a user
  Future<List<BookmarkModel>> getUserBookmarks(String userId) async {
    try {
      print('Loading bookmarks for user: $userId');

      final snapshot = await _firestore
          .collection('user_bookmarks')
          .doc(userId)
          .collection('articles')
          .orderBy('savedAt', descending: true)
          .get();

      final bookmarks = snapshot.docs
          .map((doc) => BookmarkModel.fromFirestore(doc))
          .toList();

      print('Loaded ${bookmarks.length} bookmarks for user: $userId');
      return bookmarks;
    } catch (e) {
      print('Error fetching bookmarks: $e');
      return [];
    }
  }

  /// Get real-time stream of user's bookmarks
  Stream<List<BookmarkModel>> getUserBookmarksStream(String userId) {
    try {
      return _firestore
          .collection('user_bookmarks')
          .doc(userId)
          .collection('articles')
          .orderBy('savedAt', descending: true)
          .snapshots()
          .map((snapshot) {
            final bookmarks = snapshot.docs
                .map((doc) => BookmarkModel.fromFirestore(doc))
                .toList();
            print('Bookmarks stream update: ${bookmarks.length} items');
            return bookmarks;
          })
          .handleError((error) {
            print('Error in bookmarks stream: $error');
            return [];
          });
    } catch (e) {
      print('Error creating bookmarks stream: $e');
      return Stream.value([]);
    }
  }

  /// MIGRATION: Di chuyển bookmarks cũ từ collection 'articles' sang 'user_bookmarks'
  Future<void> migrateOldBookmarks(String userId) async {
    try {
      print('Starting bookmark migration for user: $userId');
      
      // Lấy tất cả documents từ collection 'articles' mà có field 'userId' trùng
      final oldBookmarksSnapshot = await _firestore
          .collection('articles')
          .where('userId', isEqualTo: userId)
          .get();

      print('Found ${oldBookmarksSnapshot.docs.length} old bookmarks to migrate');

      for (final doc in oldBookmarksSnapshot.docs) {
        final data = doc.data();
        
        // Tạo bookmark mới trong cấu trúc mới
        await _firestore
            .collection('user_bookmarks')
            .doc(userId)
            .collection('articles')
            .doc(doc.id)
            .set(data);

        // Xóa bookmark cũ
        await _firestore.collection('articles').doc(doc.id).delete();
        
        print('Migrated bookmark: ${doc.id}');
      }

      print('Bookmark migration completed for user: $userId');
    } catch (e) {
      print('Error during bookmark migration: $e');
    }
  }
}