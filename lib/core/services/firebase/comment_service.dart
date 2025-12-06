import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:newsverse/models/comment_model.dart';

class CommentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addComment(Comment comment) async {
    await _firestore
        .collection('comments')
        .doc(comment.id)
        .set(comment.toMap());

    await _updateArticleCommentCount(comment.articleId, 1);
  }

  Stream<List<Comment>> getCommentsByArticle(String articleId) {
    print('CommentService - Getting comments for article: $articleId');

    return _firestore
        .collection('comments')
        .where('articleId', isEqualTo: articleId)
        .snapshots()
        .handleError((error) {
          print('CommentService - Stream error: $error');
          throw error;
        })
        .asyncMap((snapshot) async {
          print('CommentService - Got ${snapshot.docs.length} comments');

          final allComments = snapshot.docs
              .map((doc) => Comment.fromMap(doc.data()))
              .toList();

          final rootComments = allComments
              .where((comment) => comment.parentCommentId == null)
              .toList();

          rootComments.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          print('CommentService - Found ${rootComments.length} root comments');
          return rootComments;
        });
  }

  Future<void> toggleLikeComment(String commentId, String userId) async {
    try {
      print('🔹 toggleLikeComment - Comment: $commentId, User: $userId');

      final docRef = _firestore.collection('comments').doc(commentId);

      final doc = await docRef.get();
      if (!doc.exists) {
        print('Comment không tồn tại: $commentId');
        throw Exception('Comment không tồn tại');
      }

      final data = doc.data()!;
      List<dynamic> currentLikes = List.from(data['likes'] ?? []);

      currentLikes.removeWhere((id) => id == "current_user_id");

      final hasLiked = currentLikes.contains(userId);

      print('Current likes: $currentLikes');
      print('User đã like: $hasLiked');

      if (hasLiked) {
        print('Removing like...');
        await docRef.update({
          'likes': FieldValue.arrayRemove([userId]),
        });
        print('Đã bỏ like');
      } else {
        print('Adding like...');
        await docRef.update({
          'likes': FieldValue.arrayUnion([userId]),
        });
        print('Đã thêm like');
      }

      final updatedDoc = await docRef.get();
      final updatedLikes = List.from(updatedDoc.data()!['likes'] ?? []);
      print('Updated likes: $updatedLikes');
    } catch (e) {
      print('Lỗi toggleLikeComment: $e');

      if (e is FirebaseException) {
        print('Firebase error code: ${e.code}');
        print('Firebase error message: ${e.message}');

        if (e.code == 'permission-denied') {
          print('\n FIRESTORE RULES CẦN SỬA NGAY:');
          print('1. Vào Firebase Console → Firestore Database → Rules');
          print('2. Dán rules này và PUBLISH:');
          print('''
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /comments/{commentId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update: if request.auth != null;
      allow delete: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
          ''');
        }
      }

      rethrow;
    }
  }

  Future<void> deleteComment(String commentId, String articleId) async {
    await _firestore.collection('comments').doc(commentId).delete();
    await _updateArticleCommentCount(articleId, -1);
  }

  Future<void> _updateArticleCommentCount(String articleId, int change) async {
    final articleRef = _firestore.collection('articles').doc(articleId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(articleRef);
      if (!doc.exists) return;

      final currentCount = doc.data()!['commentCount'] ?? 0;
      transaction.update(articleRef, {'commentCount': currentCount + change});
    });
  }
}
