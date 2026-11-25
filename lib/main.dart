import 'package:flutter/material.dart';

/// Entry point aplikasi WeatherApp.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
      ),
      home: const Scaffold(
        body: Center(
          child: Text('WeatherApp Setup'),
        ),
      ),
    );
  }
}
