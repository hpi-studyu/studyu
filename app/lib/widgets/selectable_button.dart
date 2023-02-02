import 'package:flutter/material.dart';

class SelectableButton extends StatelessWidget {
  final Widget child;
  final bool selected;
  final Function() onTap;

  const SelectableButton({@required this.child, this.selected = false, this.onTap});

  Color _getFillColor(ThemeData theme) => selected ? theme.primaryColor : theme.cardColor;

  Color _getTextColor(ThemeData theme) => selected ? Colors.white : Colors.blue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: _getTextColor(theme),
          backgroundColor: _getFillColor(theme),
        ),
        onPressed: onTap,
        child: child,
      ),
    );
  }
}
