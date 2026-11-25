import 'package:flutter/material.dart';

import 'config/app_theme.dart';
import 'repositories/local_storage_repository.dart';
import 'views/home_screen.dart';
import 'views/search_screen.dart';

/// Entry point aplikasi WeatherApp.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageRepository.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/search': (context) => const SearchScreen(),
      },
    );
  }
}
