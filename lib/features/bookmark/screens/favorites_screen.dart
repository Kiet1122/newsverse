import 'package:flutter/material.dart';
import 'package:newsverse/models/article_model.dart';
import 'package:provider/provider.dart';
import '../../../models/bookmark_model.dart';
import '../bookmark_provider.dart';
import '../../auth/auth_provider.dart';
import '../../../routes/route_names.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    _loadBookmarks();
    _migrateOldBookmarks();
  }

  void _migrateOldBookmarks() {
    final authProvider = context.read<AuthProvider>();
    final bookmarkProvider = context.read<BookmarkProvider>();

    if (authProvider.user != null) {
      bookmarkProvider.migrateBookmarks(authProvider.user!['id']);
    }
  }

  /// Load user bookmarks from the provider
  void _loadBookmarks() {
    final authProvider = context.read<AuthProvider>();
    final bookmarkProvider = context.read<BookmarkProvider>();

    if (authProvider.user != null) {
      bookmarkProvider.loadUserBookmarks(authProvider.user!['id']);
    }
  }

  /// Refresh bookmarks list
  void _onRefresh() {
    _loadBookmarks();
  }

  /// Navigate to article detail screen
  void _onTapArticle(ArticleModel article) {
    Navigator.pushNamed(context, RouteNames.newsDetail, arguments: article);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final bookmarkProvider = context.watch<BookmarkProvider>();

    // Show login required screen if user is not authenticated
    if (authProvider.user == null) {
      return _buildLoginRequired();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Bài viết đã lưu',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey[700]),
            onPressed: _onRefresh,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _buildContent(bookmarkProvider),
    );
  }

  /// Build login required screen
  Widget _buildLoginRequired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'Vui lòng đăng nhập',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Đăng nhập để xem và quản lý các bài viết đã lưu của bạn',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.login);
              },
              icon: const Icon(Icons.login),
              label: const Text('Đăng nhập ngay'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build main content based on bookmark provider state
  Widget _buildContent(BookmarkProvider bookmarkProvider) {
    if (bookmarkProvider.isLoading) {
      return _buildLoadingState();
    }

    if (bookmarkProvider.error != null) {
      return _buildErrorState(bookmarkProvider.error!);
    }

    if (bookmarkProvider.bookmarks.isEmpty) {
      return _buildEmptyState();
    }

    return _buildBookmarksList(bookmarkProvider.bookmarks);
  }

  /// Build loading state widget
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Đang tải bài viết...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// Build error state widget
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_add, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'Chưa có bài viết nào được lưu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Nhấn vào biểu tượng bookmark trên các bài viết để lưu lại và xem sau',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  RouteNames.home,
                  (route) => false,
                );
              },
              icon: const Icon(Icons.explore),
              label: const Text('Khám phá tin tức'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build bookmarks list with refresh indicator
  Widget _buildBookmarksList(List<BookmarkModel> bookmarks) {
    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookmarks.length,
        itemBuilder: (context, index) {
          final bookmark = bookmarks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _BookmarkItem(
              bookmark: bookmark,
              onTap: _onTapArticle,
              onRemove: _removeBookmark,
            ),
          );
        },
      ),
    );
  }

  /// Remove bookmark from the list
  void _removeBookmark(BookmarkModel bookmark) {
    final authProvider = context.read<AuthProvider>();
    final bookmarkProvider = context.read<BookmarkProvider>();

    final article = bookmark.toArticleModel();
    bookmarkProvider.toggleBookmark(
      userId: authProvider.user!['id'],
      article: article,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã xóa khỏi bài viết đã lưu'),
        backgroundColor: Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Individual bookmark item widget
class _BookmarkItem extends StatelessWidget {
  final BookmarkModel bookmark;
  final Function(ArticleModel) onTap;
  final Function(BookmarkModel) onRemove;

  const _BookmarkItem({
    required this.bookmark,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final article = bookmark.toArticleModel();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onTap(article),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BookmarkImage(articleImage: bookmark.articleImage),
                const SizedBox(width: 16),

                Expanded(child: _BookmarkContent(bookmark: bookmark)),

                const SizedBox(width: 8),
                _BookmarkRemoveButton(bookmark: bookmark, onRemove: onRemove),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bookmark image widget
class _BookmarkImage extends StatelessWidget {
  final String? articleImage;

  const _BookmarkImage({required this.articleImage});

  @override
  Widget build(BuildContext context) {
    if (articleImage != null && articleImage!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          articleImage!,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _buildPlaceholderImage();
          },
        ),
      );
    }
    return _buildPlaceholderImage();
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.article, color: Colors.grey[400], size: 32),
    );
  }
}

/// Bookmark content widget (title, description, metadata)
class _BookmarkContent extends StatelessWidget {
  final BookmarkModel bookmark;

  const _BookmarkContent({required this.bookmark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bookmark.articleTitle,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            height: 1.3,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),

        if (bookmark.articleDescription != null)
          Text(
            bookmark.articleDescription!,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

        const SizedBox(height: 12),

        _BookmarkMetadata(bookmark: bookmark),
      ],
    );
  }
}

/// Bookmark metadata widget (source and date)
class _BookmarkMetadata extends StatelessWidget {
  final BookmarkModel bookmark;

  const _BookmarkMetadata({required this.bookmark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            bookmark.source,
            style: TextStyle(
              color: Colors.orange[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              _formatDate(bookmark.savedAt),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ';
    } else {
      return '${difference.inDays} ngày';
    }
  }
}

/// Bookmark remove button widget
class _BookmarkRemoveButton extends StatelessWidget {
  final BookmarkModel bookmark;
  final Function(BookmarkModel) onRemove;

  const _BookmarkRemoveButton({required this.bookmark, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.bookmark, color: Colors.orange[600], size: 24),
      onPressed: () => onRemove(bookmark),
      tooltip: 'Xóa khỏi danh sách đã lưu',
    );
  }
}
