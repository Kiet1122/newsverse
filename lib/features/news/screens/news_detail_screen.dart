import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/article_model.dart';
import '../../profile/widgets/bookmark_button.dart';

class NewsDetailScreen extends StatelessWidget {
  final ArticleModel article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Chi tiết tin tức',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          BookmarkButton(article: article),
          IconButton(
            icon: Icon(Icons.share, color: Colors.grey[700]),
            onPressed: () => _shareArticle(context),
            tooltip: 'Chia sẻ',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                height: 1.4,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            _buildMetaInfo(),

            const SizedBox(height: 20),

            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              _buildArticleImage(),

            const SizedBox(height: 24),

            if (article.description != null && article.description!.isNotEmpty)
              _buildDescription(),

            _buildContent(),

            const SizedBox(height: 32),

            _buildCommentsSection(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                _formatTimeAgo(article.publishedAt),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const Spacer(),

          if (article.author != null && article.author!.isNotEmpty)
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  article.author!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildArticleImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        article.imageUrl!,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: 220,
            color: Colors.grey[100],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 220,
            color: Colors.grey[100],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.photo_library, size: 50, color: Colors.grey[400]),
                const SizedBox(height: 8),
                Text(
                  'Không thể tải hình ảnh',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description, size: 18, color: Colors.blue[700]),
              const SizedBox(width: 8),
              Text(
                'Tóm tắt',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            article.description!,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final content = article.content != null && article.content!.isNotEmpty
        ? _cleanContent(article.content!)
        : (article.description ?? 'Nội dung đang được cập nhật...');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.7,
            color: Colors.black87,
          ),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[600]!, Colors.blue[700]!],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _readOriginal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.launch, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Đọc bài viết gốc',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.comment, color: Colors.grey[700], size: 20),
            const SizedBox(width: 8),
            Text(
              'Bình luận',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '3',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        _buildCommentItem(
          avatar: 'U',
          name: 'Nguyễn Văn A',
          time: '2 giờ trước',
          content:
              'Bài viết rất hay và hữu ích. Cảm ơn tác giả đã chia sẻ thông tin chi tiết như vậy!',
          likes: 12,
        ),

        const SizedBox(height: 16),

        _buildCommentItem(
          avatar: 'T',
          name: 'Trần Thị B',
          time: '4 giờ trước',
          content:
              'Thông tin được cập nhật rất nhanh chóng. Tôi thường xuyên theo dõi các bài viết tại đây.',
          likes: 8,
        ),

        const SizedBox(height: 16),

        _buildCommentItem(
          avatar: 'L',
          name: 'Lê Văn C',
          time: '1 ngày trước',
          content:
              'Có thêm hình ảnh minh họa sẽ giúp bài viết sinh động hơn. Hy vọng tác giả cân nhắc!',
          likes: 5,
        ),

        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {},
              child: Center(
                child: Text(
                  'Xem thêm bình luận',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentItem({
    required String avatar,
    required String name,
    required String time,
    required String content,
    required int likes,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                avatar,
                style: TextStyle(
                  color: Colors.blue[800],
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
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      likes.toString(),
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.reply, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      'Phản hồi',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _cleanContent(String content) {
    return content.replaceAll(RegExp(r'\[\+\d+\s*chars\]'), '').trim();
  }

  void _readOriginal() async {
    final uri = Uri.parse(article.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Không thể mở liên kết'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _shareArticle(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tính năng chia sẻ đang được phát triển'),
        backgroundColor: Colors.grey[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

final navigatorKey = GlobalKey<NavigatorState>();
