import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SelectableButton extends StatelessWidget {
  final Widget child;
  final bool selected;
  final Function() onTap;

  SelectableButton({Key key, @required this.child, this.selected = false, this.onTap});

  Color _getFillColor(BuildContext context) => selected ? Theme.of(context).primaryColor : Theme.of(context).cardColor;

  Color _getEffectiveTextColor(BuildContext context) {
    final fillColor = _getFillColor(context);
    if (ThemeData.estimateBrightnessForColor(fillColor) == Brightness.dark) {
      return Colors.white;
    } else {
      return Theme.of(context).primaryColor;
    }
  }

  TextStyle _getTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.button.copyWith(color: _getEffectiveTextColor(context));

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.fromBorderSide(Divider.createBorderSide(context)),
          borderRadius: BorderRadius.circular(4.0),
          color: _getFillColor(context),
        ),
        child: InkWell(
          onTap: onTap,
          child: ListTile(
            title: DefaultTextStyle(
              style: _getTextStyle(context),
              child: child,
            ),
          ),
        ),
      )
    );
  }
}