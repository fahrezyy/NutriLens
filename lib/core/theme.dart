import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors
  static const Color primary      = Color(0xFF00E5A0);
  static const Color primaryDark  = Color(0xFF00B87C);
  static const Color surface      = Color(0xFF111827);
  static const Color surfaceCard  = Color(0xFF1F2937);
  static const Color surfaceCard2 = Color(0xFF374151);
  static const Color onSurface    = Color(0xFFF9FAFB);
  static const Color onSurfaceSub = Color(0xFF9CA3AF);
  static const Color accent       = Color(0xFF34D399);
  static const Color error        = Color(0xFFEF4444);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color calorieColor = Color(0xFFFF6B6B);
  static const Color proteinColor = Color(0xFF4ECDC4);
  static const Color fatColor     = Color(0xFFFFE66D);
  static const Color carbColor    = Color(0xFF95E1D3);

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
        onSurface: onSurface,
        error: error,
      ),
      scaffoldBackgroundColor: surface,
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge  : TextStyle(color: onSurface, fontWeight: FontWeight.w700, fontSize: 32),
          displayMedium : TextStyle(color: onSurface, fontWeight: FontWeight.w700, fontSize: 26),
          titleLarge    : TextStyle(color: onSurface, fontWeight: FontWeight.w600, fontSize: 20),
          titleMedium   : TextStyle(color: onSurface, fontWeight: FontWeight.w600, fontSize: 16),
          bodyLarge     : TextStyle(color: onSurface, fontSize: 16),
          bodyMedium    : TextStyle(color: onSurfaceSub, fontSize: 14),
          labelLarge    : TextStyle(color: onSurface, fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: onSurface),
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: surface,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
