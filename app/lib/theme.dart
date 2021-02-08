import 'package:flutter/material.dart';

const primaryColor = Colors.blue;
const accentColor = Colors.orange;

ThemeData get theme => ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      accentColor: accentColor,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
