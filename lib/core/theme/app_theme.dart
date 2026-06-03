import 'package:flutter/material.dart';

class AppColors {
  // Zinc palette — mirrors the Laravel web app
  static const Color primaryDark   = Color(0xFF171717); // zinc-900
  static const Color surfaceLight  = Color(0xFFFAFAFA); // zinc-50
  static const Color accent        = Color(0xFF262626); // neutral-800
  static const Color textPrimary   = Color(0xFF171717); // zinc-900
  static const Color textSecondary = Color(0xFF737373); // zinc-500
  static const Color border        = Color(0xFFE5E5E5); // zinc-200
  static const Color disabled      = Color(0xFFA3A3A3); // zinc-400
  static const Color white         = Color(0xFFFFFFFF);

  // Semantic status colours
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color danger  = Color(0xFFDC2626);
  static const Color info    = Color(0xFF2563EB);
  static const Color neutral = Color(0xFF737373);

  static Color fromLabel(String color) {
    switch (color.toLowerCase()) {
      case 'green':
        return success;
      case 'red':
        return danger;
      case 'yellow':
      case 'amber':
      case 'orange':
        return warning;
      case 'blue':
        return info;
      default:
        return neutral;
    }
  }
}

class AppTheme {
  static ThemeData get light => ThemeData(
        colorSchemeSeed: AppColors.primaryDark,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.surfaceLight,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: AppColors.white),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.primaryDark,
          selectedItemColor: AppColors.white,
          unselectedItemColor: AppColors.disabled,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: AppColors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.accent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          hintStyle: const TextStyle(color: AppColors.disabled),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            foregroundColor: AppColors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.accent),
        ),
        dividerTheme: const DividerThemeData(color: AppColors.border, space: 1, thickness: 1),
        listTileTheme: const ListTileThemeData(
          tileColor: AppColors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
        chipTheme: ChipThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        ),
      );
}
