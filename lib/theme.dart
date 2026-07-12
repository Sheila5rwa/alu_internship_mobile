import 'package:flutter/material.dart';

class AluTheme {
  // Color Palette
  static const Color primaryMaroon = Color(0xFF8C1D40); 
  static const Color secondaryGold = Color(0xFFFFC627); 
  static const Color darkSlate = Color(0xFF1E242B);      
  static const Color backgroundGrey = Color(0xFFF6F8FB);  
  static const Color accentSpruce = Color(0xFF0F5A47);   
  static const Color borderGrey = Color(0xFFE2E8F0);
  static const Color cardShadow = Color(0x0A0F172A);

  // Gradient definitions
  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryMaroon, Color(0xFFAC2652)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient goldSpruceGradient = LinearGradient(
    colors: [secondaryGold, Color(0xFFE5B518)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient spruceGradient = LinearGradient(
    colors: [accentSpruce, Color(0xFF157A62)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryMaroon,
        primary: primaryMaroon,
        secondary: secondaryGold,
        tertiary: accentSpruce,
        surface: backgroundGrey,
        onSurface: darkSlate,
      ),
      scaffoldBackgroundColor: backgroundGrey,
      cardColor: Colors.white,
      
      // Fine-tuning text themes
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: darkSlate,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkSlate,
          letterSpacing: -0.3,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: darkSlate,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          color: darkSlate,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: Color(0xFF64748B),
        ),
      ),
 
      // Input Decoration Styles
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderGrey, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderGrey, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryMaroon, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        floatingLabelStyle: const TextStyle(color: primaryMaroon, fontWeight: FontWeight.bold),
      ),
 
      // Button Styles
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryMaroon,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ),
 
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryMaroon,
          side: const BorderSide(color: primaryMaroon, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
 
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryMaroon,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
 
      
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderGrey, width: 1),
        ),
        color: Colors.white,
        margin: EdgeInsets.zero,
      ),
 
      
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primaryMaroon.withAlpha(26), // 10% opacity
        height: 65,
        elevation: 10,
        shadowColor: Colors.black.withAlpha(51), // 20% opacity
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: primaryMaroon, fontWeight: FontWeight.bold, fontSize: 12);
          }
          return const TextStyle(color: Color(0xFF64748B), fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryMaroon, size: 24);
          }
          return const IconThemeData(color: Color(0xFF64748B), size: 24);
        }),
      ),

      
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: darkSlate,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkSlate,
        ),
      ),
    );
  }
}
