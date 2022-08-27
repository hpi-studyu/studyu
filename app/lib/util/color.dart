import 'package:flutter/material.dart';

extension ColorBrightness on Color {
  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0).toDouble());

    return hslLight.toColor();
  }
}
