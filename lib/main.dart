import 'package:flutter/material.dart';
import 'package:newsverse/core/services/firebase/comment_service.dart';
import 'package:newsverse/features/bookmark/bookmark_provider.dart';
import 'package:newsverse/features/home/home_provider.dart';
import 'package:newsverse/features/profile/profile_provider.dart';
import 'package:newsverse/models/ArticleRepository.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/app_provider.dart';
import 'features/auth/auth_provider.dart';
import 'core/services/api/news_api_service.dart';
import 'core/services/firebase/firestore_service.dart';
import 'routes/app_routes.dart';
import 'routes/route_names.dart';

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
        // ================== SERVICES ==================
        Provider(create: (_) => NewsApiService()),
        Provider(create: (_) => FirestoreService()),
        Provider(create: (_) => CommentService()),

        // ================== REPOSITORY ==================
        ProxyProvider2<NewsApiService, FirestoreService, ArticleRepository>(
          update: (_, api, firestore, _) => ArticleRepository(
            newsApiService: api,
            firestoreService: firestore,
          ),
        ),

        // ================== STATE PROVIDERS ==================
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => BookmarkProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),

        ChangeNotifierProvider(
          create: (context) => HomeProvider(
            newsApiService: context.read<NewsApiService>(),
            firestoreService: context.read<FirestoreService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'NewsVerse',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        initialRoute: RouteNames.splash,
        onGenerateRoute: generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
