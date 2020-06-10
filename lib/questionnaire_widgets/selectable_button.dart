import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SelectableButton extends StatelessWidget {
  final Widget child;
  final bool selected;
  final Function() onTap;

  SelectableButton({Key key, @required this.child, this.selected = false, this.onTap});

  Color _getFillColor(ThemeData theme) => selected ? theme.primaryColor : theme.cardColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FlatButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: theme.primaryColor),
        ),
        onPressed: onTap,
        child: child,
        color: _getFillColor(theme),
      ),
    );
  }
}
