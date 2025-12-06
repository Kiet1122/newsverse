import 'package:cloud_firestore/cloud_firestore.dart';

class LikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<void> toggleLikeArticle(String articleId, String userId) async {
    final articleRef = _firestore.collection('articles').doc(articleId);
    
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(articleRef);
      if (!doc.exists) return;
      
      List<String> likes = List<String>.from(doc.data()!['likes'] ?? []);
      
      if (likes.contains(userId)) {
        likes.remove(userId);
      } else {
        likes.add(userId);
      }
      
      transaction.update(articleRef, {
        'likes': likes,
        'likeCount': likes.length
      });
    });
  }
  
  Future<bool> hasUserLiked(String articleId, String userId) async {
    final doc = await _firestore.collection('articles').doc(articleId).get();
    if (!doc.exists) return false;
    
    List<String> likes = List<String>.from(doc.data()!['likes'] ?? []);
    return likes.contains(userId);
  }
}