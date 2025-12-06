class Comment {
  final String id;
  final String articleId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final DateTime timestamp;
  final List<String> likes; 
  final String? parentCommentId; 
  
  Comment({
    required this.id,
    required this.articleId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    required this.timestamp,
    this.likes = const [],
    this.parentCommentId,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'articleId': articleId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'likes': likes,
      'parentCommentId': parentCommentId,
    };
  }
  
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      articleId: map['articleId'],
      userId: map['userId'],
      userName: map['userName'],
      userAvatar: map['userAvatar'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
      likes: List<String>.from(map['likes'] ?? []),
      parentCommentId: map['parentCommentId'],
    );
  }
}