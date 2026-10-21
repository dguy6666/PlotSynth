// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;             // Project cards, search bar, buttons
  final Color addCardSurface;      // "Add New" card surface
  final Color accentTitle;         // Titles ("Projects", project name), icons
  final Color textRegular;         // Standard readable body text
  final Color textDescription;     // Secondary description text
  final Color textMuted;           // Versions, dates, timestamps
  final Color outline;             // Borders and dividers

  const AppColors({
    required this.background,
    required this.surface,
    required this.addCardSurface,
    required this.accentTitle,
    required this.textRegular,
    required this.textDescription,
    required this.textMuted,
    required this.outline,
  });

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? addCardSurface,
    Color? accentTitle,
    Color? textRegular,
    Color? textDescription,
    Color? textMuted,
    Color? outline,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      addCardSurface: addCardSurface ?? this.addCardSurface,
      accentTitle: accentTitle ?? this.accentTitle,
      textRegular: textRegular ?? this.textRegular,
      textDescription: textDescription ?? this.textDescription,
      textMuted: textMuted ?? this.textMuted,
      outline: outline ?? this.outline,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      addCardSurface: Color.lerp(addCardSurface, other.addCardSurface, t)!,
      accentTitle: Color.lerp(accentTitle, other.accentTitle, t)!,
      textRegular: Color.lerp(textRegular, other.textRegular, t)!,
      textDescription: Color.lerp(textDescription, other.textDescription, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
    );
  }
}

// Convenient context accessor: context.colors.accentTitle
extension AppColorsExtension on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}