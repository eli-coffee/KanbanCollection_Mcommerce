import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Estimated from the mockup. Replace with exact values from Figma.
class AppColors {
  static const background = Color(0xFFD6D6D6);
  static const card = Color(0xFFFAFAFA);
  static const navy = Color(0xFF14233B);
  static const ink = Color(0xFF1B1F23);
  static const purple = Color(0xFF5B2D6B);
  static const indigo = Color(0xFF4D4690);
  static const blue = Color(0xFF2F489C);
  static const yellow = Color(0xFFFFE79A);
  static const preorder = Color(0xFFFFE082);
  static const link = Color(0xFF2F6BFF);
}

class AppText {
  /// Stencil-style display font for titles and buttons (closest match I found).
  static TextStyle display({double size = 22, Color color = Colors.black}) =>
      GoogleFonts.sairaStencilOne(fontSize: size, color: color);
}

class AppTheme {
  static ThemeData get light {
    final base =
        ThemeData(useMaterial3: true, colorSchemeSeed: AppColors.indigo);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.karlaTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        centerTitle: true,

        
      ),
    );
  }

    static ThemeData get dark {
    final base = ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: AppColors.indigo);
    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF14161B),
      textTheme: GoogleFonts.karlaTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF14161B),
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
    );
  }
}