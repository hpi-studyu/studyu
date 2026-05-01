import 'package:flutter/material.dart';

const primaryColor = Color(0xFF2196F3);
const accentColor = Color(0xFFFF9800);
const surfaceColor = Colors.white;
const scaffoldColor = Color(0xFFF5F7FA);

class ThemeConfig {
  static SliderThemeData coloredSliderTheme(ThemeData theme) => SliderThemeData(
    activeTrackColor: Colors.white.withValues(alpha: 0.4),
    inactiveTrackColor: Colors.white.withValues(alpha: 0),
  );
}

ThemeData get theme => ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: scaffoldColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 2,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
  ),
  cardTheme: const CardThemeData(
    color: surfaceColor,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  ),
  colorScheme:
      ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
      ).copyWith(
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF333333),
        surfaceContainerLowest: surfaceColor,
        surfaceContainerLow: scaffoldColor,
        surfaceContainer: scaffoldColor,
        surfaceContainerHigh: scaffoldColor,
        surfaceContainerHighest: const Color(0xFFE9EEF5),
        surfaceTint: Colors.transparent,
      ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(Colors.white),
      backgroundColor: WidgetStateProperty.all(primaryColor),
      surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
      overlayColor: WidgetStateProperty.all(
        primaryColor.withValues(alpha: 0.08),
      ),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(primaryColor),
      backgroundColor: WidgetStateProperty.all(Colors.transparent),
      surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
      overlayColor: WidgetStateProperty.all(
        primaryColor.withValues(alpha: 0.08),
      ),
      side: WidgetStateProperty.all(
        const BorderSide(color: primaryColor, width: 1.5),
      ),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(primaryColor),
      surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
      overlayColor: WidgetStateProperty.all(
        primaryColor.withValues(alpha: 0.08),
      ),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
    ),
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
