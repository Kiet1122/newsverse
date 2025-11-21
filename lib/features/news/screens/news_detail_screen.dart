import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/article_model.dart';
import '../../auth/auth_provider.dart';
import '../../../core/services/firebase/firestore_service.dart';

class NewsDetailScreen extends StatelessWidget {
  final ArticleModel article;

  const NewsDetailScreen({
    super.key,
    required this.article,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết tin tức'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareArticle(context),
            tooltip: 'Chia sẻ',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () => _bookmarkArticle(context, authProvider, firestoreService),
            tooltip: 'Lưu bài viết',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tiêu đề
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Thông tin meta
            _buildMetaInfo(),
            
            const SizedBox(height: 16),
            
            // Hình ảnh
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  article.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.article, size: 50, color: Colors.grey),
                    );
                  },
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Mô tả
            if (article.description != null && article.description!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.description!,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            
            // Nội dung
            if (article.content != null && article.content!.isNotEmpty)
              Text(
                _cleanContent(article.content!),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              )
            else if (article.description != null && article.description!.isNotEmpty)
              Text(
                article.description!,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            
            const SizedBox(height: 30),
            
            // Nút hành động
            _buildActionButtons(context, authProvider, firestoreService),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaInfo() {
    return Row(
      children: [
        // Nguồn tin
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            article.source,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Thời gian
        Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          _formatTimeAgo(article.publishedAt),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        
        const Spacer(),
        
        // Tác giả
        if (article.author != null && article.author!.isNotEmpty)
          Text(
            'Tác giả: ${article.author!}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, AuthProvider authProvider, FirestoreService firestoreService) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _readOriginal,
            icon: const Icon(Icons.launch),
            label: const Text('Đọc bài gốc'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _bookmarkArticle(context, authProvider, firestoreService),
            icon: const Icon(Icons.bookmark_border),
            label: const Text('Lưu bài viết'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
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
    return content.replaceAll(RegExp(r'\[\+\d+\s*chars\]'), '').trim();
  }

  void _readOriginal() async {
    final uri = Uri.parse(article.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Không thể mở URL: ${article.url}');
    }
  }

  void _shareArticle(BuildContext context) {
    print('Chia sẻ bài viết: ${article.title}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng chia sẻ đang được phát triển'),
      ),
    );
  }

  void _bookmarkArticle(BuildContext context, AuthProvider authProvider, FirestoreService firestoreService) {
    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để lưu bài viết'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final userId = authProvider.user!['uid'];
    print('Lưu bài viết: ${article.title} cho user: $userId');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã lưu bài viết vào danh sách yêu thích'),
        backgroundColor: Colors.green,
      ),
    );
  }
}