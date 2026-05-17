import 'package:flutter/material.dart';
import 'screens/main_navigation.dart'; // IMPORT THE NEW WRAPPER

void main() {
  runApp(const MagicWeatherApp());
}

class MagicWeatherApp extends StatelessWidget {
  const MagicWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Magic Weather AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.dark, 
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Premium deep slate background
      ),
      home: const MainNavigation(), // LAUNCH THE WRAPPER FIRST
    );
  }
}