import 'package:flutter/material.dart';
import '../routes/route_names.dart';
import '../features/home/screens/home_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/news/screens/news_detail_screen.dart';
import '../models/article_model.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case RouteNames.home:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case RouteNames.login:
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    case RouteNames.register:
      return MaterialPageRoute(builder: (_) => const RegisterScreen());
    case RouteNames.forgotPassword:
      return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
    case RouteNames.newsDetail:
      final article = settings.arguments as ArticleModel;
      return MaterialPageRoute(
        builder: (_) => NewsDetailScreen(article: article),
      );
    default:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
  }
}