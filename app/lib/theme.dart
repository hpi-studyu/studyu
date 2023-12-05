import 'package:flutter/material.dart';

const primaryColor = Colors.blue;
const accentColor = Colors.orange;

class ThemeConfig {
  static SliderThemeData coloredSliderTheme(ThemeData theme) => SliderThemeData(
        activeTrackColor: Colors.white.withOpacity(0.4),
        inactiveTrackColor: Colors.white.withOpacity(0),
      );
}

ThemeData get theme => ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ThemeData().colorScheme.copyWith(
        secondary: accentColor,
        primary: primaryColor,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
