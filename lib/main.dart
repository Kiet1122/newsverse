import 'package:flutter/material.dart';
import 'package:newsverse/features/auth/screens/login_screen.dart';
import 'package:newsverse/features/home/home_provider.dart';
import 'package:newsverse/features/home/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/app_provider.dart';
import 'features/auth/auth_provider.dart';
import 'core/services/api/news_api_service.dart';
import 'core/services/firebase/firestore_service.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppProvider()),
        ChangeNotifierProvider(
          create: (context) => AuthProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeProvider(
            newsApiService: NewsApiService(),
            firestoreService: FirestoreService(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'NewsVerse',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const AuthWrapper(), 
        onGenerateRoute: generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.isInitializing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang khởi tạo...'),
            ],
          ),
        ),
      );
    }

    if (authProvider.user == null) {
      return const LoginScreen();
    }

    return const HomeScreen();
  }
}
