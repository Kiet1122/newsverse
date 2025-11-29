import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../../routes/route_names.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  /// Check user authentication status and navigate accordingly
  void _checkAuthStatus() async {
    final authProvider = context.read<AuthProvider>();
    
    // Wait for auth provider to finish initialization
    await Future.delayed(const Duration(milliseconds: 1000));
    
    if (mounted) {
      if (authProvider.user != null) {
        Navigator.pushReplacementNamed(context, RouteNames.home);
      } else {
        Navigator.pushReplacementNamed(context, RouteNames.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(size: 100),
            const SizedBox(height: 20),
            const Text(
              'NewsVerse',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(
              color: Colors.blue[700],
            ),
          ],
        ),
      ),
    );
  }
}