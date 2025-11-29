import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/app_drawer.dart';
import '../../routes/route_names.dart';
import '../../features/auth/auth_provider.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;
  final String? title;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentRoute,
    this.title,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _updateCurrentIndex();
  }

  @override
  void didUpdateWidget(MainLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      _updateCurrentIndex();
    }
  }

  /// Updates the current bottom navigation index based on the current route
  void _updateCurrentIndex() {
    final route = widget.currentRoute;
    
    setState(() {
      switch (route) {
        case RouteNames.home:
          _currentIndex = 0;
          break;
        case RouteNames.favorites:
          _currentIndex = 1;
          break;
        case RouteNames.search:
          _currentIndex = 2;
          break;
        case RouteNames.profile:
        case RouteNames.login:
        case RouteNames.register:
          _currentIndex = 3;
          break;
        default:
          _currentIndex = 0;
      }
    });
  }

  /// Handles bottom navigation item taps and navigates to corresponding screens
  void _onBottomNavTap(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0: // Home screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.home,
          (route) => false,
        );
        break;
      case 1: // Saved articles screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.favorites,
          (route) => false,
        );
        break;
      case 2: // Search screen
        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteNames.search,
          (route) => false,
        );
        break;
      case 3: // Profile or Login screen based on authentication status
        final authProvider = context.read<AuthProvider>();
        if (authProvider.user != null) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.profile,
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.login,
            (route) => false,
          );
        }
        break;
    }
  }

  /// Opens the navigation drawer
  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  /// Returns the appropriate app bar title based on current route
  String _getAppBarTitle() {
    if (widget.title != null) return widget.title!;

    switch (widget.currentRoute) {
      case RouteNames.home:
        return 'NewsVerse';
      case RouteNames.favorites:
        return 'Bài viết đã lưu';
      case RouteNames.search:
        return 'Tìm kiếm';
      case RouteNames.profile:
        return 'Trang cá nhân';
      case RouteNames.login:
        return 'Đăng nhập';
      case RouteNames.register:
        return 'Đăng ký';
      default:
        return 'NewsVerse';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Determine if bottom navigation and drawer should be shown
    final showBottomNav = widget.currentRoute != RouteNames.splash;
    final showDrawer = widget.currentRoute != RouteNames.splash;

    return Scaffold(
      key: _scaffoldKey,
      appBar: showBottomNav 
          ? AppBar(
              title: Text(
                _getAppBarTitle(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              leading: showDrawer 
                  ? IconButton(
                      icon: Icon(
                        Icons.menu_rounded,
                        color: colors.onSurface,
                      ),
                      onPressed: _openDrawer,
                      tooltip: 'Mở menu',
                    )
                  : null,
              backgroundColor: colors.surface,
              elevation: 0.5,
              shadowColor: colors.shadow.withOpacity(0.1),
              actions: [
                // Refresh button only shown on home screen
                if (widget.currentRoute == RouteNames.home)
                  IconButton(
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: colors.onSurface.withOpacity(0.7),
                    ),
                    onPressed: () {
                    },
                    tooltip: 'Làm mới tin tức',
                  ),
              ],
            )
          : null,
      drawer: showDrawer ? const AppDrawer() : null,
      body: Container(
        color: colors.background,
        child: widget.child,
      ),
      bottomNavigationBar: showBottomNav 
          ? BottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onBottomNavTap,
            )
          : null,
    );
  }
}