import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFF83B46); // Pure Red
  static const Color secondaryColor = Color(0xFFFA6A73); // Lighter Red
  static const Color backgroundColorLight = Colors.white;
  static const Color backgroundColorDark = Color(0xFF121212);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color darkGrey = Color(0xFF303030);
  static const Color textColorLight = Colors.black87;
  static const Color textColorDark = Colors.white;

  static const TextStyle _baseTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle _headingTextStyle = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static ThemeData lightTheme = ThemeData(
    canvasColor: Colors.white,
    dialogBackgroundColor: Colors.white,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColorLight,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColorLight,
      foregroundColor: textColorLight,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _headingTextStyle.copyWith(color: textColorLight),
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      shadowColor: Colors.black12,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: backgroundColorLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.black54,
      elevation: 4,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(primaryColor),
      trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? secondaryColor : Colors.grey,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        iconColor: Colors.white,
        textStyle: _baseTextStyle.copyWith(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: _baseTextStyle.copyWith(fontWeight: FontWeight.w500),
        side: BorderSide(color: primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: _baseTextStyle.copyWith(fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightGrey,
      hintStyle: TextStyle(color: Colors.black54),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryColor,
      linearTrackColor: Colors.grey[300],
      circularTrackColor: Colors.grey[300],
    ),
    expansionTileTheme: ExpansionTileThemeData(
      collapsedBackgroundColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      iconColor: primaryColor,
      collapsedIconColor: Colors.black,
    ),
    tabBarTheme: TabBarTheme(
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: primaryColor, width: 3),
      ),
      labelColor: primaryColor,
      unselectedLabelColor: Colors.grey[600],
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColorDark,
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColorDark,
      foregroundColor: textColorDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: _headingTextStyle.copyWith(color: textColorDark),
    ),
    cardTheme: CardTheme(
      color: darkGrey,
      shadowColor: Colors.black54,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
    ),
    dialogTheme: DialogTheme(
      backgroundColor: backgroundColorDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkGrey,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.white54,
      elevation: 4,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(primaryColor),
      trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected) ? secondaryColor : Colors.grey,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        iconColor: Colors.white,
        textStyle: _baseTextStyle.copyWith(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: _baseTextStyle.copyWith(fontWeight: FontWeight.w500),
        side: BorderSide(color: primaryColor, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: _baseTextStyle.copyWith(fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkGrey,
      hintStyle: TextStyle(color: Colors.white60),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryColor, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[600]!),
        borderRadius: BorderRadius.circular(10),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[600]!),
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryColor,
      linearTrackColor: Colors.grey[300],
      circularTrackColor: Colors.grey[300],
    ),
    expansionTileTheme: ExpansionTileThemeData(
      collapsedBackgroundColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      iconColor: primaryColor,
      collapsedIconColor: Colors.white,
    ),
    tabBarTheme: TabBarTheme(
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: primaryColor, width: 3),
      ),
      labelColor: primaryColor,
      unselectedLabelColor: Colors.grey[600],
    ),
  );
}