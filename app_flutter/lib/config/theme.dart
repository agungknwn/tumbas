import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class AppTheme {
  static Color primaryColor = Vx.black;
  static Color secondaryColor = Vx.white;
  static Color tertiaaryColor = const Color(0xFFee5396);
  static Color darkBackgroundColor = Vx.gray900;

  static ThemeData lightTheme(BuildContext context) => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    // primaryColor: primaryColor,
    // colorScheme: ColorScheme(
    //   // seedColor: primaryColor,
    //   brightness: Brightness.light,
    //   primary: primaryColor,
    //   onPrimary: Colors.white,
    //   secondary: secondaryColor,
    //   onSecondary: Vx.blue700,
    //   surface: Colors.white,
    //   onSurface: Vx.gray900,
    //   error: Vx.red500,
    //   onError: Colors.white,
    // ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaaryColor,
      surface: Colors.white,
      error: Vx.red500,
    ),
    cardColor: Colors.white,
    fontFamily: 'Poppins',
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: primaryColor),
    ),
  );

  // Dark theme
  static ThemeData darkTheme(BuildContext context) => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    // primaryColor: primaryColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.grey,
      error: Vx.red500,
    ),
    canvasColor: darkBackgroundColor,
    cardColor: Vx.gray800,
    appBarTheme: AppBarTheme(
      backgroundColor: darkBackgroundColor,
      elevation: 0,
    ),
  );
}
