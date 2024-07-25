import 'package:flutter/material.dart';

class StripedGradient {
  StripedGradient({
    required this.colors,
  });

  final List<Color> colors;

  LinearGradient get gradient {
    return LinearGradient(
      begin: Alignment.topRight,
      end: const Alignment(0.5, -0.4),
      stops: const [0.0, 0.5, 0.5, 1],
      colors: colors,
      tileMode: TileMode.repeated,
    );
  }
}
