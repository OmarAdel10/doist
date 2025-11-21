import 'package:doist/shared/font_manager.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const Color lightModePrimary = Color(0xFFFFFFFF);
  static const Color lightModeSecondry = Color(0xFF1570FF);
  static const Color lightModeBlack = Color(0xFF121217);
  static const Color lightModeLightGrey = Color(0xFF9AA0A6);
  static const Color lightModeTextGrey = Color(0xFF6B7380);
  static const Color lightModeLoadingTextGrey = Color(0xFF3C3C43);
  static const Color lightModeDividerGrey = Color(0xFFE6E9EE);
  static const Color lightModeFormAndCheckBoxGrey = Color(0xFFDBDEE5);
  static const Color lightModeDialogBackground = Color(0xFF090909);

  static const Color darkModePrimary = Color(0xFF0B0D0F);
  static const Color darkModeSecondry = Color(0xFF1570FF);
  static const Color darkModeWhite = Color(0xFFFFFFFF);
  static const Color darkModeLightGrey = Color(0xFF9AA0A6);
  static const Color darkModeTextGrey = Color(0xFF61708A);
  static const Color darkModeTextFieldBackGroundGrey = Color(0xFF292E38);
  static const Color darkModeLoadingTextGrey = Color(0xFFBFBFBF);
  static const Color darkModeDividerGrey = Color(0xFFE6E9EE);
  static const Color darkModeFormAndCheckBoxGrey = Color(0xFF9EA6BA);

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: lightModePrimary,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: lightModeBlack,
        fontSize: FontManager.f18,
        fontWeight: FontManager.bold,
      ),
      backgroundColor: lightModePrimary,
      elevation: 0,
      actionsIconTheme: IconThemeData(color: lightModeBlack),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightModeFormAndCheckBoxGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightModeFormAndCheckBoxGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: lightModeFormAndCheckBoxGrey),
      ),
    ),

    textTheme: TextTheme(
      headlineMedium: TextStyle(
        fontSize: FontManager.f28,
        fontWeight: FontManager.bold,
        color: lightModeBlack
      ),
      headlineSmall: TextStyle(
        fontSize: FontManager.f16,
        fontWeight: FontManager.bold,
        color: lightModePrimary,
      ),
      titleLarge: TextStyle(
        fontSize: FontManager.f18,
        fontWeight: FontManager.semiBold,
        color: lightModeBlack,
      ),
      titleMedium: TextStyle(
        fontSize: FontManager.f16,
        fontWeight: FontManager.medium,
        color: lightModeBlack,
      ),
      titleSmall: TextStyle(
        fontSize: FontManager.f14,
        fontWeight: FontManager.regular,
        color: lightModeTextGrey,
      ),
      labelLarge: TextStyle(
        fontSize: FontManager.f16,
        fontWeight: FontManager.semiBold,
        color: lightModeBlack,
      ),
      labelMedium: TextStyle(
        fontSize: FontManager.f14,
        fontWeight: FontManager.semiBold,
        color: lightModeBlack,
      ),
      labelSmall: TextStyle(
        fontSize: FontManager.f16,
        fontWeight: FontManager.regular,
        color: lightModeBlack,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: darkModePrimary,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: darkModeWhite,
        fontSize: FontManager.f18,
        fontWeight: FontManager.bold,
      ),
      backgroundColor: darkModePrimary,
      elevation: 0,
      actionsIconTheme: IconThemeData(color: darkModeWhite),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkModeTextFieldBackGroundGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: darkModeLightGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: darkModeLightGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: darkModeLightGrey),
      ),
    ),

    textTheme: TextTheme(
      titleLarge: TextStyle(
        fontSize: FontManager.f18,
        fontWeight: FontManager.semiBold,
        color: lightModeBlack,
      ),
      titleMedium: TextStyle(
        fontSize: FontManager.f16,
        fontWeight: FontManager.medium,
        color: lightModeBlack,
      ),
      titleSmall: TextStyle(
        fontSize: FontManager.f14,
        fontWeight: FontManager.regular,
        color: lightModeTextGrey,
      ),
      labelLarge: TextStyle(
        fontSize: FontManager.f16,
        fontWeight: FontManager.semiBold,
        color: lightModeBlack,
      ),
      labelMedium: TextStyle(
        fontSize: FontManager.f14,
        fontWeight: FontManager.semiBold,
        color: lightModeBlack,
      ),
    ),
  );
}
