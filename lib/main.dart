import 'package:flutter/material.dart';
import 'package:newsverse/features/bookmark/bookmark_provider.dart';
import 'package:newsverse/features/home/home_provider.dart';
import 'package:newsverse/features/profile/profile_provider.dart';
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
        ChangeNotifierProvider(create: (context) => BookmarkProvider()),
        ChangeNotifierProvider(create: (context) => ProfileProvider()),
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