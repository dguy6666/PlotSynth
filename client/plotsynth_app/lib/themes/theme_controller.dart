import 'package:flutter/material.dart';
import 'app_themes.dart';

class ThemeController {
  // Holds the active ThemeData across the whole app
  static final ValueNotifier<ThemeData> currentTheme =
      ValueNotifier<ThemeData>(AppThemes.sepia);

  static void setTheme(ThemeData theme) {
    currentTheme.value = theme;
  }
}