// lib/theme/app_themes.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

enum AppThemeMode {
  sepia,
  slateDark,
  // Add more enum names here whenever you create new themes
}

class AppThemes {
  AppThemes._();

  // -------------------------------------------------------------
  // 1. SEPIA THEME PALETTE
  // -------------------------------------------------------------
  static const sepiaColors = AppColors(
    background: Color(0xFFF4EFE6),
    surface: Color(0xFFFAF7F2),
    addCardSurface: Color(0xFFEAE2D5),
    accentTitle: Color(0xFF4A2E1B),
    textRegular: Color(0xFF1F1A17),
    textDescription: Color(0xFF5A524C),
    textMuted: Color(0xFF8C827A),
    outline: Color(0xFFD9CEBF),
  );

  // -------------------------------------------------------------
  // 2. SLATE DARK THEME PALETTE (Example to demonstrate swapping)
  // -------------------------------------------------------------
  static const slateDarkColors = AppColors(
    background: Color(0xFF16181D),
    surface: Color(0xFF21242C),
    addCardSurface: Color(0xFF2A2E39),
    accentTitle: Color(0xFF64B5F6),
    textRegular: Color(0xFFECEFF4),
    textDescription: Color(0xFFA0A8B7),
    textMuted: Color(0xFF6B7280),
    outline: Color(0xFF333846),
  );

  // -------------------------------------------------------------
  // CENTRAL BUILDER: Turns any AppColors into a full ThemeData
  // -------------------------------------------------------------
  static ThemeData buildTheme(AppColors colors, {Brightness brightness = Brightness.light}) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: colors.background,
      extensions: [colors], // Registers custom colors

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colors.accentTitle),
        actionsIconTheme: IconThemeData(color: colors.accentTitle),
        titleTextStyle: TextStyle(
          color: colors.accentTitle,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
      ),

      // Project Cards
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.outline, width: 0.8),
        ),
      ),

      // Search Bar
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(colors.surface),
        elevation: const WidgetStatePropertyAll(0.5),
        hintStyle: WidgetStatePropertyAll(TextStyle(color: colors.textMuted, fontSize: 14)),
        textStyle: WidgetStatePropertyAll(TextStyle(color: colors.textRegular, fontSize: 14)),
        side: WidgetStatePropertyAll(BorderSide(color: colors.outline, width: 0.8)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),

      // Filter / Choice Chips
      chipTheme: ChipThemeData(
        backgroundColor: colors.surface,
        selectedColor: colors.addCardSurface,
        labelStyle: TextStyle(color: colors.textRegular, fontSize: 13, fontWeight: FontWeight.w500),
        secondaryLabelStyle: TextStyle(color: colors.accentTitle, fontSize: 13, fontWeight: FontWeight.w600),
        side: BorderSide(color: colors.outline, width: 0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        iconTheme: IconThemeData(color: colors.accentTitle, size: 16),
      ),

      // Text Styles
      textTheme: TextTheme(
        headlineSmall: TextStyle(color: colors.accentTitle, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: colors.accentTitle, fontWeight: FontWeight.w600, fontSize: 16),
        bodyMedium: TextStyle(color: colors.textRegular, fontSize: 14, height: 1.4),
        bodySmall: TextStyle(color: colors.textDescription, fontSize: 13),
        labelSmall: TextStyle(color: colors.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
      ),

      dividerTheme: DividerThemeData(color: colors.outline, thickness: 0.8),
    );
  }

  // Pre-configured theme getters ready for MaterialApp:
  static ThemeData get sepia => buildTheme(sepiaColors, brightness: Brightness.light);
  static ThemeData get slateDark => buildTheme(slateDarkColors, brightness: Brightness.dark);
}