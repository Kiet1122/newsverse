import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/article_model.dart';
import '../../../models/category_model.dart';
import '../../../models/bookmark_model.dart';

// Service để làm việc với Firestore database
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy danh sách các danh mục tin tức
  Future<List<CategoryModel>> getCategories() async {
    try {
      // Lấy tất cả documents từ collection 'categories'
      final snapshot = await _firestore.collection('categories').get();
      
      // Chuyển đổi từ Firestore documents sang CategoryModel
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi tải danh mục: $e');
    }
  }

  // Lấy danh sách bài viết từ Firebase
  Future<List<ArticleModel>> getFirebaseArticles() async {
    try {
      // Lấy tất cả bài viết từ collection 'articles'
      final snapshot = await _firestore.collection('articles').get();
      
      // Chuyển đổi từ Firestore documents sang ArticleModel
      return snapshot.docs
          .map((doc) => ArticleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi tải bài viết từ Firebase: $e');
    }
  }

  // Thêm bài viết vào danh sách bookmark của user
  Future<void> addBookmark(BookmarkModel bookmark) async {
    try {
      // Thêm document mới vào collection 'bookmarks'
      await _firestore.collection('bookmarks').add(bookmark.toJson());
    } catch (e) {
      throw Exception('Lỗi thêm bookmark: $e');
    }
  }

  // Lấy danh sách bookmark của một user
  Future<List<BookmarkModel>> getUserBookmarks(String userId) async {
    try {
      // Tìm các bookmark có userId trùng khớp
      final snapshot = await _firestore
          .collection('bookmarks')
          .where('userId', isEqualTo: userId)
          .get();

      // Chuyển đổi kết quả sang BookmarkModel
      return snapshot.docs
          .map((doc) => BookmarkModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Lỗi tải bookmark: $e');
    }
  }

  // Lấy thông tin chi tiết một bài viết theo ID
  Future<ArticleModel?> getArticleById(String articleId) async {
    try {
      // Lấy document cụ thể từ collection 'articles'
      final doc = await _firestore.collection('articles').doc(articleId).get();
      
      // Kiểm tra nếu document tồn tại thì trả về dữ liệu
      if (doc.exists) {
        return ArticleModel.fromFirestore(doc);
      }
      return null; // Trả về null nếu không tìm thấy
    } catch (e) {
      throw Exception('Lỗi lấy bài viết: $e');
    }
  }
}