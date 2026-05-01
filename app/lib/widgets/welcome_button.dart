import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;

  const WelcomeButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  static const double _width = 240;
  static const double _height = 48;
  static const double _iconSize = 18;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleLarge;
    final iconWidget = Icon(icon, size: _iconSize);
    final labelWidget = Text(label, style: textStyle);

    return SizedBox.fromSize(
      size: const Size(_width, _height),
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: iconWidget,
              label: labelWidget,
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: iconWidget,
              label: labelWidget,
            ),
    );
  }
}
