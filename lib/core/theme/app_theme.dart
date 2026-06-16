// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _primaryColor = Color(0xFF004625);
  static const _secondaryColor = Color(0xFFFCBF48);
  static const _errorColor = Color(0xFFE02424);
  static const _surfaceColor = Color(0xFFF8FAF7);
  static const _cardColor = Colors.white;

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        secondary: _secondaryColor,
        error: _errorColor,
        surface: _surfaceColor,
      ),
      scaffoldBackgroundColor: _surfaceColor,
      cardColor: _cardColor,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF111827),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF111827),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          side: const BorderSide(color: _primaryColor, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEFF6FF),
        labelStyle: const TextStyle(
          color: _primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static const Color statusSuccess = Color(0xFF0E9F6E);
  static const Color statusFailed = Color(0xFFE02424);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusProcessing = Color(0xFF1A56DB);
}
