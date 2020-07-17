import 'package:flutter/material.dart';

const primaryColor = Colors.indigo;
const accentColor = Colors.deepOrange;

ThemeData get theme => ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      accentColor: accentColor,
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor,
        textTheme: ButtonTextTheme.primary,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
