import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/auth_provider.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: colors.surface,
          selectedItemColor: colors.primary,
          unselectedItemColor: colors.onSurface.withOpacity(0.6),
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.primary,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: colors.onSurface.withOpacity(0.6),
          ),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 8,
          items: [
            // Home navigation item
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentIndex == 0
                      ? colors.primary.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Icon(
                  currentIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
                  size: 22,
                ),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.home_rounded,
                  size: 22,
                  color: colors.primary,
                ),
              ),
              label: 'Trang chủ',
            ),

            // Saved articles navigation item
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentIndex == 1
                      ? colors.primary.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Icon(
                  currentIndex == 1
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  size: 22,
                ),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.bookmark_rounded,
                  size: 22,
                  color: colors.primary,
                ),
              ),
              label: 'Đã lưu',
            ),

            // Search navigation item
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentIndex == 2
                      ? colors.primary.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Icon(
                  currentIndex == 2
                      ? Icons.search_rounded
                      : Icons.search_outlined,
                  size: 22,
                ),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.search_rounded,
                  size: 22,
                  color: colors.primary,
                ),
              ),
              label: 'Tìm kiếm',
            ),

            // Profile/Login navigation item - changes based on authentication status
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: currentIndex == 3
                      ? colors.primary.withOpacity(0.1)
                      : Colors.transparent,
                ),
                child: Icon(
                  currentIndex == 3
                      ? Icons.person_rounded
                      : Icons.person_outline_rounded,
                  size: 22,
                ),
              ),
              activeIcon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 22,
                  color: colors.primary,
                ),
              ),
              label: user != null ? 'Cá nhân' : 'Đăng nhập',
            ),
          ],
        ),
      ),
    );
  }
}
