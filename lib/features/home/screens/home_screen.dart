import 'package:flutter/material.dart';
import 'package:newsverse/features/auth/auth_provider.dart';
import 'package:provider/provider.dart';
import '../home_provider.dart';
import '../widgets/category_chips.dart';
import '../widgets/news_list.dart';
import '../../../models/article_model.dart';
import '../../../routes/route_names.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().initializeData();
    });
  }

  void _onCategorySelected(String category) {
    context.read<HomeProvider>().loadCombinedNews(category: category.toLowerCase());
  }

  void _onTapArticle(ArticleModel article) {
    Navigator.pushNamed(
      context,
      RouteNames.newsDetail,
      arguments: article,
    );
  }

  void _refreshData() {
    context.read<HomeProvider>().refreshData();
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut();
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _showUserProfile() {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.user;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue,
              child: Text(
                (user?['name']?.substring(0, 1) ?? 'U').toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?['name'] ?? 'Người dùng',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user?['email'] ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getRoleColor(user?['role']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user?['role']?.toUpperCase() ?? 'USER',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Bài viết đã lưu'),
              onTap: () {
                Navigator.pop(context);
                
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt'),
              onTap: () {
                Navigator.pop(context);
                
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('NewsVerse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Làm mới',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _showUserProfile,
            tooltip: 'Tài khoản',
          ),
        ],
      ),
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          // Hiển thị loading
          if (provider.isLoading && provider.articles.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải tin tức từ nhiều nguồn...'),
                ],
              ),
            );
          }

          // Hiển thị lỗi
          if (provider.error.isNotEmpty && provider.articles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      provider.error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Welcome message
              if (user != null)
                Container(
                  color: Colors.blue[50],
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.waving_hand, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xin chào, ${user['name'] ?? 'Người dùng'}!',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (user['role'] != null && user['role'] != 'user')
                              Text(
                                'Vai trò: ${_getRoleDisplayName(user['role'])}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Categories
              if (provider.categories.isNotEmpty)
                CategoryChips(
                  categories: provider.categories,
                  onCategorySelected: _onCategorySelected,
                ),

              // Thông tin kết hợp
              Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tổng số bài viết
                    Row(
                      children: [
                        Icon(Icons.article, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.articles.length} tin bài',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    // Thông tin nguồn dữ liệu
                    Row(
                      children: [
                        if (provider.firebaseCount > 0)
                          Row(
                            children: [
                              Icon(Icons.cloud, size: 14, color: Colors.blue[600]),
                              const SizedBox(width: 2),
                              Text(
                                '${provider.firebaseCount}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.blue[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        
                        if (provider.apiCount > 0)
                          Row(
                            children: [
                              Icon(Icons.public, size: 14, color: Colors.green[600]),
                              const SizedBox(width: 2),
                              Text(
                                '${provider.apiCount}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // News List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await context.read<HomeProvider>().refreshData();
                  },
                  child: NewsList(
                    articles: provider.articles,
                    onTapArticle: _onTapArticle,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'journalist':
        return Colors.orange;
      case 'premium':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role) {
      case 'admin':
        return 'Quản trị viên';
      case 'journalist':
        return 'Nhà báo';
      case 'premium':
        return 'Thành viên Premium';
      default:
        return 'Người dùng';
    }
  }
}