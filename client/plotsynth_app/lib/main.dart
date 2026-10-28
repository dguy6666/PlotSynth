import 'package:flutter/material.dart';
import 'views/library/library_view.dart';
import 'themes/app_themes.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PlotSynthApp());
}

class PlotSynthApp extends StatelessWidget {
  const PlotSynthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlotSynth',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.slateDark,
      home: const LibraryView(),
    );
  }
}

// basically complete