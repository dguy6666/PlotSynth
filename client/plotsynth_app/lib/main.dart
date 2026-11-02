import 'package:flutter/material.dart';
import 'package:plotsynth_app/services/database_service.dart';
import 'views/library/library_view.dart';
import 'themes/app_themes.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final db = await DatabaseService.instance.database;
    // אם db מטיפוס Database של sqlite3, ניתן לבדוק רישום בפועל:
    debugPrint("DATABASE CREATED SUCCESSFULLY!");
    
    // שאילתת בדיקה לוודא שהטבלאות קיימות פיזית
    final tables = db.select("SELECT name FROM sqlite_master WHERE type='table';");
    debugPrint("TABLES IN DB: ${tables.map((r) => r['name']).toList()}");
  } catch (e, stack) {
    debugPrint("DATABASE INIT ERROR: $e");
    debugPrint("STACK TRACE: $stack");
  }
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