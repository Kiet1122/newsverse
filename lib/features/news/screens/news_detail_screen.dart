import 'package:flutter/material.dart';
import 'package:newsverse/features/news/widgets/tts_player.dart';
import 'package:newsverse/features/news/widgets/comment_section.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/article_model.dart';
import '../../profile/widgets/bookmark_button.dart';

class NewsDetailScreen extends StatefulWidget {
  final ArticleModel article;

  const NewsDetailScreen({super.key, required this.article});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late String _articleId;

  @override
  void initState() {
    super.initState();
    _articleId = widget.article.id;
  }

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
          BookmarkButton(article: widget.article),
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
              widget.article.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                height: 1.4,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            TTSPlayer(
              articleContent:
                  widget.article.description ?? widget.article.description ?? '',
            ),

            _buildMetaInfo(),

            const SizedBox(height: 20),

            if (widget.article.imageUrl != null &&
                widget.article.imageUrl!.isNotEmpty)
              _buildArticleImage(),

            const SizedBox(height: 24),

            _buildContent(),

            const SizedBox(height: 32),

            CommentSection(articleId: _articleId),

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
                _formatTimeAgo(widget.article.publishedAt),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const Spacer(),

          if (widget.article.author != null &&
              widget.article.author!.isNotEmpty)
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  widget.article.author!,
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
    if (widget.article.imageUrl == null) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        widget.article.imageUrl!, 
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

  Widget _buildContent() {
    String fullContent = '';

    if (widget.article.description != null &&
        widget.article.description!.isNotEmpty) {
      fullContent = _cleanContent(widget.article.description!);
    } else {
      fullContent = 'Nội dung đang được cập nhật...';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          fullContent,
          style: const TextStyle(
            fontSize: 16,
            height: 1.7,
            color: Colors.black87,
          ),
          textAlign: TextAlign.justify,
        ),
      ],
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
    return content
        .replaceAll(RegExp(r'\[\+\d+\s*chars\]'), '')
        .replaceAll(RegExp(r'\[.*?\]'), '') 
        .replaceAll(RegExp(r'…'), '...')
        .replaceAll(RegExp(r'\s+'), ' ') 
        .trim();
  }

  void _readOriginal() async {
    if (widget.article.url.isNotEmpty) {
      final uri = Uri.parse(widget.article.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể mở liên kết'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  String _generateArticleId() {
    final cleanTitle = widget.article.title
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
        .toLowerCase();
    final maxLength = widget.article.title.length < 50
        ? widget.article.title.length
        : 50;
    final timestamp = widget.article.publishedAt.millisecondsSinceEpoch;
    return 'article_${cleanTitle.substring(0, maxLength)}_$timestamp';
  }
}

final navigatorKey = GlobalKey<NavigatorState>();
