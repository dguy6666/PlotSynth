import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const PlotSynthApp());
}

class PlotSynthApp extends StatelessWidget {
  const PlotSynthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Main Page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF7EB),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF6C995)),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}
