import 'package:flutter/material.dart';

/// Paleta y tipografía alineadas al prototipo Figma (Screen1_Feed).
abstract final class NodoColors {
  static const Color primary = Color(0xFF5B4CDB);
  static const Color primaryDark = Color(0xFF3F2FB5);
  static const Color primarySoft = Color(0xFF8B7CF0);
  static const Color primaryMuted = Color(0xFFE8E4FF);
  static const Color background = Color(0xFFF7F6FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B6B80);
  static const Color chipInactive = Color(0xFFF0EEF5);
  static const Color chipBorder = Color(0xFFE2DFEC);
  static const Color navInactive = Color(0xFF9A98B0);
}

ThemeData buildNodoTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: NodoColors.primary,
      primary: NodoColors.primary,
      surface: NodoColors.surface,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: NodoColors.background,
    fontFamily: 'Segoe UI',
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: NodoColors.textPrimary,
      displayColor: NodoColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: NodoColors.background,
      foregroundColor: NodoColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
  );
}
