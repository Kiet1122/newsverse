import 'package:flutter/material.dart';
import 'package:newsverse/features/auth/screens/forgot_password_screen.dart';
import 'package:newsverse/models/article_model.dart';
import '../core/layouts/main_layout.dart';
import '../features/splash/screens/splash_screen.dart'; 
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/bookmark/screens/favorites_screen.dart';
import '../features/search/screens/search_screen.dart';
import '../features/news/screens/news_detail_screen.dart';

import 'route_names.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case RouteNames.splash:
      return MaterialPageRoute(builder: (_) => const SplashScreen());

    case RouteNames.home:
      return MaterialPageRoute(
        builder: (_) => MainLayout(
          currentRoute: RouteNames.home,
          child: const HomeScreen(),
        ),
      );

    case RouteNames.login:
      return MaterialPageRoute(
        builder: (_) => MainLayout(
          currentRoute: RouteNames.login,
          child: const LoginScreen(),
        ),
      );

    case RouteNames.register:
      return MaterialPageRoute(
        builder: (_) => MainLayout(
          currentRoute: RouteNames.register,
          child: const RegisterScreen(),
        ),
      );

    case RouteNames.forgotPassword:
      return MaterialPageRoute(
        builder: (_) => MainLayout(
          currentRoute: RouteNames.forgotPassword,
          child: const ForgotPasswordScreen(),
        ),
      );

    case RouteNames.newsDetail:
      final article = settings.arguments as ArticleModel;

      return MaterialPageRoute(
        builder: (_) => MainLayout(
          currentRoute: RouteNames.newsDetail,
          child: NewsDetailScreen(article: article),
        ),
      );

    case RouteNames.profile:
      return MaterialPageRoute(
        builder: (_) => MainLayout(
          currentRoute: RouteNames.profile,
          child: const ProfileScreen(),
        ),
      );

    case RouteNames.favorites:
      return MaterialPageRoute(
        builder: (_) => MainLayout(
          currentRoute: RouteNames.favorites,
          child: const FavoritesScreen(),
        ),
      );

    case RouteNames.search:
      return MaterialPageRoute(
        builder: (_) => MainLayout(
          currentRoute: RouteNames.search,
          child: const SearchScreen(),
        ),
      );

    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(child: Text('Không tìm thấy trang: ${settings.name}')),
        ),
      );
  }
}
