import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFF83B46); // Logo color
  static const Color secondaryColor = Color(0xFFFA737B); // Complementary color
  static const Color backgroundColorLight = Colors.white; // Light background
  static const Color backgroundColorDark = Color(0xFF1C1C1E); // Dark background

  static const TextStyle _baseTextStyle = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16,
    fontWeight: FontWeight.w400, // Reduced weight for sleeker text
    color: Colors.black,
  );

  static const TextStyle _headingTextStyle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w500, // Softer boldness for headings
    color: Colors.black,
  );

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColorLight,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColorLight,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _headingTextStyle.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 18
      )
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: _baseTextStyle.copyWith(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: _baseTextStyle.copyWith(fontWeight: FontWeight.w500),
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      onPrimary: Colors.white,
      surface: backgroundColorLight,
      onSurface: Colors.black,
    ),
    textTheme: TextTheme(
      displayLarge: _headingTextStyle.copyWith(fontSize: 42, color: Colors.black),
      displayMedium: _headingTextStyle.copyWith(fontSize: 36, color: Colors.black),
      displaySmall: _headingTextStyle.copyWith(fontSize: 30, color: Colors.black),
      headlineLarge: _headingTextStyle.copyWith(fontSize: 26, color: Colors.black),
      headlineMedium: _headingTextStyle.copyWith(fontSize: 22, color: Colors.black),
      headlineSmall: _headingTextStyle.copyWith(fontSize: 20, color: Colors.black),
      titleLarge: _baseTextStyle.copyWith(fontSize: 18),
      titleMedium: _baseTextStyle.copyWith(fontSize: 16),
      titleSmall: _baseTextStyle.copyWith(fontSize: 14),
      bodyLarge: _baseTextStyle.copyWith(fontSize: 16),
      bodyMedium: _baseTextStyle.copyWith(fontSize: 14),
      bodySmall: _baseTextStyle.copyWith(fontSize: 12),
      labelLarge: _baseTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: _baseTextStyle.copyWith(fontSize: 12),
      labelSmall: _baseTextStyle.copyWith(fontSize: 10),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: backgroundColorLight,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: _baseTextStyle.copyWith(fontWeight: FontWeight.w500),
      hintStyle: TextStyle(color: Colors.black54),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      collapsedBackgroundColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      iconColor: primaryColor,
      collapsedIconColor: Colors.black,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: _baseTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColorDark,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColorDark,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: _baseTextStyle.copyWith(fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: _baseTextStyle.copyWith(fontWeight: FontWeight.w500),
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      onPrimary: Colors.white,
      surface: backgroundColorDark,
      onSurface: Colors.white,
    ),
    textTheme: TextTheme(
      displayLarge: _headingTextStyle.copyWith(fontSize: 42, color: Colors.white),
      displayMedium: _headingTextStyle.copyWith(fontSize: 36, color: Colors.white),
      displaySmall: _headingTextStyle.copyWith(fontSize: 30, color: Colors.white),
      headlineLarge: _headingTextStyle.copyWith(fontSize: 26, color: Colors.white),
      headlineMedium: _headingTextStyle.copyWith(fontSize: 22, color: Colors.white),
      headlineSmall: _headingTextStyle.copyWith(fontSize: 20, color: Colors.white),
      titleLarge: _baseTextStyle.copyWith(fontSize: 18, color: Colors.white),
      titleMedium: _baseTextStyle.copyWith(fontSize: 16, color: Colors.white),
      titleSmall: _baseTextStyle.copyWith(fontSize: 14, color: Colors.white),
      bodyLarge: _baseTextStyle.copyWith(fontSize: 16, color: Colors.white),
      bodyMedium: _baseTextStyle.copyWith(fontSize: 14, color: Colors.white),
      bodySmall: _baseTextStyle.copyWith(fontSize: 12, color: Colors.white),
      labelLarge: _baseTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: _baseTextStyle.copyWith(fontSize: 12, color: Colors.white),
      labelSmall: _baseTextStyle.copyWith(fontSize: 10, color: Colors.white),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: backgroundColorDark,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: _baseTextStyle.copyWith(fontWeight: FontWeight.w500),
      hintStyle: TextStyle(color: Colors.white70),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[600]!),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      collapsedBackgroundColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      iconColor: primaryColor,
      collapsedIconColor: Colors.white,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: _baseTextStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
    ),
  );
}
