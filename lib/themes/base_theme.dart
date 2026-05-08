import 'package:flutter/material.dart';
import 'package:project_habits/themes/purple_green.dart';
import 'package:project_habits/themes/orange_blue.dart';
import 'package:project_habits/themes/yellow_blue.dart';

const Color WHITE = Colors.white;
const Color BWHITE = Color(0xffF7F7F7);
const Color GREY = Color(0xFFE6E6EA);
const Color BGREY = Color(0xFF404040);
const Color BLACK = Color(0xFF313131);
const Color BBLACK = Color(0xFF000000);

enum ThemeColors { yellowBlue, purpleGreen, orangeBlue }

List<Color> getColors(ThemeColors color) {
  switch (color) {
    case ThemeColors.yellowBlue:
      return [YELLOW_BLUE_THEME.primary, YELLOW_BLUE_THEME.accent, YELLOW_BLUE_THEME.hightlight];
    case ThemeColors.purpleGreen:
      return [PURPLE_GREEN_THEME.primary, PURPLE_GREEN_THEME.accent, PURPLE_GREEN_THEME.hightlight];
    case ThemeColors.orangeBlue:
      return [ORANGE_BLUE_THEME.primary, ORANGE_BLUE_THEME.accent, ORANGE_BLUE_THEME.hightlight];
  }
}

// Perbaikan: Menggunakan ColorScheme untuk menggantikan accentColor dan primaryColor
getLightTheme(ThemeColors color) {
  final theme = lightTheme;
  switch (color) {
    case ThemeColors.yellowBlue:
      return theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: YELLOW_BLUE_THEME.primary,
          secondary: YELLOW_BLUE_THEME.accent,
        ),
        highlightColor: YELLOW_BLUE_THEME.hightlight,
      );
    case ThemeColors.purpleGreen:
      return theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: PURPLE_GREEN_THEME.primary,
          secondary: PURPLE_GREEN_THEME.accent,
        ),
        highlightColor: PURPLE_GREEN_THEME.hightlight,
      );
    case ThemeColors.orangeBlue:
      return theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: ORANGE_BLUE_THEME.primary,
          secondary: ORANGE_BLUE_THEME.accent,
        ),
        highlightColor: ORANGE_BLUE_THEME.hightlight,
      );
  }
}

getDarkTheme(ThemeColors color) {
  final theme = darkTheme;
  switch (color) {
    case ThemeColors.yellowBlue:
      return theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: YELLOW_BLUE_THEME.primary,
          secondary: YELLOW_BLUE_THEME.accent,
        ),
        highlightColor: YELLOW_BLUE_THEME.hightlight,
        hintColor: YELLOW_BLUE_THEME.accent,
      );
    case ThemeColors.purpleGreen:
      return theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: PURPLE_GREEN_THEME.primary,
          secondary: PURPLE_GREEN_THEME.accent,
        ),
        highlightColor: PURPLE_GREEN_THEME.hightlight,
        hintColor: PURPLE_GREEN_THEME.accent,
      );
    case ThemeColors.orangeBlue:
      return theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: ORANGE_BLUE_THEME.primary,
          secondary: ORANGE_BLUE_THEME.accent,
        ),
        highlightColor: ORANGE_BLUE_THEME.hightlight,
        hintColor: ORANGE_BLUE_THEME.accent,
      );
  }
}

final lightTheme = ThemeData(
  useMaterial3: false, // Menjaga tampilan tetap konsisten dengan desain lama
  scaffoldBackgroundColor: BWHITE,
  primaryColorLight: WHITE,
  primaryColorDark: BLACK,
  shadowColor: GREY,
  fontFamily: "Kodchasan",
  colorScheme: const ColorScheme.light(
    surface: BWHITE, // Menggantikan backgroundColor
    secondary: Colors.blue, // Placeholder, akan dioverwrite di switch-case
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: WHITE, fontSize: 28), // headline1
    displayMedium: TextStyle(color: BLACK, fontSize: 22, fontWeight: FontWeight.bold), // headline2
    displaySmall: TextStyle(color: BLACK, fontSize: 20), // headline3
    headlineMedium: TextStyle(color: WHITE, fontSize: 18), // headline4
    bodyMedium: TextStyle(color: BLACK, fontSize: 18), // bodyText2
    titleMedium: TextStyle(color: BLACK, fontSize: 12), // subtitle1
    titleSmall: TextStyle(color: BLACK, fontSize: 16), // subtitle2
    labelLarge: TextStyle(fontSize: 18, decoration: TextDecoration.underline), // button
  ),
  iconTheme: const IconThemeData(color: WHITE, size: 24),
);

final darkTheme = ThemeData(
  useMaterial3: false,
  scaffoldBackgroundColor: BBLACK,
  primaryColorLight: BLACK,
  primaryColorDark: WHITE,
  shadowColor: BGREY,
  fontFamily: "Kodchasan",
  unselectedWidgetColor: WHITE,
  colorScheme: const ColorScheme.dark(
    surface: BLACK, // Menggantikan backgroundColor
    secondary: Colors.blue, 
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: WHITE, fontSize: 28),
    displayMedium: TextStyle(color: WHITE, fontSize: 22, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(color: WHITE, fontSize: 20),
    headlineMedium: TextStyle(color: WHITE, fontSize: 18),
    bodyMedium: TextStyle(color: WHITE, fontSize: 18),
    titleMedium: TextStyle(color: WHITE, fontSize: 12),
    titleSmall: TextStyle(color: WHITE, fontSize: 16),
    labelLarge: TextStyle(fontSize: 18, decoration: TextDecoration.underline),
  ),
  iconTheme: const IconThemeData(color: WHITE, size: 24),
);