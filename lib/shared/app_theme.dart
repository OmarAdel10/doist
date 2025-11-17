import 'package:doist/shared/font_manager.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static const Color lightModePrimary = Color(0xFFFFFFFF);
  static const Color lightModeSecondry = Color(0xFF125CED);
  static const Color lightModeBlack = Color(0xFF121217);
  static const Color lightModeLightGrey = Color(0xFF9AA0A6);
  static const Color lightModeTextGrey = Color(0xFF61708A);
  static const Color lightModeBackGroundGrey = Color(0xFFF0F2F5);
  static const Color lightModeLoadingTextGrey = Color(0xFF3C3C43);
  static const Color lightModeDividerGrey = Color(0xFFE6E9EE);
  static const Color lightModeFormAndCheckBoxGrey = Color(0xFFDBDEE5);

  static const Color darkModePrimary = Color(0xFF0B0D0F);
  static const Color darkModeSecondry = Color(0xFF125CED);
  static const Color darkModeWhite = Color(0xFFFFFFFF);
  static const Color darkModeLightGrey = Color(0xFF9AA0A6);
  static const Color darkModeTextGrey = Color(0xFF61708A);
  static const Color darkModeContainerBackGroundGrey = Color(0xFF292E38);
  static const Color darkModeLoadingTextGrey = Color(0xFFBFBFBF);
  static const Color darkModeDividerGrey = Color(0xFFE6E9EE);

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
  );
}
