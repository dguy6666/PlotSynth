// import 'package:flutter/material.dart';
// import 'screens/main_screen.dart';

// void main() {
//   runApp(const PlotSynthApp());
// }

// class PlotSynthApp extends StatelessWidget {
//   const PlotSynthApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Main Page',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         scaffoldBackgroundColor: const Color(0xFFFFF7EB),
//         colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF6C995)),
//         useMaterial3: true,
//       ),
//       home: const MainScreen(),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

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
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF7EB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF6C995),
          surface: const Color(0xFFFFF7EB),
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          color: const Color(0xFFFADBB8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
           scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF2D241E),
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(color: Color(0xFF2D241E)),
        ),
      ),
      home: const MainScreen(),
    );
  }
}