import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RoundCheckbox extends StatelessWidget {
  final Function(bool) onChanged;
  final bool value;

  const RoundCheckbox({Key key, this.onChanged, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: () {
        onChanged(!value);
      },
      icon: value
          ? Icon(
              MdiIcons.checkboxMarkedCircleOutline,
              size: 30,
              color: theme.accentColor,
            )
          : Icon(
              MdiIcons.checkboxBlankCircleOutline,
              size: 30,
              color: theme.accentColor,
            ),
    );
  }
}
