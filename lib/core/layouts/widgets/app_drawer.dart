import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../routes/route_names.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final isLoggedIn = user != null;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // User profile header section with gradient background
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primary,
                  colors.primaryContainer,
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                // Decorative background circle
                Positioned(
                  top: -20,
                  right: -20,
                  child: Icon(
                    Icons.circle,
                    size: 100,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                // User information section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // User avatar with initial
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: colors.onPrimary.withOpacity(0.2),
                        child: Text(
                          isLoggedIn 
                            ? (user['name']?.substring(0, 1) ?? 'U').toUpperCase()
                            : 'K',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colors.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // User name display
                      Text(
                        isLoggedIn ? user['name'] ?? 'Người dùng' : 'Khách',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: colors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // User email or login prompt
                      Text(
                        isLoggedIn ? user['email'] ?? '' : 'Vui lòng đăng nhập',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.onPrimary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main navigation menu section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // Home navigation item
                _buildDrawerItem(
                  icon: Icons.home_rounded,
                  title: 'Trang chủ',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(
                      context, 
                      RouteNames.home, 
                      (route) => false
                    );
                  },
                  theme: theme,
                ),

                // Profile navigation item (only for logged in users)
                if (isLoggedIn)
                  _buildDrawerItem(
                    icon: Icons.person_rounded,
                    title: 'Trang cá nhân',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, RouteNames.profile);
                    },
                    theme: theme,
                  ),

                // Saved articles navigation item (only for logged in users)
                if (isLoggedIn)
                  _buildDrawerItem(
                    icon: Icons.bookmark_rounded,
                    title: 'Bài viết đã lưu',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, RouteNames.favorites);
                    },
                    theme: theme,
                  ),

                // Search navigation item
                _buildDrawerItem(
                  icon: Icons.search_rounded,
                  title: 'Tìm kiếm',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, RouteNames.search);
                  },
                  theme: theme,
                ),

                // Categories navigation item
                _buildDrawerItem(
                  icon: Icons.category_rounded,
                  title: 'Danh mục',
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoonMessage(context);
                  },
                  theme: theme,
                ),

                const SizedBox(height: 8),
                // Section divider
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 1),
                ),
                const SizedBox(height: 8),

                // Settings navigation item
                _buildDrawerItem(
                  icon: Icons.settings_rounded,
                  title: 'Cài đặt',
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoonMessage(context);
                  },
                  theme: theme,
                ),

                // Help & Support navigation item
                _buildDrawerItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Trợ giúp & Hỗ trợ',
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoonMessage(context);
                  },
                  theme: theme,
                ),

                const SizedBox(height: 16),

                // Login/Logout button section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: isLoggedIn
                      ? _buildLogoutButton(context, theme, colors)
                      : _buildLoginButton(context, theme, colors),
                ),
              ],
            ),
          ),

          // App footer with version information
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'NewsVerse v1.0',
                  style: TextStyle(
                    color: colors.onSurface.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ứng dụng tin tức thông minh',
                  style: TextStyle(
                    color: colors.onSurface.withOpacity(0.4),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single drawer navigation item with icon and title
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colors.primary,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: colors.onSurface.withOpacity(0.3),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Builds the login button for non-authenticated users
  Widget _buildLoginButton(BuildContext context, ThemeData theme, ColorScheme colors) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        Navigator.pushNamedAndRemoveUntil(
          context, 
          RouteNames.login, 
          (route) => false
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login_rounded, size: 18),
          const SizedBox(width: 8),
          Text(
            'Đăng nhập',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the logout button for authenticated users
  Widget _buildLogoutButton(BuildContext context, ThemeData theme, ColorScheme colors) {
    return OutlinedButton(
      onPressed: () {
        Navigator.pop(context);
        _showLogoutDialog(context);
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.error,
        side: BorderSide(color: colors.error),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout_rounded, size: 18),
          const SizedBox(width: 8),
          Text(
            'Đăng xuất',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Shows confirmation dialog for logout action
  void _showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout_rounded,
                size: 48,
                color: colors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Đăng xuất',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bạn có chắc chắn muốn đăng xuất?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.onSurface,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); 
                        context.read<AuthProvider>().signOut();
                        Navigator.pushNamedAndRemoveUntil(
                          context, 
                          RouteNames.home, 
                          (route) => false
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.error,
                        foregroundColor: colors.onError,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Đăng xuất'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a snackbar message for features under development
  void _showComingSoonMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.build_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Text('Tính năng đang được phát triển'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}