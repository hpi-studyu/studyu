import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pimp_my_button/pimp_my_button.dart';

class RoundCheckbox extends StatelessWidget {
  final Function(bool) onChanged;
  final bool value;

  const RoundCheckbox({Key key, this.onChanged, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PimpedButton(
      particle: DemoParticle(),
      pimpedWidgetBuilder: (context, controller) {
        return IconButton(
          onPressed: () {
            onChanged(!value);
            controller.forward(from: 0);
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
      },
    );
  }
}
