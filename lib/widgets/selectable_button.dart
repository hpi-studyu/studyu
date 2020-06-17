import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SelectableButton extends StatelessWidget {
  final Widget child;
  final bool selected;
  final Function() onTap;

  const SelectableButton({@required this.child, this.selected = false, this.onTap});

  Color _getFillColor(ThemeData theme) => selected ? theme.primaryColor : theme.cardColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: Divider.createBorderSide(context, color: theme.primaryColor),
        ),
        onPressed: onTap,
        color: _getFillColor(theme),
        child: child,
      ),
    );
  }
}
