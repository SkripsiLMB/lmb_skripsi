import 'package:flutter/material.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';

final ThemeData lmbLightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: LmbColors.backgroundLow,
  appBarTheme: AppBarTheme(
    backgroundColor: LmbColors.backgroundLow,
    foregroundColor: LmbColors.textHigh,
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: LmbColors.textHigh,
    ),
    centerTitle: false
  ),
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: LmbColors.brand,
    onPrimary: Colors.white,
    secondary: LmbColors.textLow,
    onSecondary: Colors.white,
    background: LmbColors.backgroundLow,
    onBackground: LmbColors.textHigh,
    surface: LmbColors.backgroundHigh,
    onSurface: LmbColors.textHigh,
    error: LmbColors.error,
    onError: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: LmbColors.textHigh),
    bodyMedium: TextStyle(color: LmbColors.textLow),
    bodySmall: TextStyle(color: LmbColors.textLow),
    labelSmall: TextStyle(color: LmbColors.textMid, fontSize: 12),
    labelMedium: TextStyle(color: LmbColors.textMid, fontWeight: FontWeight.w600, fontSize: 18),
    labelLarge: TextStyle(color: LmbColors.textMid, fontWeight: FontWeight.bold, fontSize: 18),
    titleLarge: TextStyle(fontWeight: FontWeight.bold, color: LmbColors.textHigh),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: LmbColors.backgroundHigh,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    hintStyle: TextStyle(color: LmbColors.textLow),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: LmbColors.brand,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return LmbColors.brand;
      }
      return LmbColors.backgroundHigh;
    }),
    checkColor: MaterialStateProperty.all(Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    side: BorderSide(
      width: 1, 
      color: LmbColors.backgroundHigh
    ),
  ),
);

final ThemeData lmbDarkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: LmbColors.darkBackgroundLow,
  appBarTheme: AppBarTheme(
    backgroundColor: LmbColors.darkBackgroundLow,
    foregroundColor: LmbColors.darkTextHigh,
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16, 
      color: LmbColors.darkTextHigh,
    ),
    centerTitle: false
  ),
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: LmbColors.brand,
    onPrimary: Colors.white,
    secondary: LmbColors.darkTextLow,
    onSecondary: Colors.white,
    background: LmbColors.darkBackgroundLow,
    onBackground: LmbColors.darkTextHigh,
    surface: LmbColors.darkBackgroundHigh,
    onSurface: LmbColors.darkTextHigh,
    error: LmbColors.error,
    onError: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: LmbColors.darkTextHigh),
    bodyMedium: TextStyle(color: LmbColors.darkTextLow),
    bodySmall: TextStyle(color: LmbColors.darkTextLow),
    labelSmall: TextStyle(color: LmbColors.darkTextMid, fontSize: 12),
    labelMedium: TextStyle(color: LmbColors.darkTextMid, fontWeight: FontWeight.w600, fontSize: 18),
    labelLarge: TextStyle(color: LmbColors.darkTextMid, fontWeight: FontWeight.bold, fontSize: 18),
    titleLarge: TextStyle(fontWeight: FontWeight.bold, color: LmbColors.darkTextHigh),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: LmbColors.darkBackgroundHigh,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    hintStyle: TextStyle(color: LmbColors.darkTextLow),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: LmbColors.brand,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateProperty.resolveWith<Color>((states) {
      if (states.contains(MaterialState.selected)) {
        return LmbColors.brand;
      }
      return LmbColors.darkBackgroundHigh;
    }),
    checkColor: MaterialStateProperty.all(Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    side: BorderSide(
      width: 1, 
      color: LmbColors.darkBackgroundHigh
    ),
  )
);