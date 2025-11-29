import 'package:flutter/material.dart';
import 'package:newsverse/features/bookmark/bookmark_provider.dart';
import 'package:provider/provider.dart';
import '../../../models/article_model.dart';
import '../../auth/auth_provider.dart';

class BookmarkButton extends StatefulWidget {
  final ArticleModel article;
  final double? size;
  final Color? color;

  const BookmarkButton({
    super.key,
    required this.article,
    this.size = 24,
    this.color,
  });

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> with SingleTickerProviderStateMixin {
  bool _isBookmarked = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _checkBookmarkStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkBookmarkStatus() async {
    final authProvider = context.read<AuthProvider>();
    final bookmarkProvider = context.read<BookmarkProvider>();
    
    if (authProvider.user != null) {
      final isBookmarked = await bookmarkProvider.isArticleBookmarked(
        userId: authProvider.user!['id'],
        articleId: widget.article.id,
      );
      
      if (mounted) {
        setState(() {
          _isBookmarked = isBookmarked;
        });
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (_isLoading) return;

    final authProvider = context.read<AuthProvider>();
    final bookmarkProvider = context.read<BookmarkProvider>();
    final theme = Theme.of(context);
    
    if (authProvider.user == null) {
      _showSnackBar(
        'Vui lòng đăng nhập để lưu bài viết',
        Colors.orange,
        Icons.person_outline_rounded,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    await bookmarkProvider.toggleBookmark(
      userId: authProvider.user!['id'],
      article: widget.article,
    );

    final newStatus = await bookmarkProvider.isArticleBookmarked(
      userId: authProvider.user!['id'],
      articleId: widget.article.id,
    );

    if (mounted) {
      setState(() {
        _isBookmarked = newStatus;
        _isLoading = false;
      });

      _showSnackBar(
        _isBookmarked ? 'Đã lưu bài viết' : 'Đã xóa khỏi mục yêu thích',
        _isBookmarked ? Colors.green : theme.colorScheme.primary,
        _isBookmarked ? Icons.bookmark_added_rounded : Icons.bookmark_remove_rounded,
      );
    }
  }

  void _showSnackBar(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: _isLoading
            ? SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.primary,
                ),
              )
            : Icon(
                _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                color: _isBookmarked 
                    ? Colors.orange 
                    : widget.color ?? colors.onSurface.withOpacity(0.7),
                size: widget.size,
              ),
        onPressed: _toggleBookmark,
        tooltip: _isBookmarked ? 'Xóa khỏi mục yêu thích' : 'Lưu bài viết',
        splashRadius: widget.size,
        padding: const EdgeInsets.all(4),
      ),
    );
  }
}