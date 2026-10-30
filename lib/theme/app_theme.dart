import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ---- COLORS — replace values with tokens from your src/index.css ----
  static const Color primary    = Color(0xFF111827);
  static const Color gold       = Color(0xFFD4AF37);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color textMuted  = Color(0xFF6B7280);
  static const Color border     = Color(0xFFE5E7EB);
  static const Color success    = Color(0xFF16A34A);
  static const Color danger     = Color(0xFFDC2626);

  // ---- SPACING (Tailwind-equivalent scale) ----
  static const double s4  = 4;
  static const double s8  = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s24 = 24;
  static const double s32 = 32;

  // ---- RADIUS ----
  static const double rMd = 12;
  static const double rLg = 16;
  static const double rPill = 999;

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
          surface: surface,
        ),
        scaffoldBackgroundColor: background,
        textTheme: const TextTheme(
          displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700, height: 1.2),
          headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1.3),
          titleLarge:    TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          bodyLarge:     TextStyle(fontSize: 16, height: 1.5),
          bodyMedium:    TextStyle(fontSize: 14, height: 1.5),
          labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: surface,
          foregroundColor: primary,
          elevation: 0,
          centerTitle: true,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(rMd),
            ),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          contentPadding: const EdgeInsets.symmetric(horizontal: s16, vertical: s16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rMd),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rMd),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(rMd),
            borderSide: const BorderSide(color: primary, width: 1.5),
          ),
        ),
        dividerTheme: const DividerThemeData(color: border, thickness: 1),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rLg),
            side: const BorderSide(color: border),
          ),
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.dark,
        ),
      );
}