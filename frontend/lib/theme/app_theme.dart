import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Updated color palette
  static const Color primaryColor = Color(0xFFD24C9B); // #d24c9b
  static const Color secondaryColor = Color(0xFF662D91); // #662d91
  static const Color accentColor = Color(0xFFE8C1E0); // Light pink accent

  // Background colors
  static const Color scaffoldBackgroundColor = Color(0xFFFCF5F9);
  static const Color cardColor = Color(0xFFFFF9FD);

  // Text colors
  static const Color primaryTextColor = Color(0xFF2C3E50);
  static const Color secondaryTextColor = Color(0xFF7F8C8D);

  // Feature card colors
  static const Color nutritionCardColor = Color(0xFFF7E4EF);
  static const Color morningCardColor = Color(0xFFEDE2F4);
  static const Color weightCardColor = Color(0xFFE4F0F7);
  static const Color appointmentCardColor = Color(0xFFF0E4F7);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        background: scaffoldBackgroundColor,
      ),
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      cardColor: cardColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      textTheme: GoogleFonts.nunitoTextTheme(
        const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: primaryTextColor,
          ),
          headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: primaryTextColor,
          ),
          bodyLarge: TextStyle(fontSize: 16, color: primaryTextColor),
          bodyMedium: TextStyle(fontSize: 14, color: secondaryTextColor),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        hintStyle: const TextStyle(color: secondaryTextColor),
        labelStyle: const TextStyle(color: secondaryColor),
      ),
      iconTheme: const IconThemeData(
        color: secondaryColor,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }
}
