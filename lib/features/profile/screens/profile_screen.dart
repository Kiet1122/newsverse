import 'package:flutter/material.dart';
import 'package:newsverse/routes/route_names.dart';
import 'package:provider/provider.dart';
import '../profile_provider.dart';
import '../widgets/preference_selector.dart';
import '../../auth/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    if (authProvider.user != null) {
      profileProvider.loadUserPreferences(authProvider.user!['id']);
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Đăng xuất',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
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

  void _toggleNotifications(bool value) {
    final authProvider = context.read<AuthProvider>();
    final profileProvider = context.read<ProfileProvider>();

    if (authProvider.user != null) {
      profileProvider.updateNotifications(
        userId: authProvider.user!['id'],
        enabled: value,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final user = authProvider.user;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (user == null) {
      return _buildLoginRequiredState(theme, colors);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Cá nhân',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colors.surface,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: colors.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildUserInfoCard(user, theme, colors),
            const SizedBox(height: 20),

            _buildQuickActions(profileProvider, theme, colors),
            const SizedBox(height: 20),

            _buildPreferencesCard(profileProvider, user['id'], theme, colors),
            const SizedBox(height: 20),

            _buildLogoutButton(theme, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginRequiredState(ThemeData theme, ColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline_rounded,
            size: 80,
            color: colors.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 20),
          Text(
            'Vui lòng đăng nhập',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colors.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đăng nhập để xem thông tin cá nhân',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(Map<String, dynamic> user, ThemeData theme, ColorScheme colors) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.primary.withOpacity(0.2), width: 3),
              ),
              child: CircleAvatar(
                radius: 42,
                backgroundColor: colors.primary.withOpacity(0.1),
                child: Text(
                  user['name']?.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(
                    fontSize: 28,
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              user['name'] ?? 'Người dùng',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user['email'] ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _getRoleColor(user['role']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getRoleColor(user['role']).withOpacity(0.3)),
              ),
              child: Text(
                _getRoleDisplayName(user['role']),
                style: TextStyle(
                  fontSize: 12,
                  color: _getRoleColor(user['role']),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ProfileProvider provider, ThemeData theme, ColorScheme colors) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.bookmark_rounded, color: Colors.orange),
            ),
            title: Text(
              'Bài viết đã lưu',
              style: theme.textTheme.bodyLarge,
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: colors.onSurface.withOpacity(0.5)),
            onTap: () {
              Navigator.pushNamed(context, RouteNames.favorites);
            },
          ),
          Divider(height: 1, color: colors.outline.withOpacity(0.3)),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.notifications_rounded, color: Colors.blue),
            ),
            title: Text(
              'Thông báo',
              style: theme.textTheme.bodyLarge,
            ),
            trailing: Transform.scale(
              scale: 0.8,
              child: Switch(
                value: provider.preferences.notificationsEnabled,
                onChanged: _toggleNotifications,
                activeColor: colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(ProfileProvider provider, String userId, ThemeData theme, ColorScheme colors) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: provider.isLoading
            ? SizedBox(
                height: 120,
                child: Center(
                  child: CircularProgressIndicator(color: colors.primary),
                ),
              )
            : PreferenceSelector(userId: userId),
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme, ColorScheme colors) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.logout_rounded),
        label: const Text(
          'Đăng xuất',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.errorContainer,
          foregroundColor: colors.onErrorContainer,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: _logout,
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

  String _getRoleDisplayName(String? role) {
    switch (role) {
      case 'admin':
        return 'QUẢN TRỊ VIÊN';
      case 'journalist':
        return 'PHÓNG VIÊN';
      case 'premium':
        return 'THÀNH VIÊN PREMIUM';
      default:
        return 'THÀNH VIÊN';
    }
  }
}