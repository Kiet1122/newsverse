import 'package:flutter/material.dart';
import 'package:newsverse/core/services/firebase/comment_service.dart';
import 'package:newsverse/features/auth/auth_provider.dart';
import 'package:newsverse/models/comment_model.dart';
import 'package:provider/provider.dart';

class CommentSection extends StatelessWidget {
  final String articleId;

  const CommentSection({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    final commentService = Provider.of<CommentService>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            'Bình luận',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall,
          ),
        ),

        _CommentInput(articleId: articleId), 

        const SizedBox(height: 16),

        StreamBuilder<List<Comment>>(
          stream: commentService.getCommentsByArticle(articleId),
          builder: (context, snapshot) {
            print(
              'StreamBuilder - Connection state: ${snapshot.connectionState}',
            );
            print('StreamBuilder - Has data: ${snapshot.hasData}');

            if (snapshot.hasError) {
              print('StreamBuilder - Error: ${snapshot.error}');
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              print(
                'StreamBuilder - No comments found for article: $articleId',
              );
              return const Center(child: Text('Chưa có bình luận nào'));
            }

            print('StreamBuilder - Found ${snapshot.data!.length} comments');

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return _CommentTile(comment: snapshot.data![index]);
              },
            );
          },
        ),
      ],
    );
  }
}

class _CommentInput extends StatefulWidget {
  final String articleId;

  const _CommentInput({required this.articleId});

  @override
  __CommentInputState createState() => __CommentInputState();
}

class __CommentInputState extends State<_CommentInput> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final commentService = Provider.of<CommentService>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Viết bình luận của bạn...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.blue[400]!),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  _commentController.clear();
                },
                child: const Text('Hủy'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () => _submitComment(commentService),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Bình luận'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _submitComment(CommentService commentService) async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung bình luận')),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.firebaseUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng đăng nhập để bình luận'),
          action: SnackBarAction(
            label: 'Đăng nhập',
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userData = authProvider.user;
      final firebaseUser = authProvider.firebaseUser!;

      final comment = Comment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        articleId: widget.articleId,
        userId: firebaseUser.uid, 
        userName:
            userData?['name'] ??
            firebaseUser.displayName ??
            firebaseUser.email?.split('@').first ??
            'Người dùng',
        userAvatar: userData?['avatarUrl'] ?? firebaseUser.photoURL,
        content: _commentController.text.trim(),
        timestamp: DateTime.now(),
      );

      await commentService.addComment(comment);
      _commentController.clear();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã thêm bình luận')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final commentService = Provider.of<CommentService>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.firebaseUser?.uid;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getAvatarColor(comment.userName),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child:
                      comment.userAvatar != null &&
                          comment.userAvatar!.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(comment.userAvatar!),
                          radius: 20,
                        )
                      : Text(
                          _getInitials(comment.userName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatTime(comment.timestamp),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),

              if (currentUserId != null && comment.userId == currentUserId)
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Xóa bình luận'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteDialog(context, commentService);
                    }
                  },
                ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            comment.content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              GestureDetector(
                onTap: currentUserId != null
                    ? () => _toggleLike(context, commentService, currentUserId)
                    : null,
                child: Row(
                  children: [
                    Icon(
                      comment.likes.contains(currentUserId)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 16,
                      color: comment.likes.contains(currentUserId)
                          ? Colors.red
                          : Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      comment.likes
                          .where((id) => id != "current_user_id")
                          .length
                          .toString(),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              GestureDetector(
                onTap: currentUserId != null
                    ? () => _showReplyDialog(context)
                    : null,
                child: Row(
                  children: [
                    Icon(Icons.reply, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      'Phản hồi',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Color _getAvatarColor(String userName) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    final index = userName.codeUnits.fold(0, (a, b) => a + b) % colors.length;
    return colors[index];
  }

  String _getInitials(String userName) {
    final parts = userName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    } else if (userName.isNotEmpty) {
      return userName.substring(0, 1).toUpperCase();
    }
    return '?';
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks tuần trước';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Future<void> _toggleLike(
    BuildContext context,
    CommentService commentService,
    String currentUserId,
  ) async {
    try {
      await commentService.toggleLikeComment(comment.id, currentUserId);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  void _showReplyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phản hồi'),
        content: const Text('Tính năng phản hồi đang được phát triển'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, CommentService commentService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bình luận'),
        content: const Text('Bạn có chắc chắn muốn xóa bình luận này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await commentService.deleteComment(
                  comment.id,
                  comment.articleId,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa bình luận')),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
