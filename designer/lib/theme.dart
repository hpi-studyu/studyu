import 'package:flutter/material.dart';

const primaryColor = Colors.indigo;
const accentColor = Colors.deepOrange;

ThemeData get theme => ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ThemeData().colorScheme.copyWith(secondary: accentColor),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );

const gitlabColor = Color(0xfffc6d26);
